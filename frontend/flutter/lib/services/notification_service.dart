import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';
import 'haptic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sound_taxonomy.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

/// Central Notification Service managing System-Level Alerts & Full-Screen Intent Delivery
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Global navigator key seam for handling deep links from notifications
  GlobalKey<NavigatorState>? navigatorKey;

  // Channel IDs
  static const String criticalChannelId = 'sound_alerts_critical';
  static const String standardChannelId = 'sound_alerts_standard';

  /// Initialize notification plugin, channel configurations, and payload listeners
  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    if (_isInitialized) return;
    navigatorKey = navKey;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    await _createNotificationChannels();
    _isInitialized = true;
  }

  /// Create dedicated Android notification channels (Critical vs Standard)
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 1. Critical Channel with Max Importance, Sound + Vibration, Alarm category
      final criticalVibrationPattern =
          Int64List.fromList([0, 250, 50, 250, 50, 250, 50, 250]);
      final criticalChannel = AndroidNotificationChannel(
        criticalChannelId,
        'Critical Sound Alerts',
        description:
            'Full-screen intent alerts for high-priority and emergency acoustic events.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: criticalVibrationPattern,
        showBadge: true,
      );

      // 2. Standard Channel for Medium/Low ambient sounds (Heads-up notification)
      final standardChannel = const AndroidNotificationChannel(
        standardChannelId,
        'Standard Sound Alerts',
        description: 'Heads-up notifications for ambient and routine sounds.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(criticalChannel);
      await androidPlugin.createNotificationChannel(standardChannel);

      // Request notification permissions for Android 13+ (POST_NOTIFICATIONS)
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Request runtime notification permissions (Android 13+ POST_NOTIFICATIONS & iOS)
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (_) {}
        return granted ?? false;
      }

      final iOSPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final granted = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      return false;
    }
  }

  /// Trigger system-level sound alert
  Future<void> showSoundAlert(
    SoundLabel sound, {
    String? customTitle,
    String? customBody,
    bool textEnabled = true,
    bool iconEnabled = true,
    bool colorEnabled = true,
    bool isMuted = false,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      // Use the same language selected in the app for system notifications
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage =
          (prefs.getString('user_language') ?? 'English').toLowerCase();

      final String langCode;
      switch (savedLanguage) {
        case 'hindi':
        case 'hi':
          langCode = 'hi';
          break;
        case 'kannada':
        case 'kn':
          langCode = 'kn';
          break;
        default:
          langCode = 'en';
      }

      final localizedSoundName =
          getLocalizedSoundName(sound.id, langCode: langCode);

      final l10n = lookupAppLocalizations(Locale(langCode));
      ByteArrayAndroidBitmap? notificationImage;

      if (sound.imagePath.isNotEmpty && sound.imagePath.endsWith('.png')) {
        try {
          final imageData = await rootBundle.load(sound.imagePath);

          notificationImage = ByteArrayAndroidBitmap(
            imageData.buffer.asUint8List(),
          );
        } catch (e) {
          if (kDebugMode) {
            print('Could not load notification image: $e');
          }
        }
      }

      final isCriticalOrHigh = sound.severity == PriorityLevel.critical ||
          sound.severity == PriorityLevel.high;

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Determine title and body based on textEnabled preference
      final soundDetectedText = switch (langCode) {
        'hi' => 'ध्वनि पहचानी गई',
        'kn' => 'ಧ್ವನಿ ಪತ್ತೆಯಾಗಿದೆ',
        _ => 'Sound Detected',
      };

      final alertTriggeredText = switch (langCode) {
        'hi' => 'अलर्ट सक्रिय हुआ',
        'kn' => 'ಎಚ್ಚರಿಕೆ ಸಕ್ರಿಯವಾಗಿದೆ',
        _ => 'Alert Triggered',
      };

      final title = customTitle ??
          (textEnabled
              ? '$soundDetectedText: $localizedSoundName'
              : (iconEnabled ? soundDetectedText : alertTriggeredText));
      final localizedPriority = switch (sound.severity) {
        PriorityLevel.critical => l10n.priorityCritical,
        PriorityLevel.high => l10n.priorityHigh,
        PriorityLevel.medium => l10n.priorityMedium,
        PriorityLevel.low => l10n.priorityLow,
      };

      final localizedMode = sound.environment == EnvironmentType.indoor
          ? l10n.indoorMode
          : l10n.outdoorMode;

      final body = customBody ??
          (textEnabled
              ? '${l10n.priorityPrefix}: $localizedPriority • $localizedMode'
              : '${l10n.priorityPrefix}: $localizedPriority');

      // Trigger service/isolate level physical tactile vibration immediately
      await _triggerTactileVibration(sound.severity, isMuted: isMuted);

      // Payload for deep linking to the Alert screen
      final payload = jsonEncode({
        'soundId': sound.id,
        'soundName': sound.name,
        'severity': sound.severity.name,
        'environment': sound.environment.name,
        'category': sound.category,
        'imagePath': sound.imagePath,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Color styling: if colorEnabled is false, suppress colorization
      final Color? alertColor = colorEnabled
          ? (sound.severity == PriorityLevel.critical
              ? const Color(0xFFEF4444)
              : sound.severity == PriorityLevel.high
                  ? const Color(0xFFF97316)
                  : sound.severity == PriorityLevel.medium
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF10B981))
          : null;

      if (isCriticalOrHigh) {
        // FULL-SCREEN INTENT NOTIFICATION (Critical/High)
        final androidDetails = AndroidNotificationDetails(
          criticalChannelId,
          'Critical Sound Alerts',
          channelDescription:
              'Full-screen takeover intent for critical acoustic emergencies',
          largeIcon: notificationImage,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: false,
          autoCancel: true,
          color: alertColor,
          colorized: colorEnabled && alertColor != null,
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'action_dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'action_snooze',
              'Snooze (2m)',
              cancelNotification: true,
            ),
          ],
        );

        final darwinDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        );

        final details = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        );

        await _notificationsPlugin.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      } else {
        // HEADS-UP STANDARD NOTIFICATION (Medium/Low)
        final androidDetails = AndroidNotificationDetails(
          standardChannelId,
          'Standard Sound Alerts',
          channelDescription: 'Standard notification for moderate sound levels',
          largeIcon: notificationImage,
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: false,
          category: AndroidNotificationCategory.status,
          visibility: NotificationVisibility.public,
          autoCancel: true,
          color: alertColor,
          colorized: colorEnabled && alertColor != null,
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'action_dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
          ],
        );

        final darwinDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        final details = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        );

        await _notificationsPlugin.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing system notification: $e');
      }
    }
  }

  /// Trigger tactile haptic vibration at the service/isolate level
  Future<void> _triggerTactileVibration(PriorityLevel severity,
      {bool isMuted = false}) async {
    await HapticService.triggerVibration(severity, isMuted: isMuted);
  }

  /// Handle notification interaction (tap, action button)
  void _handleNotificationResponse(NotificationResponse response) async {
    if (response.actionId == 'action_dismiss') {
      return;
    }

    if (response.actionId == 'action_snooze') {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        'snoozed_until',
        DateTime.now()
            .add(const Duration(minutes: 2))
            .millisecondsSinceEpoch,
      );

      if (kDebugMode) {
        print('Sound alerts snoozed for 2 minutes.');
      }

      return;
    }

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        final sound = SoundLabel.fromJson(data);

        navigatorKey?.currentState?.pushNamed(
          '/alert',
          arguments: sound,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error handling notification payload: $e');
        }
      }
    }
  }

  /// Cancel all active notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

/// Top-level background notification response handler (required by flutter_local_notifications)
@pragma('vm:entry-point')
void _handleBackgroundNotificationResponse(NotificationResponse response) {
  // Handle background actions such as dismiss / snooze
  if (kDebugMode) {
    print('Background notification response: ${response.actionId}');
  }
}
