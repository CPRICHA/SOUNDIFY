import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'saved_locations_screen.dart';

class AlertPresentationScreen extends StatefulWidget {
  const AlertPresentationScreen({Key? key}) : super(key: key);

  @override
  State<AlertPresentationScreen> createState() => _AlertPresentationScreenState();
}

class _AlertPresentationScreenState extends State<AlertPresentationScreen> {
  // All three selected by default
  final Set<String> _selectedPrefs = {'text', 'icon', 'color'};

  void _togglePref(String key, AppLocalizations l10n) {
    setState(() {
      if (_selectedPrefs.contains(key)) {
        // Enforce hard rule: at least one of Text or Icon must remain selected
        if (key == 'text' && !_selectedPrefs.contains('icon')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errAtLeastOneFormat),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        if (key == 'icon' && !_selectedPrefs.contains('text')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errAtLeastOneFormat),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedPrefs.remove(key);
      } else {
        _selectedPrefs.add(key);
      }
    });
  }

  void _handleNext() {
    if (_selectedPrefs.isEmpty) return;

    final state = context.read<AppState>();
    final profile = state.userProfile;
    profile.outputPreferences = _selectedPrefs.toList();
    state.updateProfile(profile);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SavedLocationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    final canProceed = _selectedPrefs.isNotEmpty;

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
          l10n.prefPresentationTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtext
              Text(
                l10n.prefPresentationDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: isHC ? AppColors.hcText : AppColors.textSecondary,
                  fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Text notifications card
              _buildOptionCard(
                id: 'text',
                title: l10n.prefTextTitle,
                description: l10n.prefTextDesc,
                icon: Icons.title_rounded,
                isHC: isHC,
                l10n: l10n,
              ),
              const SizedBox(height: 14),

              // 2. Icon-forward cards
              _buildOptionCard(
                id: 'icon',
                title: l10n.prefIconTitle,
                description: l10n.prefIconDesc,
                icon: Icons.image_rounded,
                isHC: isHC,
                l10n: l10n,
              ),
              const SizedBox(height: 14),

              // 3. Vibrant Color bands
              _buildOptionCard(
                id: 'color',
                title: l10n.prefColorTitle,
                description: l10n.prefColorDesc,
                icon: Icons.palette_rounded,
                isHC: isHC,
                l10n: l10n,
              ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canProceed ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isHC
                          ? const BorderSide(color: AppColors.hcBorder, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    l10n.nextSavedLocations,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required bool isHC,
    required AppLocalizations l10n,
  }) {
    final isSelected = _selectedPrefs.contains(id);

    return InkWell(
      onTap: () => _togglePref(id, l10n),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8))
                : (isHC ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5B4FE8).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Leading Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isHC ? AppColors.hcText : const Color(0xFFEEF2FF))
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? (isHC ? Colors.white : const Color(0xFF5B4FE8))
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 14),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isHC ? AppColors.hcText : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isHC
                          ? AppColors.hcText
                          : const Color(0xFF64748B),
                      fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark or radio bubble
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isHC ? AppColors.hcText : const Color(0xFF5B4FE8))
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? (isHC ? AppColors.hcBorder : const Color(0xFF5B4FE8))
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
