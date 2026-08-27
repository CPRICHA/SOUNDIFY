import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'guide_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Text controllers for profile & emergency contacts
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _emNameController;
  late TextEditingController _emPhoneController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().userProfile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _phoneController = TextEditingController(text: profile.phone);
    _emailController = TextEditingController(text: profile.email);
    _emNameController =
        TextEditingController(text: profile.emergencyContactName ?? '');
    _emPhoneController =
        TextEditingController(text: profile.emergencyContactPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emNameController.dispose();
    _emPhoneController.dispose();
    super.dispose();
  }

  void _syncProfileField() {
    final state = context.read<AppState>();
    final profile = state.userProfile;
    profile.name = _nameController.text.trim();
    final parsedAge = int.tryParse(_ageController.text.trim());
    if (parsedAge != null && parsedAge > 0) {
      profile.age = parsedAge;
    }
    profile.phone = _phoneController.text.trim();
    profile.email = _emailController.text.trim();
    profile.emergencyContactName = _emNameController.text.trim();
    profile.emergencyContactPhone = _emPhoneController.text.trim();
    state.updateProfile(profile);
  }

  void _toggleOutputPref(String format, AppLocalizations l10n) {
    final state = context.read<AppState>();
    final success = state.toggleOutputPreference(format);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.atLeastOneFormat),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddLocationModal(BuildContext context, bool isHC, AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applySuggestion(String name, String addr) {
              setModalState(() {
                nameCtrl.text = name;
                if (addrCtrl.text.isEmpty) {
                  addrCtrl.text = addr;
                }
              });
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isHC ? AppColors.hcBackground : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: isHC
                    ? Border.all(color: AppColors.hcBorder, width: 2)
                    : null,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.addLocation,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color:
                                isHC ? AppColors.hcText : AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.quickSuggestions.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color:
                            isHC ? AppColors.hcText : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickPill(
                          icon: Icons.home_rounded,
                          label: l10n.quickHome,
                          isHC: isHC,
                          onTap: () => applySuggestion(
                              l10n.quickHome, '104 Willow Creek Rd, Apt 4B'),
                        ),
                        _buildQuickPill(
                          icon: Icons.apartment_rounded,
                          label: l10n.quickOffice,
                          isHC: isHC,
                          onTap: () => applySuggestion(
                              l10n.quickOffice, 'Tech Park, Building 3, Floor 4'),
                        ),
                        _buildQuickPill(
                          icon: Icons.favorite_border_rounded,
                          label: l10n.quickParentsHouse,
                          isHC: isHC,
                          onTap: () => applySuggestion(
                              l10n.quickParentsHouse, '72 Gardenia Ave, North Wing'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.locationName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color:
                            isHC ? AppColors.hcText : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.locationNameHint,
                        filled: true,
                        fillColor:
                            isHC ? Colors.white : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isHC
                                ? AppColors.hcBorder
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.address.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color:
                            isHC ? AppColors.hcText : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addrCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.addressHint,
                        filled: true,
                        fillColor:
                            isHC ? Colors.white : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isHC
                                ? AppColors.hcBorder
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final addr = addrCtrl.text.trim();
                          if (name.isEmpty || addr.isEmpty) return;

                          final state = context.read<AppState>();
                          state.addSavedLocation(
                            SavedLocation(
                              id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              address: addr,
                              createdAt: DateTime.now().millisecondsSinceEpoch,
                            ),
                          );
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHC
                              ? AppColors.hcText
                              : const Color(0xFF5B4FE8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.saveLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickPill({
    required IconData icon,
    required String label,
    required bool isHC,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHC ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF5B4FE8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isHC ? AppColors.hcText : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context, bool isHC, AppLocalizations l10n) {
    int currentRating = 5;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isHC
                    ? const BorderSide(color: AppColors.hcBorder, width: 2)
                    : BorderSide.none,
              ),
              backgroundColor: isHC ? Colors.white : Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4FE8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B4FE8).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.cell_tower_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.rateSoundSeeTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isHC ? AppColors.hcText : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.rateSoundSeeSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isHC
                            ? AppColors.hcText
                            : const Color(0xFF64748B),
                        fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (idx) {
                        final starIndex = idx + 1;
                        final isFilled = starIndex <= currentRating;
                        return IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 32,
                            color: isFilled
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFCBD5E1),
                          ),
                          onPressed: () {
                            setDialogState(() => currentRating = starIndex);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${l10n.rateThanksPrefix} $currentRating ${l10n.rateThanksSuffix}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHC
                              ? AppColors.hcText
                              : const Color(0xFF5B4FE8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.submitReview,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        l10n.notNow,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isHC ? FontWeight.w800 : FontWeight.w600,
                          color: isHC
                              ? AppColors.hcText
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, bool isHC, AppLocalizations l10n) {
    String selectedCategory = l10n.feedbackCatGeneral;
    int feedbackRating = 5;
    final feedbackTextCtrl = TextEditingController();

    final categories = [
      l10n.feedbackCatGeneral,
      l10n.feedbackCatFeature,
      l10n.feedbackCatBug,
      l10n.feedbackCatSoundAccuracy,
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isHC
                    ? const BorderSide(color: AppColors.hcBorder, width: 2)
                    : BorderSide.none,
              ),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.rate_review_outlined,
                              size: 20,
                              color: Color(0xFF5B4FE8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.sendFeedback,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.feedbackStoredLocal,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close_rounded,
                                size: 20, color: Color(0xFF94A3B8)),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        l10n.feedbackCategory.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color:
                              isHC ? AppColors.hcText : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return InkWell(
                            onTap: () {
                              setDialogState(() => selectedCategory = cat);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF5B4FE8))
                                    : (isHC
                                        ? Colors.white
                                        : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? (isHC
                                          ? AppColors.hcBorder
                                          : const Color(0xFF5B4FE8))
                                      : (isHC
                                          ? AppColors.hcBorder
                                          : const Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : (isHC
                                          ? AppColors.hcText
                                          : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        l10n.feedbackRating.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color:
                              isHC ? AppColors.hcText : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (idx) {
                          final starIndex = idx + 1;
                          final isFilled = starIndex <= feedbackRating;
                          return IconButton(
                            padding: const EdgeInsets.only(right: 4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 26,
                              color: isFilled
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFCBD5E1),
                            ),
                            onPressed: () {
                              setDialogState(
                                  () => feedbackRating = starIndex);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        l10n.feedbackPrompt.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color:
                              isHC ? AppColors.hcText : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: feedbackTextCtrl,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isHC ? AppColors.hcText : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.feedbackHint,
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor:
                              isHC ? Colors.white : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isHC
                                  ? AppColors.hcBorder
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final text = feedbackTextCtrl.text.trim();
                                  if (text.isNotEmpty) {
                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final existingList = prefs.getStringList(
                                              'soundsee_user_feedbacks') ??
                                          [];
                                      final feedbackEntry = jsonEncode({
                                        'category': selectedCategory,
                                        'rating': feedbackRating,
                                        'text': text,
                                        'timestamp': DateTime.now()
                                            .toIso8601String(),
                                      });
                                      existingList.insert(0, feedbackEntry);
                                      await prefs.setStringList(
                                          'soundsee_user_feedbacks',
                                          existingList);
                                    } catch (_) {}
                                  }

                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            l10n.feedbackSavedSnackbar),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isHC
                                      ? AppColors.hcText
                                      : const Color(0xFF5B4FE8),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  l10n.saveFeedback,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isHC
                                        ? AppColors.hcBorder
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  l10n.cancel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content, bool isHC, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isHC
              ? const BorderSide(color: AppColors.hcBorder, width: 2)
              : BorderSide.none,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: isHC ? AppColors.hcText : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.userProfile;
    final isHC = profile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    final isEmergencyMissing = profile.emergencyContactName == null ||
        profile.emergencyContactName!.trim().isEmpty ||
        profile.emergencyContactPhone == null ||
        profile.emergencyContactPhone!.trim().isEmpty;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isHC ? AppColors.hcText : AppColors.textPrimary,
              ),
            ),
            Text(
              l10n.settingsSubtitle.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isHC ? AppColors.hcText : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Required Safety Setting banner (only shows if emergency contact is empty)
          if (isEmergencyMissing) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHC ? AppColors.hcBorder : const Color(0xFFFECACA),
                  width: isHC ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.requiredSafetySetting.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.requiredSafetySettingDesc,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF7F1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 2. Account & Profile card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.person_rounded,
            title: l10n.accountProfile.toUpperCase(),
            children: [
              _buildFieldLabel(l10n.fullName.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _nameController,
                isHC: isHC,
                onChanged: (_) => _syncProfileField(),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(l10n.userAge.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _ageController,
                isHC: isHC,
                prefixIcon: Icons.calendar_today_rounded,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncProfileField(),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(l10n.yourPhone.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _phoneController,
                isHC: isHC,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                onChanged: (_) => _syncProfileField(),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(l10n.yourEmail.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _emailController,
                isHC: isHC,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _syncProfileField(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.signOutConfirmTitle),
                        content: Text(l10n.signOutConfirmDesc),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(l10n.signOut,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await state.resetOnboarding();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: Text(
                    l10n.signOutProfile,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isHC ? AppColors.hcBorder : const Color(0xFFFECACA),
                        width: isHC ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Alert Preferences card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.tune_rounded,
            title: l10n.alertPreferences.toUpperCase(),
            children: [
              _buildFieldLabel(l10n.alertFormats.toUpperCase(), isHC),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFormatPill('text', l10n.formatText, profile.outputPreferences, isHC, l10n),
                  const SizedBox(width: 8),
                  _buildFormatPill('icon', l10n.formatIcon, profile.outputPreferences, isHC, l10n),
                  const SizedBox(width: 8),
                  _buildFormatPill('color', l10n.formatColor, profile.outputPreferences, isHC, l10n),
                ],
              ),
              const SizedBox(height: 14),
              // Vibrations wave guide button
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GuideScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isHC ? Colors.white : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHC
                          ? AppColors.hcBorder
                          : const Color(0xFFC7D2FE),
                      width: isHC ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vibration_rounded,
                        size: 18,
                        color: isHC
                            ? AppColors.hcText
                            : const Color(0xFF5B4FE8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.vibrationsWaveGuide,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF4338CA),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Interactive 4-tier tactile wave preview',
                              style: TextStyle(
                                fontSize: 11,
                                color: isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isHC
                            ? AppColors.hcText
                            : const Color(0xFF5B4FE8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('HAPTIC NOTIFICATION MUTING', isHC),
              const SizedBox(height: 6),
              // Mute Low Severity Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.muteLowSeverity,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC
                                ? AppColors.hcText
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Silences vibrations for ambient / low sounds',
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC
                                ? AppColors.hcText
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: profile.muteLowAlerts,
                    activeColor: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    onChanged: (val) {
                      state.setMuteLowAlerts(val);
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              // Mute Medium Severity Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mute Medium Severity',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC
                                ? AppColors.hcText
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Silences vibrations for doorbells & knocks',
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC
                                ? AppColors.hcText
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: profile.muteMediumAlerts,
                    activeColor: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    onChanged: (val) {
                      state.setMuteMediumAlerts(val);
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              // High & Critical Locked Notice
              Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: isHC ? AppColors.hcText : const Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Critical & High emergency alerts are locked active for personal safety.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isHC ? AppColors.hcText : const Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Emergency Contacts card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.notifications_active_rounded,
            title: l10n.emergencyContactTitle.toUpperCase(),
            children: [
              _buildFieldLabel(l10n.contactName.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _emNameController,
                hintText: l10n.contactNameHint,
                isHC: isHC,
                prefixIcon: Icons.person_outline_rounded,
                onChanged: (_) => _syncProfileField(),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(l10n.contactPhone.toUpperCase(), isHC),
              const SizedBox(height: 4),
              _buildInlineTextField(
                controller: _emPhoneController,
                hintText: l10n.contactPhoneHint,
                isHC: isHC,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                onChanged: (_) => _syncProfileField(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Saved Locations card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.location_on_outlined,
            title: l10n.savedLocations.toUpperCase(),
            headerAction: InkWell(
              onTap: () => _showAddLocationModal(context, isHC, l10n),
              child: Text(
                '+ ${l10n.addLocation}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                ),
              ),
            ),
            children: [
              Text(
                l10n.personalLocationsSubtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isHC ? AppColors.hcText : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              if (profile.savedLocations.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_off_outlined,
                        size: 32,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noSavedLocations,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isHC
                              ? AppColors.hcText
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            _showAddLocationModal(context, isHC, l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FF),
                          foregroundColor: const Color(0xFF5B4FE8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '+ ${l10n.addLocation}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: profile.savedLocations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final loc = profile.savedLocations[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isHC ? Colors.white : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHC
                              ? AppColors.hcBorder
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Color(0xFF5B4FE8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  loc.address,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isHC
                                        ? AppColors.hcText
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () =>
                                state.removeSavedLocation(loc.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // 6. Detection Behavior card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.explore_outlined,
            title: l10n.detectionBehavior.toUpperCase(),
            children: [
              // Outdoor mode override
              Row(
                children: [
                  const Icon(
                    Icons.park_outlined,
                    size: 20,
                    color: Color(0xFF5B4FE8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.outdoorOverride,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isHC ? AppColors.hcText : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Switch(
                    value: state.environmentMode == EnvironmentType.outdoor,
                    activeColor:
                        isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    onChanged: (val) {
                      state.setEnvironmentMode(val
                          ? EnvironmentType.outdoor
                          : EnvironmentType.indoor);
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              // GPS auto-detect
              Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 20,
                    color: Color(0xFF5B4FE8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          l10n.gpsAutoDetect,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: profile.gpsAutoDetect,
                    activeColor:
                        isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    onChanged: (val) {
                      profile.gpsAutoDetect = val;
                      state.updateProfile(profile);
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              // Microphone sampling
              Row(
                children: [
                  const Icon(
                    Icons.mic_rounded,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.microphoneSampling,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          l10n.accessGranted,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '✓ ${l10n.activeUpper}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // System Notifications & Background Alerts card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.notifications_active_outlined,
            title: l10n.systemNotifications.toUpperCase(),
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.security_update_good_rounded,
                    size: 20,
                    color: Color(0xFF5B4FE8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.backgroundChannels,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC ? AppColors.hcText : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          l10n.fullScreenIntentSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC ? AppColors.hcText : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final granted = await NotificationService.instance.requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              granted
                                  ? l10n.permissionsVerified
                                  : l10n.permissionsRequiredWarning,
                            ),
                            backgroundColor: granted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        );
                      }
                    },
                    child: Text(
                      l10n.verifyUpper,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5B4FE8),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.cell_tower_rounded,
                    size: 20,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.testSystemAlert,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isHC ? AppColors.hcText : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          l10n.testSystemAlertSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC ? AppColors.hcText : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final testSound = soundTaxonomy.firstWhere(
                        (s) => s.severity == PriorityLevel.critical,
                        orElse: () => soundTaxonomy.first,
                      );
                      state.triggerSoundEvent(testSound);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.dispatchedSystemAlert}: ${getLocalizedSoundName(testSound.id, context: context)}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FE8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.testUpper,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7. Accessibility card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.visibility_outlined,
            title: l10n.accessibilitySection.toUpperCase(),
            children: [
              _buildFieldLabel(l10n.appLanguage.toUpperCase(), isHC),
              const SizedBox(height: 4),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isHC ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHC
                        ? AppColors.hcBorder
                        : const Color(0xFFCBD5E1),
                    width: isHC ? 2 : 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: profile.language,
                    items: const [
                      DropdownMenuItem(
                          value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Hindi', child: Text('हिंदी (Hindi)')),
                      DropdownMenuItem(
                          value: 'Kannada', child: Text('ಕನ್ನಡ (Kannada)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        state.setLanguage(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldLabel(l10n.fontSize.toUpperCase(), isHC),
              const SizedBox(height: 4),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isHC ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHC
                        ? AppColors.hcBorder
                        : const Color(0xFFCBD5E1),
                    width: isHC ? 2 : 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: profile.textSize,
                    items: [
                      DropdownMenuItem(
                          value: 'small', child: Text('${l10n.fontSizeSmall} (85%)')),
                      DropdownMenuItem(
                          value: 'medium', child: Text('${l10n.fontSizeMedium} (100%)')),
                      DropdownMenuItem(
                          value: 'large', child: Text('${l10n.fontSizeLarge} (115%)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        state.setFontScale(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.contrast_rounded,
                    size: 20,
                    color: Color(0xFF5B4FE8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.highContrast,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isHC
                            ? AppColors.hcText
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Switch(
                    value: profile.highContrast,
                    activeColor:
                        isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    onChanged: (_) => state.toggleHighContrast(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8. About App card
          _buildCard(
            isHC: isHC,
            headerIcon: Icons.info_outline_rounded,
            title: l10n.aboutApp.toUpperCase(),
            children: [
              _buildAboutRow(
                icon: Icons.description_outlined,
                label: l10n.termsAndConditions,
                isHC: isHC,
                onTap: () => _showInfoDialog(
                  context,
                  l10n.termsAndConditions,
                  l10n.termsDialogBody,
                  isHC,
                  l10n,
                ),
              ),
              const Divider(height: 16),
              _buildAboutRow(
                icon: Icons.shield_outlined,
                label: l10n.privacyPolicy,
                isHC: isHC,
                onTap: () => _showInfoDialog(
                  context,
                  l10n.privacyPolicy,
                  l10n.privacyDialogBody,
                  isHC,
                  l10n,
                ),
              ),
              const Divider(height: 16),
              _buildAboutRow(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFEF3C7),
                label: l10n.rateSoundSee,
                isHC: isHC,
                onTap: () => _showRateDialog(context, isHC, l10n),
              ),
              const Divider(height: 16),
              _buildAboutRow(
                icon: Icons.rate_review_outlined,
                label: l10n.sendFeedback,
                isHC: isHC,
                onTap: () => _showFeedbackDialog(context, isHC, l10n),
              ),
              const Divider(height: 16),
              _buildAboutRow(
                icon: Icons.local_offer_outlined,
                label: l10n.releaseVersion,
                trailingText: 'v1.0.0+1',
                isHC: isHC,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isHC,
    required IconData headerIcon,
    required String title,
    Widget? headerAction,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
          width: isHC ? 2 : 1,
        ),
        boxShadow: isHC
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                headerIcon,
                size: 16,
                color: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isHC ? AppColors.hcText : const Color(0xFF0F172A),
                ),
              ),
              if (headerAction != null) ...[
                const Spacer(),
                headerAction,
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isHC) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isHC ? AppColors.hcText : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildInlineTextField({
    required TextEditingController controller,
    required bool isHC,
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isHC ? AppColors.hcText : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF94A3B8),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 16,
                color: isHC ? AppColors.hcText : const Color(0xFF64748B),
              )
            : null,
        filled: true,
        fillColor: isHC ? Colors.white : const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isHC ? AppColors.hcBorder : const Color(0xFFCBD5E1),
            width: isHC ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isHC ? AppColors.hcBorder : const Color(0xFFCBD5E1),
            width: isHC ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8),
            width: isHC ? 2 : 2,
          ),
        ),
      ),
    );
  }

  Widget _buildFormatPill(
    String key,
    String label,
    List<String> activeList,
    bool isHC,
    AppLocalizations l10n,
  ) {
    final isActive = activeList.contains(key);

    return Expanded(
      child: InkWell(
        onTap: () => _toggleOutputPref(key, l10n),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isHC ? AppColors.hcText : const Color(0xFF5B4FE8))
                : (isHC ? Colors.white : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8))
                  : (isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0)),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : (isHC ? AppColors.hcText : const Color(0xFF475569)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutRow({
    required IconData icon,
    Color? iconColor,
    Color? iconBgColor,
    required String label,
    String? trailingText,
    required bool isHC,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBgColor ??
                    (isHC ? AppColors.hcText : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor ??
                    (isHC ? Colors.white : const Color(0xFF5B4FE8)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isHC ? AppColors.hcText : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isHC ? AppColors.hcText : const Color(0xFF94A3B8),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isHC ? AppColors.hcText : const Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }
}
