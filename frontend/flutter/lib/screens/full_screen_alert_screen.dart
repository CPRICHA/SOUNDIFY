import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../data/sound_taxonomy.dart';
import '../l10n/app_localizations.dart';

class FullScreenAlertScreen extends StatefulWidget {
  final SoundLabel? sound;

  const FullScreenAlertScreen({Key? key, this.sound}) : super(key: key);

  @override
  State<FullScreenAlertScreen> createState() => _FullScreenAlertScreenState();
}

class _FullScreenAlertScreenState extends State<FullScreenAlertScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSnoozed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  SoundLabel _resolveSound(BuildContext context) {
    if (widget.sound != null) return widget.sound!;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    if (routeArg is SoundLabel) {
      return routeArg;
    }
    final state = context.read<AppState>();
    return state.lastDetectedSound ?? soundTaxonomy.first;
  }

  IconData _getIconForSound(String id) {
    final lower = id.toLowerCase();
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

  void _handleDismiss() {
    final state = context.read<AppState>();
    state.clearDetectedSound();
    NotificationService.instance.cancelAll();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _handleSnooze(AppLocalizations l10n) {
    setState(() {
      _isSnoozed = true;
    });
    final state = context.read<AppState>();
    state.clearDetectedSound();
    NotificationService.instance.cancelAll();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snoozeSnackbar),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  void _handleEmergencyContact(AppLocalizations l10n) {
    final state = context.read<AppState>();
    final contactName = state.userProfile.emergencyContactName ?? l10n.emergencyContactTitle;
    final contactPhone = state.userProfile.emergencyContactPhone ?? '112';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.emergencyAlertSent)),
          ],
        ),
        content: Text(
          '${l10n.emergencyAlertDesc} $contactName ($contactPhone).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sound = _resolveSound(context);
    final state = context.watch<AppState>();
    final isHC = state.userProfile.highContrast;
    final textEnabled = state.textEnabled;
    final iconEnabled = state.iconEnabled;
    final colorEnabled = state.colorEnabled;
    final l10n = AppLocalizations.of(context)!;

    final isCritical = sound.severity == PriorityLevel.critical;
    final isHigh = sound.severity == PriorityLevel.high;

    // Theme color palette matching alert tier & colorEnabled modifier
    final Color primaryAlertColor = colorEnabled
        ? (isHC
            ? (isCritical ? const Color(0xFFDC2626) : const Color(0xFFEA580C))
            : (isCritical
                ? const Color(0xFFEF4444)
                : isHigh
                    ? const Color(0xFFF97316)
                    : const Color(0xFF3B82F6)))
        : (isHC ? Colors.white : const Color(0xFF94A3B8));

    final Color bgGradientStart = colorEnabled
        ? (isHC
            ? Colors.black
            : (isCritical
                ? const Color(0xFF450A0A)
                : isHigh
                    ? const Color(0xFF431407)
                    : const Color(0xFF0F172A)))
        : (isHC ? Colors.black : const Color(0xFF1E293B));

    final Color bgGradientEnd = colorEnabled
        ? (isHC
            ? const Color(0xFF18181B)
            : (isCritical
                ? const Color(0xFF1C1917)
                : const Color(0xFF020617)))
        : (isHC ? const Color(0xFF18181B) : const Color(0xFF0F172A));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Top Header Badge: FULL SCREEN INTENT / ALERT ACTIVE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryAlertColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryAlertColor.withOpacity(0.6),
                          width: 1.5,
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
                              color: primaryAlertColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCritical
                                ? l10n.criticalAlertHeader
                                : '${_getLocalizedSeverity(sound.severity, l10n)} ${l10n.priorityPrefix.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: primaryAlertColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: _handleDismiss,
                      tooltip: l10n.closeAlert,
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Pulsing Center Icon & Radar Rings (Only rendered when iconEnabled is true)
                if (iconEnabled) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Radar Ring
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryAlertColor.withOpacity(0.12),
                                border: Border.all(
                                  color: primaryAlertColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Middle Radar Ring
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryAlertColor.withOpacity(0.22),
                                border: Border.all(
                                  color: primaryAlertColor.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Core Icon Container
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryAlertColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryAlertColor.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getIconForSound(sound.id),
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                ],

                // Sound Class Label and Categories (Only rendered when textEnabled is true)
                if (textEnabled) ...[
                  Text(
                    getLocalizedSoundName(sound.id, context: context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: iconEnabled ? 28 : 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category & Environment Mode Tag
                  Text(
                    '${getLocalizedCategoryName(sound.category, context: context).toUpperCase()} • ${_getLocalizedMode(sound.environment, l10n).toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Tactile Vibration Pattern Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vibration_rounded,
                          size: 18, color: Colors.white70),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isCritical
                              ? l10n.continuousEmergencyVibration
                              : l10n.tactilePulsePattern,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Emergency Contact Quick Action (For Critical & High)
                if (isCritical || isHigh) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleEmergencyContact(l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.emergency_share_rounded, size: 20),
                      label: Text(
                        state.userProfile.emergencyContactName != null &&
                                state.userProfile.emergencyContactName!.isNotEmpty
                            ? '${l10n.notifyContact} ${state.userProfile.emergencyContactName}'
                            : l10n.dispatchEmergencyAlert,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Buttons: Snooze & Dismiss
                Row(
                  children: [
                    // Snooze Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isSnoozed ? null : () => _handleSnooze(l10n),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.snooze_rounded, size: 18),
                          label: Text(
                            l10n.snooze,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Dismiss Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _handleDismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          label: Text(
                            l10n.dismiss,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
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
}
