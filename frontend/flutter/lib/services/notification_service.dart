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

  static final NotificationService instance =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Global navigator key seam for handling deep links from notifications
  GlobalKey<NavigatorState>? navigatorKey;

  // Channel IDs
  static const String criticalChannelId = 'sound_alerts_critical';
  static const String standardChannelId = 'sound_alerts_standard';

  /// Initialize notification plugin, channel configurations, and payload listeners
  Future<void> initialize({
    GlobalKey<NavigatorState>? navKey,
  }) async {
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
      // Critical Channel with Max Importance, Sound + Vibration, Alarm category
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

      // Standard Channel for Medium/Low ambient sounds
      const standardChannel = AndroidNotificationChannel(
        standardChannelId,
        'Standard Sound Alerts',
        description:
            'Heads-up notifications for ambient and routine sounds.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(
        criticalChannel,
      );

      await androidPlugin.createNotificationChannel(
        standardChannel,
      );

      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Request runtime notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted =
            await androidPlugin.requestNotificationsPermission();

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
        print(
          'Error requesting notification permissions: $e',
        );
      }

      return false;
    }
  }

  /// Trigger system-level sound alert.
  ///
  /// [mode] is the environment in which the sound was detected.
  /// The sound's priority is calculated from that mode.
  Future<void> showSoundAlert(
    SoundLabel sound, {
    required EnvironmentType mode,
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

      // ---------------------------------------------------------------
      // Determine priority from the actual detection environment
      // ---------------------------------------------------------------
      final currentPriority = sound.getPriority(mode);

      // ---------------------------------------------------------------
      // Determine selected language
      // ---------------------------------------------------------------
      final prefs = await SharedPreferences.getInstance();

      final savedLanguage =
          (prefs.getString('user_language') ?? 'English')
              .toLowerCase();

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

      // ---------------------------------------------------------------
      // Localized sound name
      //
      // NotificationService does not have a reliable BuildContext,
      // so use the same translation table directly.
      // ---------------------------------------------------------------
      final localizedSoundName =
          soundClassTranslations[langCode]?[sound.id] ??
              soundClassTranslations['en']?[sound.id] ??
              sound.name;

      // ---------------------------------------------------------------
      // Localized strings
      // ---------------------------------------------------------------
      final l10n = lookupAppLocalizations(
        Locale(langCode),
      );

      ByteArrayAndroidBitmap? notificationImage;

      if (sound.imagePath.isNotEmpty &&
          sound.imagePath.endsWith('.png')) {
        try {
          final imageData =
              await rootBundle.load(sound.imagePath);

          notificationImage = ByteArrayAndroidBitmap(
            imageData.buffer.asUint8List(),
          );
        } catch (e) {
          if (kDebugMode) {
            print(
              'Could not load notification image: $e',
            );
          }
        }
      }

      final BigPictureStyleInformation? bigPictureStyle =
          notificationImage != null
              ? BigPictureStyleInformation(
                  notificationImage,
                  largeIcon: notificationImage,
                  hideExpandedLargeIcon: false,
                )
              : null;

      // ---------------------------------------------------------------
      // Critical / High notification decision
      // ---------------------------------------------------------------
      final isCriticalOrHigh =
          currentPriority == PriorityLevel.critical ||
              currentPriority == PriorityLevel.high;

      final id =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // ---------------------------------------------------------------
      // Notification title
      // ---------------------------------------------------------------
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
              : (iconEnabled
                  ? soundDetectedText
                  : alertTriggeredText));

      // ---------------------------------------------------------------
      // Localized priority
      // ---------------------------------------------------------------
      final localizedPriority = switch (currentPriority) {
        PriorityLevel.critical => l10n.priorityCritical,
        PriorityLevel.high => l10n.priorityHigh,
        PriorityLevel.medium => l10n.priorityMedium,
        PriorityLevel.low => l10n.priorityLow,
      };

      // ---------------------------------------------------------------
      // Localized environment
      // ---------------------------------------------------------------
      final localizedMode =
          mode == EnvironmentType.indoor
              ? l10n.indoorMode
              : l10n.outdoorMode;

      final body = customBody ??
          (textEnabled
              ? '${l10n.priorityPrefix}: '
                  '$localizedPriority • $localizedMode'
              : '${l10n.priorityPrefix}: '
                  '$localizedPriority');

      // ---------------------------------------------------------------
      // Trigger physical haptic vibration using mode-specific priority
      // ---------------------------------------------------------------
      await _triggerTactileVibration(
        currentPriority,
        isMuted: isMuted,
      );

      // ---------------------------------------------------------------
      // Payload for deep linking to Alert screen
      // ---------------------------------------------------------------
      final payload = jsonEncode({
        'soundId': sound.id,
        'soundName': sound.name,
        'severity': currentPriority.name,
        'indoorSeverity': sound.indoorSeverity.name,
        'outdoorSeverity': sound.outdoorSeverity.name,
        'environment': mode.name,
        'category': sound.category,
        'imagePath': sound.imagePath,
        'timestamp':
            DateTime.now().millisecondsSinceEpoch,
      });

      // ---------------------------------------------------------------
      // Color styling based on current mode priority
      // ---------------------------------------------------------------
      final Color? alertColor = colorEnabled
          ? (currentPriority == PriorityLevel.critical
              ? const Color(0xFFEF4444)
              : currentPriority == PriorityLevel.high
                  ? const Color(0xFFF97316)
                  : currentPriority == PriorityLevel.medium
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF10B981))
          : null;

      // ===============================================================
      // CRITICAL / HIGH
      // ===============================================================
      if (isCriticalOrHigh) {
        final androidDetails =
            AndroidNotificationDetails(
          criticalChannelId,
          'Critical Sound Alerts',
          channelDescription:
              'Full-screen takeover intent for critical acoustic emergencies',
          largeIcon: notificationImage,
          styleInformation: bigPictureStyle,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: false,
          autoCancel: true,
          color: alertColor,
          colorized:
              colorEnabled && alertColor != null,
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

        const darwinDetails =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel:
              InterruptionLevel.critical,
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

      // ===============================================================
      // MEDIUM / LOW
      // ===============================================================
      else {
        final androidDetails =
            AndroidNotificationDetails(
          standardChannelId,
          'Standard Sound Alerts',
          channelDescription:
              'Standard notification for moderate sound levels',
          largeIcon: notificationImage,
          styleInformation: bigPictureStyle,
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: false,
          category:
              AndroidNotificationCategory.status,
          visibility:
              NotificationVisibility.public,
          autoCancel: true,
          color: alertColor,
          colorized:
              colorEnabled && alertColor != null,
          actions: const <AndroidNotificationAction>[
            AndroidNotificationAction(
              'action_dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
          ],
        );

        const darwinDetails =
            DarwinNotificationDetails(
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
        print(
          'Error showing system notification: $e',
        );
      }
    }
  }

  /// Trigger tactile haptic vibration at the service/isolate level
  Future<void> _triggerTactileVibration(
    PriorityLevel severity, {
    bool isMuted = false,
  }) async {
    await HapticService.triggerVibration(
      severity,
      isMuted: isMuted,
    );
  }

  /// Handle notification interaction
  void _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId == 'action_dismiss') {
      return;
    }

    if (response.actionId == 'action_snooze') {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setInt(
        'snoozed_until',
        DateTime.now()
            .add(const Duration(minutes: 2))
            .millisecondsSinceEpoch,
      );

      if (kDebugMode) {
        print(
          'Sound alerts snoozed for 2 minutes.',
        );
      }

      return;
    }

    if (response.payload != null &&
        response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            jsonDecode(response.payload!);

        final sound =
            SoundLabel.fromJson(data);

        navigatorKey?.currentState?.pushNamed(
          '/alert',
          arguments: sound,
        );
      } catch (e) {
        if (kDebugMode) {
          print(
            'Error handling notification payload: $e',
          );
        }
      }
    }
  }

  /// Cancel all active notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

/// Top-level background notification response handler
@pragma('vm:entry-point')
Future<void> _handleBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  if (response.actionId == 'action_dismiss') {
    return;
  }

  if (response.actionId == 'action_snooze') {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      'snoozed_until',
      DateTime.now()
          .add(const Duration(minutes: 2))
          .millisecondsSinceEpoch,
    );

    if (kDebugMode) {
      print(
        'Sound alerts snoozed for 2 minutes.',
      );
    }
  }
}