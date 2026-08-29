import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/services.dart';
import '../services/sound_classifier.dart';
import '../theme/app_theme.dart';
import '../data/sound_taxonomy.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SoundClassificationService _classificationService;

  @override
  void initState() {
    super.initState();

    _classificationService = TFLiteSoundClassificationService();

    Future.microtask(() async {
      try {
        await _classificationService.initializeModel();

        await _classificationService.startListening((sound, confidence) {
          if (!mounted) return;

          print(
            'REAL AIISH DETECTION: ${sound.name} '
            '${(confidence * 100).toStringAsFixed(1)}%',
          );

          context.read<AppState>().triggerSoundEvent(sound, confidence);
        });
      } catch (e) {
        print('Failed to start AIISH detection: $e');
      }
    });
  }

  @override
  void dispose() {
    _classificationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final textEnabled = state.textEnabled;
    final iconEnabled = state.iconEnabled;
    final colorEnabled = state.colorEnabled;
    final lastSound = state.lastDetectedSound;
    final isListening = state.isListening;
    final l10n = AppLocalizations.of(context)!;
    final Color? detectionBorderColor =
    lastSound != null && colorEnabled
        ? AppColors.getSeverityColor(
            lastSound.severity,
            highContrast: isHC,
          )
        : null;

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title and Mode Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isHC ? AppColors.hcText : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.offlineAiSoundDetector,
                        style: TextStyle(
                          fontSize: 12,
                          color: isHC ? AppColors.hcText : AppColors.textSecondary,
                          fontWeight: isHC ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHC ? Colors.white : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHC ? AppColors.hcBorder : AppColors.primary.withOpacity(0.3),
                        width: isHC ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isListening ? l10n.active : l10n.muted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isHC ? AppColors.hcText : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Indoor / Outdoor Mode Switcher
              Container(
                decoration: BoxDecoration(
                  color: isHC ? Colors.white : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: isHC ? Border.all(color: AppColors.hcBorder, width: 2) : null,
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildEnvironmentToggle(
                        context: context,
                        label: l10n.indoorMode,
                        icon: Icons.home_rounded,
                        isSelected: state.environmentMode == EnvironmentType.indoor,
                        onTap: () => state.setEnvironmentMode(EnvironmentType.indoor),
                        isHC: isHC,
                      ),
                    ),
                    Expanded(
                      child: _buildEnvironmentToggle(
                        context: context,
                        label: l10n.outdoorMode,
                        icon: Icons.directions_walk_rounded,
                        isSelected: state.environmentMode == EnvironmentType.outdoor,
                        onTap: () => state.setEnvironmentMode(EnvironmentType.outdoor),
                        isHC: isHC,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Central Sound Detection Display Area
              Container(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                    decoration: BoxDecoration(
                      border: detectionBorderColor != null
                          ? Border.all(
                              color: detectionBorderColor,
                              width: 3,
                            )
                          : null,
                    ),
            child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple Wave Circles
                          if (isListening && lastSound == null) ...[
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lastSound != null
                                    ? (colorEnabled
                                        ? AppColors.getSeverityBg(lastSound.severity).withOpacity(0.4)
                                        : (isHC ? Colors.black12 : const Color(0xFFF1F5F9)))
                                    : (isHC ? Colors.black12 : AppColors.primaryLight.withOpacity(0.5)),
                                border: Border.all(
                                  color: lastSound != null
                                      ? (colorEnabled
                                          ? AppColors.getSeverityBorder(lastSound.severity)
                                          : (isHC ? AppColors.hcBorder : const Color(0xFFCBD5E1)))
                                      : (isHC ? AppColors.hcBorder : const Color(0xFFC7D2FE)),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isHC
                                    ? Colors.white
                                    : (lastSound != null
                                        ? (colorEnabled ? Colors.indigo.shade50.withOpacity(0.5) : const Color(0xFFF8FAFC))
                                        : Colors.indigo.shade50.withOpacity(0.5)),
                                border: Border.all(
                                  color: lastSound != null
                                      ? (colorEnabled
                                          ? AppColors.getSeverityBorder(lastSound.severity)
                                          : (isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0)))
                                      : (isHC ? AppColors.hcBorder : const Color(0xFFE0E7FF)),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ],

                          // Center display:
                          // 72x72 circular microphone while idle/listening.
                          // Responsive 140-180px PNG when a sound is detected.
                          GestureDetector(
                            onTap: () {
                              if (lastSound != null) {
                                state.clearDetectedSound();
                              } else {
                                state.toggleListening();
                              }
                            },
                            child: lastSound != null && iconEnabled
                                ? Builder(
                                    builder: (context) {
                                      final screenWidth =
                                          MediaQuery.sizeOf(context).width;

                                      final imageSize =
                                          (screenWidth * 0.5)
                                              .clamp(140.0, 180.0)
                                              .toDouble();

                                      return SizedBox(
                                        width: imageSize,
                                        height: imageSize,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.asset(
                                            lastSound.imagePath,
                                            width: imageSize,
                                            height: imageSize,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.graphic_eq_rounded,
                                                  size: 48,
                                                  color: colorEnabled
                                                      ? AppColors
                                                          .getSeverityColor(
                                                          lastSound.severity,
                                                          highContrast: isHC,
                                                        )
                                                      : AppColors.primary,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: lastSound != null
                                          ? (colorEnabled
                                              ? AppColors.getSeverityColor(
                                                  lastSound.severity,
                                                  highContrast: isHC,
                                                )
                                              : (isHC
                                                  ? AppColors.hcText
                                                  : const Color(0xFF475569)))
                                          : (isListening
                                              ? (isHC
                                                  ? AppColors.hcText
                                                  : AppColors.primary)
                                              : (isHC
                                                  ? Colors.white
                                                  : Colors.grey.shade400)),
                                      border: isHC
                                          ? Border.all(
                                              color: AppColors.hcBorder,
                                              width: 2,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      lastSound != null
                                          ? Icons.graphic_eq_rounded
                                          : (isListening
                                              ? Icons.mic_rounded
                                              : Icons.mic_off_rounded),
                                      size: 32,
                                      color: (isHC &&
                                              !isListening &&
                                              lastSound == null)
                                          ? AppColors.hcText
                                          : Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Detection or Idle Text (respecting textEnabled and colorEnabled)
                    if (lastSound != null) ...[
                      if (textEnabled) ...[
                        Text(
                          getLocalizedSoundName(lastSound.id, context: context),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isHC ? AppColors.hcText : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorEnabled
                              ? AppColors.getSeverityBg(lastSound.severity)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorEnabled
                                ? AppColors.getSeverityBorder(lastSound.severity)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          '${l10n.priorityPrefix}: ${_getLocalizedSeverity(lastSound.severity, l10n)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: colorEnabled
                                ? AppColors.getSeverityColor(lastSound.severity, highContrast: isHC)
                                : (isHC ? AppColors.hcText : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        isListening ? l10n.listeningStatus : l10n.pausedStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isHC ? AppColors.hcText : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              const SizedBox(height: 24),

              // Trigger Sound Wave Simulator
              Container(
                decoration: BoxDecoration(
                  color: isHC ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHC ? AppColors.hcBorder : AppColors.border,
                    width: isHC ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sensors_rounded,
                          size: 16,
                          color: isHC ? AppColors.hcText : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.triggerSoundWave,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isHC ? AppColors.hcText : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: state.selectedSimSoundId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isHC ? AppColors.hcBorder : AppColors.border),
                        ),
                        filled: true,
                        fillColor: isHC ? Colors.white : const Color(0xFFF8FAFC),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: isHC ? AppColors.hcText : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      items: soundTaxonomy.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(
                            '${getLocalizedSoundName(s.id, context: context)} (${_getLocalizedSeverity(s.severity, l10n)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) state.setSimSoundId(val);
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final selected = soundTaxonomy.firstWhere(
                            (s) => s.id == state.selectedSimSoundId,
                            orElse: () => soundTaxonomy.first,
                          );
                          state.triggerSoundEvent(selected);
                        },
                        icon: const Icon(Icons.volume_up_rounded, size: 16),
                        label: Text(l10n.triggerDetectionEvent),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHC ? AppColors.hcText : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Alert History Box
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentAlerts,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isHC ? AppColors.hcText : AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => state.setTabIndex(1),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
              if (state.history.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHC ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isHC ? AppColors.hcBorder : AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      l10n.noRecentSounds,
                      style: TextStyle(
                        fontSize: 12,
                        color: isHC ? AppColors.hcText : AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...state.history.take(3).map((evt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHC ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isHC ? AppColors.hcBorder : AppColors.border,
                        width: isHC ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (iconEnabled) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorEnabled
                                  ? AppColors.getSeverityBg(evt.severity)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getSoundIconData(evt.soundId.isNotEmpty ? evt.soundId : evt.label),
                              size: 18,
                              color: colorEnabled
                                  ? AppColors.getSeverityColor(evt.severity, highContrast: isHC)
                                  : (isHC ? AppColors.hcText : const Color(0xFF475569)),
                            ),
                          ),
                          if (textEnabled) const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (textEnabled)
                                Text(
                                  getLocalizedSoundName(evt.soundId.isNotEmpty ? evt.soundId : evt.label, context: context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isHC ? AppColors.hcText : AppColors.textPrimary,
                                  ),
                                ),
                              Text(
                                '${_getLocalizedMode(evt.mode, l10n)} • ${_getLocalizedSeverity(evt.severity, l10n)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isHC ? AppColors.hcText : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
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

  Widget _buildEnvironmentToggle({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isHC,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHC ? AppColors.hcText : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isHC
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isHC ? Colors.white : AppColors.primary)
                  : (isHC ? AppColors.hcText : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isHC ? Colors.white : AppColors.primary)
                    : (isHC ? AppColors.hcText : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSoundIconData(String identifier) {
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
