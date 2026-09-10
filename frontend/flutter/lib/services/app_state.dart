import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import 'environment_manager.dart';
import 'indoor_location_repository.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile.defaultProfile();
  EnvironmentType _environmentMode = EnvironmentType.indoor;
  bool _isListening = true;
  SoundLabel? _lastDetectedSound;
  double? _lastDetectedConfidence;
  final List<SoundEvent> _history = [];
  final IndoorLocationRepository _indoorLocationRepository =
      IndoorLocationRepository();
  final EnvironmentManager _environmentManager = EnvironmentManager();
  List<SavedIndoorLocation> _indoorLocations = [];

  Timer? _historyCleanupTimer;

  // 10-second timer for the detected sound display.
  // This only controls the UI display and does not
  // stop or restart the sound classification service.
  Timer? _detectionDisplayTimer;

  String _selectedSimSoundId = soundTaxonomy.first.id;
  int _currentTabIndex = 0; // 0: Home, 1: History, 2: Settings
  bool _isOnboarded = false;
  bool _isInitialized = false;
  StreamSubscription<User?>? _firebaseAuthSubscription;

  // ----------------------------------------------------------
  // Detection cooldown tracking
  // ----------------------------------------------------------
  //
  // Each sound has its own detection/output cooldown.
  //
  // Example:
  // Dog Bark  -> its own cooldown
  // Doorbell  -> its own cooldown
  // Siren     -> its own cooldown
  //
  // A detection of one sound does NOT affect another sound.
  //
  final Map<String, DateTime> _lastDetectionTimes = {};

  // ----------------------------------------------------------
  // Notification cooldown tracking
  // ----------------------------------------------------------
  //
  // Each sound has its own notification timer.
  //
  // Notification cooldown remains separate from the
  // detection/output cooldown.
  //
  final Map<String, DateTime> _lastNotificationTimes = {};

  AppState() {
    _loadFromPreferences();
    _listenToFirebaseAuth();
    _initializeEnvironmentMonitoring();
    _startHistoryCleanupTimer();
  }

  Future<void> _initializeEnvironmentMonitoring() async {
    await _environmentManager.initialize();
    _environmentManager.locationManager
        .setNativeGeofenceListener((ids, transition) async {
      if (ids.isEmpty) {
        return;
      }
      await _environmentManager.refreshFromLastKnownOrCurrent();
      notifyListeners();
    });
    await _environmentManager.locationManager.consumePendingGeofenceEvent();
    await _environmentManager.locationManager
        .syncEnabledGeofences(_indoorLocations);
    _environmentManager.addListener(() {
      notifyListeners();
    });
  }

  void _listenToFirebaseAuth() {
    _firebaseAuthSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _userProfile.id = 'guest_user';
        notifyListeners();
        return;
      }

      _userProfile.id = user.uid;

      if (user.email != null && user.email!.isNotEmpty) {
        _userProfile.email = user.email!;
      }

      if (user.displayName != null &&
          user.displayName!.isNotEmpty) {
        _userProfile.name = user.displayName!;
      }

      notifyListeners();
      saveProfileToPrefs();
    });
  }

  // Getters
  UserProfile get userProfile => _userProfile;
  bool get textEnabled => _userProfile.isTextEnabled;
  bool get iconEnabled => _userProfile.isIconEnabled;
  bool get colorEnabled => _userProfile.isColorEnabled;
  EnvironmentType get environmentMode => _environmentMode;
  bool get isListening => _isListening;
  SoundLabel? get lastDetectedSound => _lastDetectedSound;
  double? get lastDetectedConfidence => _lastDetectedConfidence;
  List<SoundEvent> get history => List.unmodifiable(_history);
  List<SavedIndoorLocation> get indoorLocations =>
      List.unmodifiable(_indoorLocations);
  EnvironmentState get currentEnvironment =>
      _environmentManager.currentEnvironment;
  SavedIndoorLocation? get activeIndoorLocation =>
      _environmentManager.activeIndoorLocation;
  String? get activeLocationId => _environmentManager.activeLocationId;
  String get selectedSimSoundId => _selectedSimSoundId;
  int get currentTabIndex => _currentTabIndex;
  bool get isOnboarded => _isOnboarded;
  bool get isInitialized => _isInitialized;

  /// Global Font Scale factor
  /// Small = 0.85, Medium = 1.0, Large = 1.15
  double get fontScale {
    final size = _userProfile.textSize.toLowerCase();

    switch (size) {
      case 'small':
        return 0.85;

      case 'large':
        return 1.15;

      case 'medium':
      default:
        return 1.0;
    }
  }

  /// Global App Locale
  /// English: 'en', Hindi: 'hi', Kannada: 'kn'
  Locale get currentLocale {
    final lang = _userProfile.language.toLowerCase();

    switch (lang) {
      case 'hindi':
      case 'hi':
        return const Locale('hi');

      case 'kannada':
      case 'kn':
        return const Locale('kn');

      case 'english':
      case 'en':
      default:
        return const Locale('en');
    }
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore sound history using the ORIGINAL timestamps.
      final savedHistory =
          prefs.getStringList('sound_history') ?? [];

      _history.clear();

      for (final item in savedHistory) {
        try {
          final event = SoundEvent.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          );

          final oneHourAgo =
              DateTime.now().subtract(
            const Duration(hours: 1),
          );

          if (!event.timestamp.isBefore(oneHourAgo)) {
            _history.add(event);
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              'Failed to restore history event: $e',
            );
          }
        }
      }

      _history.sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );

      // Rewrite storage so expired/corrupt entries are removed.
      await _saveHistory();

      _isListening =
          prefs.getBool('microphone_enabled') ?? true;

      _isOnboarded =
          prefs.getBool('soundsee_onboarded') ?? false;

      final savedName =
          prefs.getString('user_name');

      final savedPhone =
          prefs.getString('user_phone');

      final savedEmail =
          prefs.getString('user_email');

      final savedAge =
          prefs.getInt('user_age');

      final savedEmName =
          prefs.getString('user_em_name');

      final savedEmPhone =
          prefs.getString('user_em_phone');

      final savedLang =
          prefs.getString('user_language');

      final savedFontSize =
          prefs.getString('user_font_size');

      final isHighContrast =
          prefs.getBool('high_contrast') ?? false;

      final gpsAutoDetect =
          prefs.getBool('gps_auto_detect') ?? true;

      final outdoorOverride =
          prefs.getBool('outdoor_mode') ?? false;

      final muteLow =
          prefs.getBool('mute_low_alerts') ?? false;

      final muteMedium =
          prefs.getBool('mute_medium_alerts') ?? false;

      final outputPrefs =
          prefs.getStringList('output_prefs');

      if (savedName != null &&
          savedName.isNotEmpty) {
        _userProfile.name = savedName;
      }

      if (savedPhone != null &&
          savedPhone.isNotEmpty) {
        _userProfile.phone = savedPhone;
      }

      if (savedEmail != null) {
        _userProfile.email = savedEmail;
      }

      if (savedAge != null) {
        _userProfile.age = savedAge;
      }

      if (savedEmName != null) {
        _userProfile.emergencyContactName =
            savedEmName;
      }

      if (savedEmPhone != null) {
        _userProfile.emergencyContactPhone =
            savedEmPhone;
      }

      if (savedLang != null) {
        _userProfile.language = savedLang;
      }

      if (savedFontSize != null) {
        _userProfile.textSize = savedFontSize;
      }

      if (outputPrefs != null &&
          outputPrefs.isNotEmpty) {
        _userProfile.outputPreferences =
            outputPrefs;
      }

      _userProfile.highContrast = isHighContrast;
      _userProfile.gpsAutoDetect = gpsAutoDetect;
      _userProfile.muteLowAlerts = muteLow;
      _userProfile.muteMediumAlerts = muteMedium;
      _indoorLocations = await _indoorLocationRepository.getAllLocations();

      if (outdoorOverride) {
        _environmentMode =
            EnvironmentType.outdoor;
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error loading preferences: $e',
        );
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> saveProfileToPrefs() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'user_name',
        _userProfile.name,
      );

      await prefs.setString(
        'user_phone',
        _userProfile.phone,
      );

      await prefs.setString(
        'user_email',
        _userProfile.email,
      );

      await prefs.setInt(
        'user_age',
        _userProfile.age,
      );

      if (_userProfile.emergencyContactName != null) {
        await prefs.setString(

          'user_em_name',
          _userProfile.emergencyContactName!,
        );

      }

      if (_userProfile.emergencyContactPhone != null) {
        await prefs.setString(

          'user_em_phone',
          _userProfile.emergencyContactPhone!,
        );
      }

      await prefs.setString(
        'user_language',
        _userProfile.language,
      );

      await prefs.setString(
        'user_font_size',
        _userProfile.textSize,
      );

      await prefs.setStringList(
        'output_prefs',
        _userProfile.outputPreferences,
      );

      await prefs.setBool(
        'high_contrast',
        _userProfile.highContrast,
      );

      await prefs.setBool(
        'gps_auto_detect',
        _userProfile.gpsAutoDetect,
      );

      await prefs.setBool(
        'mute_low_alerts',
        _userProfile.muteLowAlerts,
      );

      await prefs.setBool(
        'mute_medium_alerts',
        _userProfile.muteMediumAlerts,
      );

      await prefs.setBool(
        'outdoor_mode',
        _environmentMode ==
            EnvironmentType.outdoor,
      );

    } catch (e) {
      if (kDebugMode) {
        print(
          'Error saving profile: $e',
        );
      }
    }
  }

  Future<void> completeOnboarding({
    UserProfile? profile,
  }) async {
    if (profile != null) {
      _userProfile = profile;
    }

    _isOnboarded = true;

    notifyListeners();

    await saveProfileToPrefs();

    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'soundsee_onboarded',
        true,
      );
    } catch (_) {}
  }



  Future<void> resetOnboarding() async {
    _isOnboarded = false;

    notifyListeners();

    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        'soundsee_onboarded',
        false,
      );
    } catch (_) {}
  }


  Future<void> refreshIndoorLocations() async {
    _indoorLocations = await _indoorLocationRepository.getAllLocations();
    await _environmentManager.locationManager
        .syncEnabledGeofences(_indoorLocations);
    notifyListeners();
  }

  Future<void> refreshEnvironmentFromLocation() async {
    final position =
        await _environmentManager.locationManager.resolveCurrentPosition();
    if (position != null) {
      await _environmentManager.updateFromPosition(position);
    }
    notifyListeners();
  }

  Future<void> addIndoorLocation(SavedIndoorLocation location) async {
    await _indoorLocationRepository.addLocation(location);
    await refreshIndoorLocations();
  }

  Future<void> updateIndoorLocation(SavedIndoorLocation location) async {
    await _indoorLocationRepository.updateLocation(location);
    await refreshIndoorLocations();
  }

  Future<void> deleteIndoorLocation(String id) async {
    await _indoorLocationRepository.deleteLocation(id);
    await refreshIndoorLocations();
  }

  Future<void> setIndoorLocationEnabled(String id, bool enabled) async {
    await _indoorLocationRepository.setLocationEnabled(id, enabled);
    await refreshIndoorLocations();
  }

  void addSavedLocation(SavedLocation location) {
    _userProfile.savedLocations = [..._userProfile.savedLocations, location];

    notifyListeners();
  }

  void removeSavedLocation(String id) {
    _userProfile.savedLocations =
        _userProfile.savedLocations
            .where((l) => l.id != id)
            .toList();

    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> toggleListening() async {
    _isListening = !_isListening;

    if (!_isListening) {
      _lastDetectedSound = null;
      _lastDetectedConfidence = null;
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'microphone_enabled',
      _isListening,
    );

    notifyListeners();
  }

  void setEnvironmentMode(
    EnvironmentType mode,
  ) {
    _environmentMode = mode;
    notifyListeners();
  }

  void setSimSoundId(String id) {
    _selectedSimSoundId = id;
    notifyListeners();
  }

  // ==========================================================
  // SOUND DETECTION + HISTORY + NOTIFICATION COOLDOWN
  // ==========================================================

  void triggerSoundEvent(
    SoundLabel sound, [
    double? confidence,
  ]) {
    // --------------------------------------------------------
    // Determine cooldown for this sound.
    //
    // These values control the complete confirmed-sound
    // output cooldown:
    //
    // Low      -> 5 minutes
    // Medium   -> 3 minutes
    // High     -> 2 minutes
    // Critical -> 1 minute
    // --------------------------------------------------------

    final Duration cooldown;

    switch (sound.severity) {
      case PriorityLevel.low:
        cooldown =
            const Duration(minutes: 5);
        break;

      case PriorityLevel.medium:
        cooldown =
            const Duration(minutes: 3);
        break;

      case PriorityLevel.high:
        cooldown =
            const Duration(minutes: 2);
        break;

      case PriorityLevel.critical:
        cooldown =
            const Duration(minutes: 1);
        break;
    }

    final now = DateTime.now();

    // --------------------------------------------------------
    // DETECTION / OUTPUT COOLDOWN
    // --------------------------------------------------------
    //
    // This is checked BEFORE updating the main-screen output.
    //
    // If the same sound is still within its cooldown:
    // - Do NOT show it on the main screen.
    // - Do NOT restart the 10-second display timer.
    // - Do NOT add it to History.
    // - Do NOT send a notification.
    //
    // Different sounds have independent cooldowns.
    // The classifier itself continues listening normally.
    // --------------------------------------------------------

    final lastDetection =
        _lastDetectionTimes[sound.id];

    if (lastDetection != null) {
      final elapsed =
          now.difference(lastDetection);

      if (elapsed < cooldown) {
        if (kDebugMode) {
          final remaining =
              cooldown - elapsed;

          print(
            'Detection suppressed for '
            '${sound.name}. '
            'Cooldown remaining: '
            '${remaining.inMinutes}m '
            '${remaining.inSeconds % 60}s',
          );
        }

        return;
      }
    }

    // This sound is allowed through the detection cooldown.
    _lastDetectionTimes[sound.id] = now;

    // --------------------------------------------------------
    // MAIN DETECTION OUTPUT
    // --------------------------------------------------------

    _lastDetectedSound = sound;
    _lastDetectedConfidence = confidence;
    _isListening = true;



    _detectionDisplayTimer?.cancel();

    _detectionDisplayTimer = Timer(
      const Duration(seconds: 10),
      () {
        _lastDetectedSound = null;
        _lastDetectedConfidence = null;
        _detectionDisplayTimer = null;
        notifyListeners();
      },
    );

    // --------------------------------------------------------
    // Check mute rules
    // --------------------------------------------------------

    if (sound.severity == PriorityLevel.low &&
        _userProfile.muteLowAlerts) {
      notifyListeners();
      return;
    }

    if (sound.severity == PriorityLevel.medium &&
        _userProfile.muteMediumAlerts) {
      notifyListeners();
      return;
    }

    // --------------------------------------------------------
    // HISTORY COOLDOWN
    // --------------------------------------------------------
    //
    // The detection/output cooldown above already prevents
    // repeated confirmed detections from reaching this point.
    //
    // This History check is intentionally retained as an
    // additional safeguard for persisted History entries.
    // --------------------------------------------------------

    SoundEvent? lastHistoryEvent;

    for (final event in _history) {
      if (event.soundId == sound.id) {
        lastHistoryEvent = event;
        break;
      }
    }

    bool historySuppressed = false;

    if (lastHistoryEvent != null) {
      final elapsed =
          now.difference(lastHistoryEvent.timestamp);

      if (elapsed < cooldown) {
        historySuppressed = true;

        if (kDebugMode) {
          final remaining =
              cooldown - elapsed;

          print(
            'History suppressed for '
            '${sound.name}. '
            'Cooldown remaining: '
            '${remaining.inMinutes}m '
            '${remaining.inSeconds % 60}s',
          );
        }
      }
    }

    // --------------------------------------------------------
    // Add detection to History ONLY if its cooldown expired.
    // --------------------------------------------------------

    if (!historySuppressed) {
      final newEvent = SoundEvent(
        id:
            'evt_${DateTime.now().millisecondsSinceEpoch}',
        soundId: sound.id,
        userId: _userProfile.id,
        label: sound.name,
        severity: sound.severity,
        mode: sound.environment,
        timestamp: now,
      );

      _history.insert(0, newEvent);

      if (kDebugMode) {
        print(
          'History entry added for '
          '${sound.name}. '
          'Cooldown: '
          '${cooldown.inMinutes} minutes.',
        );
      }
    }

    // --------------------------------------------------------
    // Keep only sounds detected within the
    // last 1 hour.
    // --------------------------------------------------------

    final oneHourAgo =
        DateTime.now().subtract(
      const Duration(hours: 1),
    );

    _history.removeWhere(
      (event) =>
          event.timestamp.isBefore(oneHourAgo),
    );

    _saveHistory();

    notifyListeners();

    // --------------------------------------------------------
    // NOTIFICATION COOLDOWN
    // --------------------------------------------------------
    //
    // Notification cooldown remains independently tracked.
    // The output-level cooldown above already prevents the
    // same sound from reaching this section while cooling down.
    // --------------------------------------------------------

    final lastNotification =
        _lastNotificationTimes[sound.id];

    if (lastNotification != null) {
      final elapsed =
          now.difference(lastNotification);

      if (elapsed < cooldown) {
        if (kDebugMode) {
          final remaining =
              cooldown - elapsed;

          print(
            'Notification suppressed for '
            '${sound.name}. '
            'Cooldown remaining: '
            '${remaining.inMinutes}m '
            '${remaining.inSeconds % 60}s',
          );
        }

        return;
      }
    }

    // --------------------------------------------------------
    // Notification is allowed
    // --------------------------------------------------------

    _lastNotificationTimes[sound.id] =
        now;

    if (kDebugMode) {
      print(
        'Notification allowed for '
        '${sound.name}. '
        'Priority: ${sound.severity.name}. '
        'Cooldown: '
        '${cooldown.inMinutes} minutes.',
      );
    }

    NotificationService.instance.showSoundAlert(
      sound,
      textEnabled:
          _userProfile.isTextEnabled,
      iconEnabled:
          _userProfile.isIconEnabled,
      colorEnabled:
          _userProfile.isColorEnabled,
    );
  }

  /// Toggles an output preference
  /// ('text', 'icon', 'color') ensuring that
  /// at least one of Text or Icon remains active.
  ///
  /// Returns false if the toggle was blocked
  /// by the rule, true if successfully changed.
  bool toggleOutputPreference(String pref) {
    final list =
        List<String>.from(
      _userProfile.outputPreferences,
    );

    if (list.contains(pref)) {
      if (pref == 'text' &&
          !list.contains('icon')) {
        return false;
      }

      if (pref == 'icon' &&
          !list.contains('text')) {
        return false;
      }

      list.remove(pref);
    } else {
      list.add(pref);
    }

    _userProfile.outputPreferences =
        list;

    notifyListeners();

    saveProfileToPrefs();

    return true;
  }

  void clearDetectedSound() {
    _detectionDisplayTimer?.cancel();
    _detectionDisplayTimer = null;

    _lastDetectedSound = null;
    _lastDetectedConfidence = null;
    notifyListeners();
  }

  void _startHistoryCleanupTimer() {
    _historyCleanupTimer?.cancel();

    _historyCleanupTimer =
        Timer.periodic(
      const Duration(minutes: 1),
      (_) => _removeExpiredHistory(),
    );
  }

  void _removeExpiredHistory() {
    final oneHourAgo =
        DateTime.now().subtract(
      const Duration(hours: 1),
    );

    final previousLength =
        _history.length;

    _history.removeWhere(
      (event) =>
          event.timestamp.isBefore(
        oneHourAgo,
      ),
    );

    if (_history.length !=
        previousLength) {
      _saveHistory();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    final encodedHistory =
        _history
            .map(
              (event) =>
                  jsonEncode(event.toJson()),
            )
            .toList();

    await prefs.setStringList(
      'sound_history',
      encodedHistory,
    );
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void updateProfile(
    UserProfile updated,
  ) {
    _userProfile = updated;

    notifyListeners();

    saveProfileToPrefs();
  }

  void toggleHighContrast() {
    _userProfile.highContrast =
        !_userProfile.highContrast;

    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) {
      prefs.setBool(
        'high_contrast',
        _userProfile.highContrast,
      );
    });
  }

  void setFontScale(String size) {
    _userProfile.textSize =
        size.toLowerCase();

    notifyListeners();

    saveProfileToPrefs();
  }

  void setLanguage(String lang) {
    _userProfile.language = lang;

    notifyListeners();

    saveProfileToPrefs();
  }

  void setMuteLowAlerts(
    bool value,
  ) {
    _userProfile.muteLowAlerts =
        value;

    notifyListeners();

    saveProfileToPrefs();
  }

  void setMuteMediumAlerts(
    bool value,
  ) {
    _userProfile.muteMediumAlerts =
        value;

    notifyListeners();

    saveProfileToPrefs();
  }

  @override
  void dispose() {
    _historyCleanupTimer?.cancel();
    _detectionDisplayTimer?.cancel();
    _firebaseAuthSubscription?.cancel();
    super.dispose();
  }
}