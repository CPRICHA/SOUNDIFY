import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';
import '../data/sound_taxonomy.dart';
import '../l10n/app_localizations.dart';

/// Interactive Guide Screen featuring the 4-Tier Vibrations Wave Guide and 33 Sound Taxonomy
class GuideScreen extends StatefulWidget {
  final int initialTabIndex;

  const GuideScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<PriorityLevel, bool> _isVibratingMap = {
    PriorityLevel.critical: false,
    PriorityLevel.high: false,
    PriorityLevel.medium: false,
    PriorityLevel.low: false,
  };

  bool _hasVibrator = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _checkHardware();
  }

  Future<void> _checkHardware() async {
    final available = await HapticService.hasVibrator();
    if (mounted) {
      setState(() {
        _hasVibrator = available;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    HapticService.cancel();
    super.dispose();
  }

  Future<void> _testTier(PriorityLevel severity) async {
    setState(() {
      _isVibratingMap[severity] = true;
    });

    await HapticService.testPattern(severity);

    final duration = HapticService.getFallbackDuration(severity);
    await Future.delayed(Duration(milliseconds: duration + 100));

    if (mounted) {
      setState(() {
        _isVibratingMap[severity] = false;
      });
    }
  }

  void _showSoundDetail(
      BuildContext context, SoundLabel sound, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final localizedName =
            getLocalizedSoundName(sound.id, context: context);
        final localizedCategory =
            getLocalizedCategoryName(sound.category, context: context);
        final isHC = context.watch<AppState>().userProfile.highContrast;

        return StatefulBuilder(
          builder: (bottomCtx, setModalState) {
            final isVib = _isVibratingMap[sound.severity] ?? false;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.getSeverityBg(sound.severity),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.getSeverityBorder(sound.severity),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForSound(sound.id),
                            size: 28,
                            color: AppColors.getSeverityColor(sound.severity,
                                highContrast: isHC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isHC
                                    ? AppColors.hcText
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$localizedCategory • ${sound.environment == EnvironmentType.indoor ? l10n.indoorMode : l10n.outdoorMode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isHC
                                    ? AppColors.hcText
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getSeverityBg(sound.severity),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.getSeverityBorder(sound.severity),
                          ),
                        ),
                        child: Text(
                          _getLocalizedSeverity(sound.severity, l10n),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.getSeverityColor(sound.severity,
                                highContrast: isHC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Waveform Visual Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isHC
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isHC ? AppColors.hcBorder : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.vibration_rounded,
                              size: 16,
                              color: isHC
                                  ? AppColors.hcText
                                  : const Color(0xFF5B4FE8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.vibrationIntensity,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          HapticService.getWaveformVisual(sound.severity),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF4338CA),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          HapticService.getPatternDescription(
                              sound.severity, context),
                          style: TextStyle(
                            fontSize: 12,
                            color: isHC
                                ? AppColors.hcText
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Actions: Test Vibration & Trigger Detection
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            setModalState(() {});
                            await _testTier(sound.severity);
                            setModalState(() {});
                          },
                          icon: Icon(
                            isVib
                                ? Icons.waves_rounded
                                : Icons.vibration_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isVib ? 'Vibrating...' : l10n.testWaveform,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: isHC
                                ? AppColors.hcText
                                : const Color(0xFF5B4FE8),
                            side: BorderSide(
                              color: isHC
                                  ? AppColors.hcBorder
                                  : const Color(0xFF5B4FE8),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            final state = context.read<AppState>();
                            state.triggerSoundEvent(sound);
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text(
                            l10n.triggerDetectionEvent,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isHC
                                ? AppColors.hcBorder
                                : const Color(0xFF5B4FE8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForSound(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('fire') ||
        lower.contains('alarm') ||
        lower.contains('smoke')) {
      return Icons.local_fire_department_rounded;
    }
    if (lower.contains('glass')) return Icons.broken_image_rounded;
    if (lower.contains('pressure') || lower.contains('cooker')) {
      return Icons.soup_kitchen_rounded;
    }
    if (lower.contains('water') || lower.contains('pump') || lower.contains('rain')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('microwave')) return Icons.microwave_rounded;
    if (lower.contains('mixer') || lower.contains('grinder')) {
      return Icons.blender_rounded;
    }
    if (lower.contains('doorbell') || lower.contains('bell')) {
      return Icons.doorbell_rounded;
    }
    if (lower.contains('knock') || lower.contains('door')) {
      return Icons.meeting_room_rounded;
    }
    if (lower.contains('baby') || lower.contains('crying')) {
      return Icons.child_care_rounded;
    }
    if (lower.contains('distress') || lower.contains('scream')) {
      return Icons.warning_amber_rounded;
    }
    if (lower.contains('siren') ||
        lower.contains('police') ||
        lower.contains('ambulance')) {
      return Icons.emergency_rounded;
    }
    if (lower.contains('train')) return Icons.train_rounded;
    if (lower.contains('vehicle') ||
        lower.contains('car') ||
        lower.contains('horn') ||
        lower.contains('auto')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('blast') || lower.contains('explosion')) {
      return Icons.dangerous_rounded;
    }
    if (lower.contains('cracker')) return Icons.celebration_rounded;
    if (lower.contains('dog')) return Icons.pets_rounded;
    if (lower.contains('cat')) return Icons.pets_rounded;
    if (lower.contains('thunder')) return Icons.thunderstorm_rounded;
    if (lower.contains('speech') || lower.contains('crowd')) {
      return Icons.record_voice_over_rounded;
    }
    return Icons.volume_up_rounded;
  }

  String _getLocalizedSeverity(PriorityLevel severity, AppLocalizations l10n) {
    switch (severity) {
      case PriorityLevel.critical:
        return l10n.priorityCritical;
      case PriorityLevel.high:
        return l10n.priorityHigh;
      case PriorityLevel.medium:
        return l10n.priorityMedium;
      case PriorityLevel.low:
        return l10n.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final l10n = AppLocalizations.of(context)!;

    final tiers = [
      {
        'severity': PriorityLevel.critical,
        'title': l10n.criticalThreatsTitle,
        'desc': l10n.criticalThreatsDesc,
        'pattern': '●●●   ●●●   ●●●  (3x 500ms Pulses)',
        'timing': '500ms ON / 100ms OFF • Repeat x3',
      },
      {
        'severity': PriorityLevel.high,
        'title': l10n.highAlertsTitle,
        'desc': l10n.highAlertsDesc,
        'pattern': '●●   ●●  (2x 400ms Strong Pulses)',
        'timing': '400ms ON / 120ms OFF • Repeat x2',
      },
      {
        'severity': PriorityLevel.medium,
        'title': l10n.mediumAlertsTitle,
        'desc': l10n.mediumAlertsDesc,
        'pattern': '●  (1x 300ms Moderate Pulse)',
        'timing': '300ms Single Tap',
      },
      {
        'severity': PriorityLevel.low,
        'title': l10n.ambientSoundsTitle,
        'desc': l10n.ambientSoundsDesc,
        'pattern': '·  (1x 150ms Gentle Pulse)',
        'timing': '150ms Gentle Tap',
      },
    ];

    final filteredTaxonomy = soundTaxonomy.where((s) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = getLocalizedSoundName(s.id, context: context).toLowerCase();
      final cat =
          getLocalizedCategoryName(s.category, context: context).toLowerCase();
      return name.contains(query) || cat.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isHC ? AppColors.hcBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.hapticGuideTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isHC ? AppColors.hcText : AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: isHC ? AppColors.hcText : const Color(0xFF5B4FE8),
          tabs: [
            Tab(
              icon: const Icon(Icons.vibration_rounded, size: 20),
              text: l10n.vibrationGuide,
            ),
            Tab(
              icon: const Icon(Icons.grid_view_rounded, size: 20),
              text: 'Sound Taxonomy (33)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Vibrations Wave Guide
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hardware status banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isHC
                      ? Colors.white
                      : (_hasVibrator
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isHC
                        ? AppColors.hcBorder
                        : (_hasVibrator
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFECACA)),
                    width: isHC ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasVibrator
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 20,
                      color: _hasVibrator
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasVibrator
                              ? 'Tactile Vibration Engine Ready'
                              : 'Vibration Simulation Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isHC
                                  ? AppColors.hcText
                                  : (_hasVibrator
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _hasVibrator
                              ? 'Tap "Test Waveform" on any tier to feel its physical vibration pattern.'
                              : 'Connected physical devices will trigger tactile patterns scaled by severity.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isHC
                                  ? AppColors.hcText
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                l10n.hapticGuideTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isHC ? AppColors.hcText : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hapticGuideDesc,
                style: TextStyle(
                  fontSize: 12,
                  color: isHC ? AppColors.hcText : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // 4 Priority Tier Cards
              ...tiers.map((tier) {
                final severity = tier['severity'] as PriorityLevel;
                final isVibrating = _isVibratingMap[severity] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isVibrating
                          ? AppColors.getSeverityColor(severity)
                          : (isHC ? AppColors.hcBorder : AppColors.border),
                      width: isVibrating ? 2 : (isHC ? 2 : 1),
                    ),
                    boxShadow: isVibrating
                        ? [
                            BoxShadow(
                              color: AppColors.getSeverityColor(severity)
                                  .withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tier['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isHC
                                    ? AppColors.hcText
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.getSeverityBg(severity),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.getSeverityBorder(severity)),
                            ),
                            child: Text(
                              _getLocalizedSeverity(severity, l10n),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.getSeverityColor(severity,
                                    highContrast: isHC),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tier['desc'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isHC
                              ? AppColors.hcText
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Waveform Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHC
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isHC
                                ? AppColors.hcBorder
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.pulsePatternLabel} ${tier['pattern']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                color: isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF4338CA),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tier['timing'] as String,
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
                      const SizedBox(height: 14),

                      // Test Waveform Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _testTier(severity),
                          icon: Icon(
                            isVibrating
                                ? Icons.waves_rounded
                                : Icons.vibration_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isVibrating
                                ? 'Testing Waveform...'
                                : l10n.testWaveform,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isVibrating
                                ? AppColors.getSeverityColor(severity)
                                : (isHC
                                    ? AppColors.hcText
                                    : const Color(0xFF5B4FE8)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),

          // Tab 2: 33 Sound Taxonomy Classes
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search 33 sound classes...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isHC ? AppColors.hcBorder : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isHC ? AppColors.hcBorder : AppColors.border,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filteredTaxonomy.length,
                  itemBuilder: (context, index) {
                    final s = filteredTaxonomy[index];
                    final localizedName =
                        getLocalizedSoundName(s.id, context: context);
                    final localizedCategory =
                        getLocalizedCategoryName(s.category, context: context);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isHC ? AppColors.hcBorder : AppColors.border,
                          width: isHC ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _showSoundDetail(context, s, l10n),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getSeverityBg(s.severity),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getIconForSound(s.id),
                            size: 20,
                            color: AppColors.getSeverityColor(s.severity,
                                highContrast: isHC),
                          ),
                        ),
                        title: Text(
                          localizedName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isHC ? AppColors.hcText : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          localizedCategory,
                          style: TextStyle(
                            fontSize: 11,
                            color: isHC
                                ? AppColors.hcText
                                : AppColors.textSecondary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.getSeverityBg(s.severity),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getLocalizedSeverity(s.severity, l10n),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getSeverityColor(s.severity,
                                  highContrast: isHC),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper to display the Vibrations Wave Guide as an interactive bottom sheet
void showVibrationWaveGuideSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: const GuideScreen(initialTabIndex: 0),
      ),
    ),
  );
}
