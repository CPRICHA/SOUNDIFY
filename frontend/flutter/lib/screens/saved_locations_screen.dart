import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../app.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({Key? key}) : super(key: key);

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final List<SavedLocation> _localLocations = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing locations if any
    final state = context.read<AppState>();
    _localLocations.addAll(state.userProfile.savedLocations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _applySuggestion(String name, String defaultAddress) {
    setState(() {
      _nameController.text = name;
      if (_addressController.text.isEmpty) {
        _addressController.text = defaultAddress;
      }
    });
  }

  void _handleAddLocation(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errEnterLocationAndAddress),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newLoc = SavedLocation(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _localLocations.add(newLoc);
      _nameController.clear();
      _addressController.clear();
    });
  }

  void _handleRemoveLocation(String id) {
    setState(() {
      _localLocations.removeWhere((l) => l.id == id);
    });
  }

  Future<void> _handleComplete() async {
    final state = context.read<AppState>();
    final profile = state.userProfile;
    profile.savedLocations = _localLocations;
    state.updateProfile(profile);

    await state.completeOnboarding(profile: profile);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.savedLocationsTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Header Pin Badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isHC ? AppColors.hcText : AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: isHC
                            ? Border.all(color: AppColors.hcBorder, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 28,
                          color: isHC ? Colors.white : const Color(0xFF5B4FE8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Heading
                    Text(
                      l10n.savedLocationsHeading,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isHC ? AppColors.hcText : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtext
                    Text(
                      l10n.savedLocationsDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isHC ? AppColors.hcText : AppColors.textSecondary,
                        fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Form Card Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHC
                              ? AppColors.hcBorder
                              : const Color(0xFFE2E8F0),
                          width: isHC ? 2 : 1,
                        ),
                        boxShadow: isHC
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // QUICK SUGGESTIONS
                          _buildSectionLabel(l10n.labelQuickSuggestions, isHC),
                          const SizedBox(height: 8),

                          // 2x2 Grid of pill buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildSuggestionPill(
                                  icon: Icons.home_rounded,
                                  label: l10n.suggestHome,
                                  isHC: isHC,
                                  onTap: () => _applySuggestion(
                                      l10n.suggestHome, '124 Maple Street, Apt 3B'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSuggestionPill(
                                  icon: Icons.school_rounded,
                                  label: l10n.suggestSchool,
                                  isHC: isHC,
                                  onTap: () => _applySuggestion(
                                      l10n.suggestSchool, 'University Campus, Hall 4'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSuggestionPill(
                                  icon: Icons.work_rounded,
                                  label: l10n.suggestOffice,
                                  isHC: isHC,
                                  onTap: () => _applySuggestion(
                                      l10n.suggestOffice, '742 Tech Park, Tower B'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSuggestionPill(
                                  icon: Icons.fitness_center_rounded,
                                  label: l10n.suggestGym,
                                  isHC: isHC,
                                  onTap: () => _applySuggestion(
                                      l10n.suggestGym, 'Fitness Club, 5th Main Rd'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // LOCATION NAME Label + Input
                          _buildSectionLabel(l10n.labelLocationName, isHC),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isHC ? AppColors.hcText : AppColors.textPrimary,
                            ),
                            decoration: _buildInputDecoration(
                              hint: l10n.placeholderLocName,
                              isHC: isHC,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ADDRESS Label + Input
                          _buildSectionLabel(l10n.labelAddress, isHC),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _addressController,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isHC ? AppColors.hcText : AppColors.textPrimary,
                            ),
                            decoration: _buildInputDecoration(
                              hint: l10n.placeholderAddress,
                              isHC: isHC,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // + Add Location Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAddLocation(l10n),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(
                                l10n.addLocation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF5B4FE8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isHC
                                      ? const BorderSide(
                                          color: AppColors.hcBorder, width: 2)
                                      : BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Added locations list
                    if (_localLocations.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${l10n.savedLocationsTitle.toUpperCase()} (${_localLocations.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _localLocations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final loc = _localLocations[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isHC
                                  ? Colors.white
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isHC
                                    ? AppColors.hcBorder
                                    : const Color(0xFFE2E8F0),
                                width: isHC ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 20,
                                  color: isHC
                                      ? AppColors.hcText
                                      : const Color(0xFF5B4FE8),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isHC
                                              ? AppColors.hcText
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        loc.address,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isHC
                                              ? AppColors.hcText
                                              : AppColors.textSecondary,
                                          fontWeight: isHC
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: Color(0xFFEF4444),
                                  ),
                                  onPressed: () =>
                                      _handleRemoveLocation(loc.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isHC
                              ? const BorderSide(
                                  color: AppColors.hcBorder, width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        _localLocations.isNotEmpty
                            ? l10n.completeSetup
                            : l10n.skipAndFinish,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isHC) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isHC ? AppColors.hcText : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildSuggestionPill({
    required IconData icon,
    required String label,
    required bool isHC,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
            width: isHC ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required bool isHC,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
          width: isHC ? 2 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
          width: isHC ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8),
          width: isHC ? 2 : 2,
        ),
      ),
    );
  }
}
