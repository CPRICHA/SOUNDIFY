import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context);

    final homeLabel = l10n?.navHome ?? 'Home';
    final historyLabel = l10n?.navHistory ?? 'History';
    final settingsLabel = l10n?.navSettings ?? 'Settings';

    return Container(
      decoration: BoxDecoration(
        color: isHC ? Colors.white : Colors.white,
        border: Border(
          top: BorderSide(
            color: isHC ? AppColors.hcBorder : AppColors.border,
            width: isHC ? 2.0 : 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: homeLabel,
              isSelected: state.currentTabIndex == 0,
              isHC: isHC,
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.history_rounded,
              label: historyLabel,
              isSelected: state.currentTabIndex == 1,
              isHC: isHC,
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.settings_rounded,
              label: settingsLabel,
              isSelected: state.currentTabIndex == 2,
              isHC: isHC,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isHC,
  }) {
    final state = context.read<AppState>();
    final activeColor = isHC ? AppColors.hcText : AppColors.primary;
    final inactiveColor = isHC ? Colors.black54 : AppColors.textMuted;

    return InkWell(
      onTap: () => state.setTabIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
