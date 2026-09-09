import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';

/// Central Haptic Service providing unified, hardware-checked vibration pattern triggers
/// scaled across priority tiers for both background/isolate detections and in-app interactive guides.
class HapticService {
  HapticService._internal();
  static final HapticService instance = HapticService._internal();

  /// Critical Tier Pattern: 3 strong repeating pulses of 500ms with 100ms gaps
  static const List<int> criticalPattern = [0, 500, 100, 500, 100, 500];
  static const List<int> criticalIntensities = [0, 255, 0, 255, 0, 255];
  static const int criticalDuration = 1700;

  /// High Tier Pattern: 2 strong pulses of 400ms with 120ms gap
  static const List<int> highPattern = [0, 400, 120, 400];
  static const List<int> highIntensities = [0, 220, 0, 220];
  static const int highDuration = 920;

  /// Medium Tier Pattern: 1 moderate single pulse of 300ms
  static const List<int> mediumPattern = [0, 300];
  static const List<int> mediumIntensities = [0, 180];
  static const int mediumDuration = 300;

  /// Low Tier Pattern: 1 brief gentle single pulse of 150ms
  static const List<int> lowPattern = [0, 150];
  static const List<int> lowIntensities = [0, 120];
  static const int lowDuration = 150;

  /// Check if the physical device has a vibration motor
  static Future<bool> hasVibrator() async {
    try {
      final hasVib = await Vibration.hasVibrator();
      return hasVib ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if custom pattern vibrations are supported
  static Future<bool> hasCustomVibrationsSupport() async {
    try {
      final custom = await Vibration.hasCustomVibrationsSupport();
      return custom ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if amplitude control is supported
  static Future<bool> hasAmplitudeControl() async {
    try {
      final amplitude = await Vibration.hasAmplitudeControl();
      return amplitude ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Triggers hardware vibration for a given priority tier.
  /// Respects `isMuted` and skips gracefully if vibration is unavailable.
  static Future<void> triggerVibration(
    PriorityLevel severity, {
    bool isMuted = false,
  }) async {
    if (isMuted) return;

    try {
      final canVibrate = await hasVibrator();
      if (!canVibrate) return;

      final customSupport = await hasCustomVibrationsSupport();
      final ampSupport = await hasAmplitudeControl();

      final pattern = getPattern(severity);
      final intensities = getIntensities(severity);
      final duration = getFallbackDuration(severity);

      if (customSupport) {
        if (ampSupport && intensities.isNotEmpty) {
          await Vibration.vibrate(
            pattern: pattern,
            intensities: intensities,
          );
        } else {
          await Vibration.vibrate(pattern: pattern);
        }
      } else {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.triggerVibration error (handled gracefully): $e');
      }
    }
  }

  /// Test a priority tier directly (ignores mute setting for preview purposes)
  static Future<void> testPattern(PriorityLevel severity) async {
    await triggerVibration(severity, isMuted: false);
  }

  /// Cancel any currently vibrating pattern
  static Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('HapticService.cancel error: $e');
      }
    }
  }

  /// Pattern array for a given severity
  static List<int> getPattern(PriorityLevel severity) {
    switch (severity) {
      case PriorityLevel.critical:
        return criticalPattern;
      case PriorityLevel.high:
        return highPattern;
      case PriorityLevel.medium:
        return mediumPattern;
      case PriorityLevel.low:
        return lowPattern;
    }
  }

  /// Intensities array for a given severity (0-255)
  static List<int> getIntensities(PriorityLevel severity) {
    switch (severity) {
      case PriorityLevel.critical:
        return criticalIntensities;
      case PriorityLevel.high:
        return highIntensities;
      case PriorityLevel.medium:
        return mediumIntensities;
      case PriorityLevel.low:
        return lowIntensities;
    }
  }

  /// Fallback duration in ms for basic vibrators
  static int getFallbackDuration(PriorityLevel severity) {
    switch (severity) {
      case PriorityLevel.critical:
        return criticalDuration;
      case PriorityLevel.high:
        return highDuration;
      case PriorityLevel.medium:
        return mediumDuration;
      case PriorityLevel.low:
        return lowDuration;
    }
  }

  /// Visual representation of the tactile pulse waveform
  static String getWaveformVisual(PriorityLevel severity) {
    switch (severity) {
      case PriorityLevel.critical:
        return '●●●  ●●●  ●●● (3x 500ms Max Intensity)';
      case PriorityLevel.high:
        return '●●  ●● (2x 400ms Strong Pulses)';
      case PriorityLevel.medium:
        return '● (1x 300ms Moderate Pulse)';
      case PriorityLevel.low:
        return '· (1x 150ms Gentle Tap)';
    }
  }

  /// Summary description of the vibration pattern
  static String getPatternDescription(PriorityLevel severity, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (severity) {
      case PriorityLevel.critical:
        return l10n?.criticalThreatsDesc ?? 'Fire, blasts, emergency sirens, train horn, danger sounds';
      case PriorityLevel.high:
        return l10n?.highAlertsDesc ?? 'Pressure cooker, crying baby, approaching vehicles, horns, crackers';
      case PriorityLevel.medium:
        return l10n?.mediumAlertsDesc ?? 'Doorbell, door knock, mixer, dog bark, name calling, vendor, utensils';
      case PriorityLevel.low:
        return l10n?.ambientSoundsDesc ?? 'Cat meow, cow mooing, temple bell, rain, crowd chatter';
    }
  }

  /// Title for the priority tier row
  static String getTierTitle(PriorityLevel severity, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (severity) {
      case PriorityLevel.critical:
        return l10n?.criticalThreatsTitle ?? 'Critical Threats (High Intensity)';
      case PriorityLevel.high:
        return l10n?.highAlertsTitle ?? 'High Priority Alerts (Moderate-High Intensity)';
      case PriorityLevel.medium:
        return l10n?.mediumAlertsTitle ?? 'Medium Priority Alerts (Medium Intensity)';
      case PriorityLevel.low:
        return l10n?.ambientSoundsTitle ?? 'Low / Ambient Sounds (Low Intensity)';
    }
  }
}
