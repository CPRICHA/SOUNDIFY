import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  UserProfile _userProfile = UserProfile.defaultProfile();
  EnvironmentType _environmentMode = EnvironmentType.indoor;
  bool _isListening = true;
  SoundLabel? _lastDetectedSound;
  final List<SoundEvent> _history = [];
  String _selectedSimSoundId = soundTaxonomy.first.id;
  int _currentTabIndex = 0; // 0: Home, 1: History, 2: Settings
  bool _isOnboarded = false;
  bool _isInitialized = false;

  AppState() {
    _loadFromPreferences();
  }

  // Getters
  UserProfile get userProfile => _userProfile;
  bool get textEnabled => _userProfile.isTextEnabled;
  bool get iconEnabled => _userProfile.isIconEnabled;
  bool get colorEnabled => _userProfile.isColorEnabled;
  EnvironmentType get environmentMode => _environmentMode;
  bool get isListening => _isListening;
  SoundLabel? get lastDetectedSound => _lastDetectedSound;
  List<SoundEvent> get history => List.unmodifiable(_history);
  String get selectedSimSoundId => _selectedSimSoundId;
  int get currentTabIndex => _currentTabIndex;
  bool get isOnboarded => _isOnboarded;
  bool get isInitialized => _isInitialized;

  /// Global Font Scale factor (Small = 0.85, Medium = 1.0, Large = 1.15)
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

  /// Global App Locale (English: 'en', Hindi: 'hi', Kannada: 'kn')
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
      _isOnboarded = prefs.getBool('soundsee_onboarded') ?? false;
      final savedName = prefs.getString('user_name');
      final savedPhone = prefs.getString('user_phone');
      final savedEmail = prefs.getString('user_email');
      final savedAge = prefs.getInt('user_age');
      final savedEmName = prefs.getString('user_em_name');
      final savedEmPhone = prefs.getString('user_em_phone');
      final savedLang = prefs.getString('user_language');
      final savedFontSize = prefs.getString('user_font_size');
      final isHighContrast = prefs.getBool('high_contrast') ?? false;
      final gpsAutoDetect = prefs.getBool('gps_auto_detect') ?? true;
      final outdoorOverride = prefs.getBool('outdoor_mode') ?? false;
      final muteLow = prefs.getBool('mute_low_alerts') ?? false;
      final muteMedium = prefs.getBool('mute_medium_alerts') ?? false;
      final outputPrefs = prefs.getStringList('output_prefs');

      if (savedName != null && savedName.isNotEmpty) {
        _userProfile.name = savedName;
      }
      if (savedPhone != null && savedPhone.isNotEmpty) {
        _userProfile.phone = savedPhone;
      }
      if (savedEmail != null) {
        _userProfile.email = savedEmail;
      }
      if (savedAge != null) {
        _userProfile.age = savedAge;
      }
      if (savedEmName != null) {
        _userProfile.emergencyContactName = savedEmName;
      }
      if (savedEmPhone != null) {
        _userProfile.emergencyContactPhone = savedEmPhone;
      }
      if (savedLang != null) {
        _userProfile.language = savedLang;
      }
      if (savedFontSize != null) {
        _userProfile.textSize = savedFontSize;
      }
      if (outputPrefs != null && outputPrefs.isNotEmpty) {
        _userProfile.outputPreferences = outputPrefs;
      }
      _userProfile.highContrast = isHighContrast;
      _userProfile.gpsAutoDetect = gpsAutoDetect;
      _userProfile.muteLowAlerts = muteLow;
      _userProfile.muteMediumAlerts = muteMedium;
      if (outdoorOverride) {
        _environmentMode = EnvironmentType.outdoor;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> saveProfileToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _userProfile.name);
      await prefs.setString('user_phone', _userProfile.phone);
      await prefs.setString('user_email', _userProfile.email);
      await prefs.setInt('user_age', _userProfile.age);
      if (_userProfile.emergencyContactName != null) {
        await prefs.setString('user_em_name', _userProfile.emergencyContactName!);
      }
      if (_userProfile.emergencyContactPhone != null) {
        await prefs.setString('user_em_phone', _userProfile.emergencyContactPhone!);
      }
      await prefs.setString('user_language', _userProfile.language);
      await prefs.setString('user_font_size', _userProfile.textSize);
      await prefs.setStringList('output_prefs', _userProfile.outputPreferences);
      await prefs.setBool('high_contrast', _userProfile.highContrast);
      await prefs.setBool('gps_auto_detect', _userProfile.gpsAutoDetect);
      await prefs.setBool('mute_low_alerts', _userProfile.muteLowAlerts);
      await prefs.setBool('mute_medium_alerts', _userProfile.muteMediumAlerts);
      await prefs.setBool('outdoor_mode', _environmentMode == EnvironmentType.outdoor);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
      }
    }
  }

  Future<void> completeOnboarding({UserProfile? profile}) async {
    if (profile != null) {
      _userProfile = profile;
    }
    _isOnboarded = true;
    notifyListeners();
    await saveProfileToPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('soundsee_onboarded', true);
    } catch (_) {}
  }

  Future<void> completeOnboardingAsGuest() async {
    _userProfile = UserProfile(
      id: 'usr_guest_demo',
      name: 'John Doe',
      age: 28,
      phone: '+1 (555) 019-2834',
      email: 'deekshakuselan23@gmail.com',
      micAccess: true,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      outputPreferences: const ['text', 'icon', 'color'],
      emergencyContactName: 'Dr. Sarah Mitchell',
      emergencyContactPhone: '+1 (555) 911-0000',
      muteLowAlerts: false,
      gpsAutoDetect: true,
      savedLocations: [
        SavedLocation(
          id: 'loc_home',
          name: 'Home',
          address: '124 Maple Street, Apt 3B',
          createdAt: DateTime.now().millisecondsSinceEpoch - 100000,
        ),
        SavedLocation(
          id: 'loc_work',
          name: 'Office',
          address: '742 Evergreen Tech Park, Tower B',
          createdAt: DateTime.now().millisecondsSinceEpoch - 50000,
        ),
      ],
      language: 'English',
      textSize: 'medium',
      highContrast: false,
    );
    await completeOnboarding();
  }

  Future<void> resetOnboarding() async {
    _isOnboarded = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('soundsee_onboarded', false);
    } catch (_) {}
  }

  void addSavedLocation(SavedLocation location) {
    _userProfile.savedLocations = [..._userProfile.savedLocations, location];
    notifyListeners();
  }

  void removeSavedLocation(String id) {
    _userProfile.savedLocations =
        _userProfile.savedLocations.where((l) => l.id != id).toList();
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleListening() {
    _isListening = !_isListening;
    if (!_isListening) {
      _lastDetectedSound = null;
    }
    notifyListeners();
  }

  void setEnvironmentMode(EnvironmentType mode) {
    _environmentMode = mode;
    notifyListeners();
  }

  void setSimSoundId(String id) {
    _selectedSimSoundId = id;
    notifyListeners();
  }

  void triggerSoundEvent(SoundLabel sound) {
    _lastDetectedSound = sound;
    _isListening = true;

    // Check mute rules
    if (sound.severity == PriorityLevel.low && _userProfile.muteLowAlerts) {
      notifyListeners();
      return;
    }
    if (sound.severity == PriorityLevel.medium && _userProfile.muteMediumAlerts) {
      notifyListeners();
      return;
    }

    final newEvent = SoundEvent(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      soundId: sound.id,
      userId: _userProfile.id,
      label: sound.name,
      severity: sound.severity,
      mode: sound.environment,
      timestamp: DateTime.now(),
    );

    _history.insert(0, newEvent);
    notifyListeners();

    // Trigger system-level alert delivery (Full-screen intent on Critical/High, heads-up on Medium/Low)
    NotificationService.instance.showSoundAlert(
      sound,
      textEnabled: _userProfile.isTextEnabled,
      iconEnabled: _userProfile.isIconEnabled,
      colorEnabled: _userProfile.isColorEnabled,
    );
  }

  /// Toggles an output preference ('text', 'icon', 'color') ensuring that at least one of Text or Icon remains active.
  /// Returns false if the toggle was blocked by the rule, true if successfully changed.
  bool toggleOutputPreference(String pref) {
    final list = List<String>.from(_userProfile.outputPreferences);
    if (list.contains(pref)) {
      if (pref == 'text' && !list.contains('icon')) {
        return false;
      }
      if (pref == 'icon' && !list.contains('text')) {
        return false;
      }
      list.remove(pref);
    } else {
      list.add(pref);
    }
    _userProfile.outputPreferences = list;
    notifyListeners();
    saveProfileToPrefs();
    return true;
  }

  void clearDetectedSound() {
    _lastDetectedSound = null;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    _userProfile = updated;
    notifyListeners();
    saveProfileToPrefs();
  }

  void toggleHighContrast() {
    _userProfile.highContrast = !_userProfile.highContrast;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('high_contrast', _userProfile.highContrast);
    });
  }

  void setFontScale(String size) {
    _userProfile.textSize = size.toLowerCase();
    notifyListeners();
    saveProfileToPrefs();
  }

  void setLanguage(String lang) {
    _userProfile.language = lang;
    notifyListeners();
    saveProfileToPrefs();
  }

  void setMuteLowAlerts(bool value) {
    _userProfile.muteLowAlerts = value;
    notifyListeners();
    saveProfileToPrefs();
  }

  void setMuteMediumAlerts(bool value) {
    _userProfile.muteMediumAlerts = value;
    notifyListeners();
    saveProfileToPrefs();
  }
}
