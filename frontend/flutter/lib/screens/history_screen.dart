import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../data/sound_taxonomy.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final textEnabled = state.textEnabled;
    final iconEnabled = state.iconEnabled;
    final colorEnabled = state.colorEnabled;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.historyTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (state.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => state.clearHistory(),
              tooltip: l10n.clearHistory,
            ),
        ],
      ),
      body: state.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 48,
                    color: isHC ? AppColors.hcText : AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noHistory,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isHC ? AppColors.hcText : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.noHistorySub,
                    style: TextStyle(
                      fontSize: 12,
                      color: isHC ? AppColors.hcText : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final evt = state.history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isHC ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHC ? AppColors.hcBorder : AppColors.border,
                      width: isHC ? 2 : 1,
                    ),
                    boxShadow: isHC
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      if (iconEnabled) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorEnabled
                                ? AppColors.getSeverityBg(evt.severity)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorEnabled
                                  ? AppColors.getSeverityBorder(evt.severity)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(
                            _getIcon(evt.soundId.isNotEmpty ? evt.soundId : evt.label),
                            size: 20,
                            color: colorEnabled
                                ? AppColors.getSeverityColor(evt.severity, highContrast: isHC)
                                : (isHC ? AppColors.hcText : const Color(0xFF475569)),
                          ),
                        ),
                        if (textEnabled) const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (textEnabled) ...[
                              Text(
                                getLocalizedSoundName(evt.soundId.isNotEmpty ? evt.soundId : evt.label, context: context),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isHC ? AppColors.hcText : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              '${_getLocalizedMode(evt.mode, l10n)} • ${evt.timestamp.hour.toString().padLeft(2, '0')}:${evt.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isHC ? AppColors.hcText : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorEnabled
                              ? AppColors.getSeverityBg(evt.severity)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getLocalizedSeverity(evt.severity, l10n),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colorEnabled
                                ? AppColors.getSeverityColor(evt.severity, highContrast: isHC)
                                : (isHC ? AppColors.hcText : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _getLocalizedSeverity(PriorityLevel severity, AppLocalizations l10n) {
    switch (severity) {
      case PriorityLevel.critical:
        return l10n.critical;
      case PriorityLevel.high:
        return l10n.high;
      case PriorityLevel.medium:
        return l10n.medium;
      case PriorityLevel.low:
        return l10n.low;
    }
  }

  String _getLocalizedMode(EnvironmentType mode, AppLocalizations l10n) {
    return mode == EnvironmentType.indoor ? l10n.indoorMode : l10n.outdoorMode;
  }

  IconData _getIcon(String identifier) {
    final lower = identifier.toLowerCase();
    if (lower.contains('fire') || lower.contains('alarm') || lower.contains('smoke')) {
      return Icons.local_fire_department_rounded;
    }
    if (lower.contains('glass')) return Icons.gavel_rounded;
    if (lower.contains('cooker') || lower.contains('whistle')) return Icons.air_rounded;
    if (lower.contains('water')) return Icons.water_drop_rounded;
    if (lower.contains('doorbell') || lower.contains('bell')) return Icons.notifications_active_rounded;
    if (lower.contains('knock')) return Icons.meeting_room_rounded;
    if (lower.contains('baby') || lower.contains('cry')) return Icons.child_care_rounded;
    if (lower.contains('siren')) return Icons.emergency_rounded;
    if (lower.contains('horn') || lower.contains('vehicle')) return Icons.directions_car_rounded;
    if (lower.contains('thunder')) return Icons.thunderstorm_rounded;
    return Icons.volume_up_rounded;
  }
}
