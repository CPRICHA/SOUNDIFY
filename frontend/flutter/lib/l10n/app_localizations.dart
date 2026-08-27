import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn')
  ];

  /// The main title of the application
  ///
  /// In en, this message translates to:
  /// **'SoundSee'**
  String get appTitle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @accessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access Granted'**
  String get accessGranted;

  /// No description provided for @accessibilitySection.
  ///
  /// In en, this message translates to:
  /// **'Accessibility & High Contrast'**
  String get accessibilitySection;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Account Profile'**
  String get accountProfile;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeUpper;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @addNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Add New Location'**
  String get addNewLocation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street address or landmark'**
  String get addressHint;

  /// No description provided for @addressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 104 Willow Creek Rd, Apt 4B'**
  String get addressPlaceholder;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @alertFormats.
  ///
  /// In en, this message translates to:
  /// **'Alert Formats'**
  String get alertFormats;

  /// No description provided for @alertPreferences.
  ///
  /// In en, this message translates to:
  /// **'Alert Preferences'**
  String get alertPreferences;

  /// No description provided for @ambientSoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Cat meow, temple bell, running water, gentle rain, crowd chatter'**
  String get ambientSoundsDesc;

  /// No description provided for @ambientSoundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Low / Ambient Sounds (Low Intensity)'**
  String get ambientSoundsTitle;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SoundSee'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visual & Haptic Sound Awareness'**
  String get appSubtitle;

  /// No description provided for @atLeastOneFormat.
  ///
  /// In en, this message translates to:
  /// **'At least one of Text or Icon must be selected.'**
  String get atLeastOneFormat;

  /// No description provided for @backgroundChannels.
  ///
  /// In en, this message translates to:
  /// **'Background & System Channels'**
  String get backgroundChannels;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeAlert.
  ///
  /// In en, this message translates to:
  /// **'Close Alert'**
  String get closeAlert;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Sarah Mitchell'**
  String get contactNameHint;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @contactPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +91 98765 43210'**
  String get contactPhoneHint;

  /// No description provided for @continuousEmergencyVibration.
  ///
  /// In en, this message translates to:
  /// **'Continuous Emergency Vibration'**
  String get continuousEmergencyVibration;

  /// No description provided for @createProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide basic details to customize emergency triggers.'**
  String get createProfileDesc;

  /// No description provided for @createProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfileTitle;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @criticalAlertHeader.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL EMERGENCY ALERT'**
  String get criticalAlertHeader;

  /// No description provided for @criticalEmergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL EMERGENCY ALERT'**
  String get criticalEmergencyAlert;

  /// No description provided for @criticalThreatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Fire alarms, smoke alarms, industrial gas leaks, sirens, glass breaks'**
  String get criticalThreatsDesc;

  /// No description provided for @criticalThreatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Critical Threats (High Intensity)'**
  String get criticalThreatsTitle;

  /// No description provided for @deleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLocation;

  /// No description provided for @detectionBehavior.
  ///
  /// In en, this message translates to:
  /// **'Detection Behavior'**
  String get detectionBehavior;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @dispatchEmergencyAlert.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Emergency Alert'**
  String get dispatchEmergencyAlert;

  /// No description provided for @dispatchedSystemAlert.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS alert dispatched to contact.'**
  String get dispatchedSystemAlert;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emergencyAlertDesc.
  ///
  /// In en, this message translates to:
  /// **'Urgent acoustic safety event detected and notification transmitted to'**
  String get emergencyAlertDesc;

  /// No description provided for @emergencyAlertSent.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert Sent'**
  String get emergencyAlertSent;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContactTitle;

  /// No description provided for @errAtLeastOneFormat.
  ///
  /// In en, this message translates to:
  /// **'At least one of Text or Icon must be selected.'**
  String get errAtLeastOneFormat;

  /// No description provided for @errEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Age.'**
  String get errEnterAge;

  /// No description provided for @errEnterLocationAndAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter both a Location Name and an Address.'**
  String get errEnterLocationAndAddress;

  /// No description provided for @errEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Name.'**
  String get errEnterName;

  /// No description provided for @errEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Phone number.'**
  String get errEnterPhone;

  /// No description provided for @errLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location access is required for emergency safety.'**
  String get errLocationRequired;

  /// No description provided for @errMicRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is required for sound awareness.'**
  String get errMicRequired;

  /// No description provided for @errPrivacyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Privacy Policy.'**
  String get errPrivacyRequired;

  /// No description provided for @errTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service.'**
  String get errTermsRequired;

  /// No description provided for @feedbackCatBug.
  ///
  /// In en, this message translates to:
  /// **'Bug / Defect'**
  String get feedbackCatBug;

  /// No description provided for @feedbackCatFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get feedbackCatFeature;

  /// No description provided for @feedbackCatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Feedback'**
  String get feedbackCatGeneral;

  /// No description provided for @feedbackCatSoundAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Sound Accuracy'**
  String get feedbackCatSoundAccuracy;

  /// No description provided for @feedbackCategory.
  ///
  /// In en, this message translates to:
  /// **'Feedback Category'**
  String get feedbackCategory;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts or report an unrecognized sound...'**
  String get feedbackHint;

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Help us improve on-device acoustic recognition'**
  String get feedbackPrompt;

  /// No description provided for @feedbackRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get feedbackRating;

  /// No description provided for @feedbackSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Feedback saved locally. Thank you!'**
  String get feedbackSavedSnackbar;

  /// No description provided for @feedbackStoredLocal.
  ///
  /// In en, this message translates to:
  /// **'Offline feedback stored on-device'**
  String get feedbackStoredLocal;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @formatColor.
  ///
  /// In en, this message translates to:
  /// **'Vibrant Color Bands'**
  String get formatColor;

  /// No description provided for @formatIcon.
  ///
  /// In en, this message translates to:
  /// **'Visual Icons'**
  String get formatIcon;

  /// No description provided for @formatText.
  ///
  /// In en, this message translates to:
  /// **'Text Notifications'**
  String get formatText;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullScreenIntentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts display immediately over other apps'**
  String get fullScreenIntentSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started (Sign Up)'**
  String get getStarted;

  /// No description provided for @gpsAutoDetect.
  ///
  /// In en, this message translates to:
  /// **'GPS Auto-detect'**
  String get gpsAutoDetect;

  /// No description provided for @hapticGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'SoundSee scales vibration rhythm and intensity according to threat severity.'**
  String get hapticGuideDesc;

  /// No description provided for @hapticGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'4-Tier Tactile Waveform Guide'**
  String get hapticGuideTitle;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @highAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pressure cooker whistle, baby crying, car horns, approaching vehicles, crackers'**
  String get highAlertsDesc;

  /// No description provided for @highAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'High Priority Alerts (Moderate-High Intensity)'**
  String get highAlertsTitle;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Colors'**
  String get highContrast;

  /// No description provided for @highPriorityAlert.
  ///
  /// In en, this message translates to:
  /// **'HIGH PRIORITY ALERT'**
  String get highPriorityAlert;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Detection History'**
  String get historyTitle;

  /// No description provided for @indoorMode.
  ///
  /// In en, this message translates to:
  /// **'Indoor Mode'**
  String get indoorMode;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS *'**
  String get labelAddress;

  /// No description provided for @labelAge.
  ///
  /// In en, this message translates to:
  /// **'AGE *'**
  String get labelAge;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get labelEmail;

  /// No description provided for @labelLocationName.
  ///
  /// In en, this message translates to:
  /// **'LOCATION NAME *'**
  String get labelLocationName;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'NAME *'**
  String get labelName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'PHONE *'**
  String get labelPhone;

  /// No description provided for @labelQuickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'QUICK SUGGESTIONS'**
  String get labelQuickSuggestions;

  /// No description provided for @listeningActive.
  ///
  /// In en, this message translates to:
  /// **'Listening Active'**
  String get listeningActive;

  /// No description provided for @listeningForSounds.
  ///
  /// In en, this message translates to:
  /// **'Listening for environmental sounds...'**
  String get listeningForSounds;

  /// No description provided for @listeningStatus.
  ///
  /// In en, this message translates to:
  /// **'Listening for environmental sounds...'**
  String get listeningStatus;

  /// No description provided for @locationAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables ambient GPS auto-detection to switch between Indoor & Outdoor profiles.'**
  String get locationAccessDesc;

  /// No description provided for @locationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access *'**
  String get locationAccessTitle;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationName;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Office, Parents\' House'**
  String get locationNameHint;

  /// No description provided for @locationNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Grandma\'s House, Gym, Office'**
  String get locationNamePlaceholder;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @mediumAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Doorbell, door knocks, mixer grinder, dog barks, name calls, vendors'**
  String get mediumAlertsDesc;

  /// No description provided for @mediumAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority Alerts (Medium Intensity)'**
  String get mediumAlertsTitle;

  /// No description provided for @micAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Used strictly for on-device local acoustic classification. No audio recorded or transmitted.'**
  String get micAccessDesc;

  /// No description provided for @micAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access *'**
  String get micAccessTitle;

  /// No description provided for @microphoneSampling.
  ///
  /// In en, this message translates to:
  /// **'Microphone Sampling'**
  String get microphoneSampling;

  /// No description provided for @muteLowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Mute Low Severity Sounds'**
  String get muteLowSeverity;

  /// No description provided for @muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get muted;

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @nextSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'Next: Saved Locations'**
  String get nextSavedLocations;

  /// No description provided for @nextStylePreferences.
  ///
  /// In en, this message translates to:
  /// **'Next: Style Preferences'**
  String get nextStylePreferences;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No Sound Detections Recorded'**
  String get noHistory;

  /// No description provided for @noHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Detected acoustic events and safety alerts will appear here in chronological order.'**
  String get noHistorySub;

  /// No description provided for @noRecentSounds.
  ///
  /// In en, this message translates to:
  /// **'No sounds detected recently'**
  String get noRecentSounds;

  /// No description provided for @noSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'No saved locations yet.'**
  String get noSavedLocations;

  /// No description provided for @noSoundsDetected.
  ///
  /// In en, this message translates to:
  /// **'No sounds detected yet'**
  String get noSoundsDetected;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @notifyContact.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notifyContact;

  /// No description provided for @notifyEmergency.
  ///
  /// In en, this message translates to:
  /// **'Notify Emergency Contact'**
  String get notifyEmergency;

  /// No description provided for @offlineAiSoundDetector.
  ///
  /// In en, this message translates to:
  /// **'Offline AI Sound Detector'**
  String get offlineAiSoundDetector;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @outdoorMode.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Mode'**
  String get outdoorMode;

  /// No description provided for @outdoorModeOverride.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Mode Override'**
  String get outdoorModeOverride;

  /// No description provided for @outdoorOverride.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Mode Override'**
  String get outdoorOverride;

  /// No description provided for @pausedStatus.
  ///
  /// In en, this message translates to:
  /// **'Acoustic detection paused'**
  String get pausedStatus;

  /// No description provided for @permissionsRequiredWarning.
  ///
  /// In en, this message translates to:
  /// **'Required permissions are missing'**
  String get permissionsRequiredWarning;

  /// No description provided for @permissionsVerified.
  ///
  /// In en, this message translates to:
  /// **'All permissions granted & verified'**
  String get permissionsVerified;

  /// No description provided for @personalLocationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your frequent destinations for GPS switching'**
  String get personalLocationsSubtitle;

  /// No description provided for @personalProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personalProfile;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @placeholderAddress.
  ///
  /// In en, this message translates to:
  /// **'e.g. 124 Maple Street, Apt 3B'**
  String get placeholderAddress;

  /// No description provided for @placeholderAge.
  ///
  /// In en, this message translates to:
  /// **'28'**
  String get placeholderAge;

  /// No description provided for @placeholderEmail.
  ///
  /// In en, this message translates to:
  /// **'user@sensoryreach.app'**
  String get placeholderEmail;

  /// No description provided for @placeholderLocName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Office, Gym'**
  String get placeholderLocName;

  /// No description provided for @placeholderName.
  ///
  /// In en, this message translates to:
  /// **'Accessibility User'**
  String get placeholderName;

  /// No description provided for @placeholderPhone.
  ///
  /// In en, this message translates to:
  /// **'9876543210'**
  String get placeholderPhone;

  /// No description provided for @prefColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Dynamic edge glow matching threat level'**
  String get prefColorDesc;

  /// No description provided for @prefColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrant Color bands'**
  String get prefColorTitle;

  /// No description provided for @prefIconDesc.
  ///
  /// In en, this message translates to:
  /// **'Bold pictograms of acoustic sources'**
  String get prefIconDesc;

  /// No description provided for @prefIconTitle.
  ///
  /// In en, this message translates to:
  /// **'Icon-forward cards'**
  String get prefIconTitle;

  /// No description provided for @prefPresentationDesc.
  ///
  /// In en, this message translates to:
  /// **'Select visual channels. Choose at least one format.'**
  String get prefPresentationDesc;

  /// No description provided for @prefPresentationTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert Presentation'**
  String get prefPresentationTitle;

  /// No description provided for @prefTextDesc.
  ///
  /// In en, this message translates to:
  /// **'Crisp written overlay popups'**
  String get prefTextDesc;

  /// No description provided for @prefTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Text notifications'**
  String get prefTextTitle;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityPrefix.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityPrefix;

  /// No description provided for @privacyDialogBody.
  ///
  /// In en, this message translates to:
  /// **'SoundSee operates 100% on-device. Audio streams are processed in transient buffers and immediately discarded. No audio is ever recorded, stored, or transmitted to any server.'**
  String get privacyDialogBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy *'**
  String get privacyPolicyTitle;

  /// No description provided for @pulsePatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Pulse Pattern:'**
  String get pulsePatternLabel;

  /// No description provided for @quickHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get quickHome;

  /// No description provided for @quickOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get quickOffice;

  /// No description provided for @quickParentsHouse.
  ///
  /// In en, this message translates to:
  /// **'Parents\' House'**
  String get quickParentsHouse;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Suggestions'**
  String get quickSuggestions;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate SoundSee'**
  String get rateApp;

  /// No description provided for @rateSoundSee.
  ///
  /// In en, this message translates to:
  /// **'Rate SoundSee'**
  String get rateSoundSee;

  /// No description provided for @rateSoundSeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve sound accessibility for everyone'**
  String get rateSoundSeeSubtitle;

  /// No description provided for @rateSoundSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate SoundSee Experience'**
  String get rateSoundSeeTitle;

  /// No description provided for @rateThanksPrefix.
  ///
  /// In en, this message translates to:
  /// **'Thank you for rating'**
  String get rateThanksPrefix;

  /// No description provided for @rateThanksSuffix.
  ///
  /// In en, this message translates to:
  /// **'stars!'**
  String get rateThanksSuffix;

  /// No description provided for @recentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Recent Alerts'**
  String get recentAlerts;

  /// No description provided for @recentDetections.
  ///
  /// In en, this message translates to:
  /// **'Recent Detections'**
  String get recentDetections;

  /// No description provided for @releaseVersion.
  ///
  /// In en, this message translates to:
  /// **'Release Version: 1.0.0 (On-Device Classifier)'**
  String get releaseVersion;

  /// No description provided for @requiredSafetySetting.
  ///
  /// In en, this message translates to:
  /// **'Mandatory Safety Configuration'**
  String get requiredSafetySetting;

  /// No description provided for @requiredSafetySettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Text or Icon visual output must remain enabled to ensure safety alerts are communicated.'**
  String get requiredSafetySettingDesc;

  /// No description provided for @saveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Save Feedback'**
  String get saveFeedback;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @savedLocationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stored personal address book'**
  String get savedLocationsDesc;

  /// No description provided for @savedLocationsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick Saved Places'**
  String get savedLocationsHeading;

  /// No description provided for @savedLocationsOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Add places like Home, College, or Workplace to keep addresses handy.'**
  String get savedLocationsOnboardingDesc;

  /// No description provided for @savedLocationsOptional.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations (Optional)'**
  String get savedLocationsOptional;

  /// No description provided for @savedLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocationsTitle;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Signing out will clear local cached session data. Do you wish to continue?'**
  String get signOutConfirmDesc;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out of SoundSee'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutProfile.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutProfile;

  /// No description provided for @simulateSound.
  ///
  /// In en, this message translates to:
  /// **'Simulate Sound'**
  String get simulateSound;

  /// No description provided for @skipAndFinish.
  ///
  /// In en, this message translates to:
  /// **'Skip and Finish'**
  String get skipAndFinish;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze (5m)'**
  String get snooze;

  /// No description provided for @snoozeSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Alert snoozed for 5 minutes'**
  String get snoozeSnackbar;

  /// No description provided for @soundClassification.
  ///
  /// In en, this message translates to:
  /// **'Sound Classification'**
  String get soundClassification;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @suggestGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get suggestGym;

  /// No description provided for @suggestHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get suggestHome;

  /// No description provided for @suggestOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get suggestOffice;

  /// No description provided for @suggestSchool.
  ///
  /// In en, this message translates to:
  /// **'College / School'**
  String get suggestSchool;

  /// No description provided for @systemAlert.
  ///
  /// In en, this message translates to:
  /// **'System Alert'**
  String get systemAlert;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications & Overlays'**
  String get systemNotifications;

  /// No description provided for @tactilePulsePattern.
  ///
  /// In en, this message translates to:
  /// **'Tactile Pulse Pattern Triggered'**
  String get tactilePulsePattern;

  /// No description provided for @tactilePulseTriggered.
  ///
  /// In en, this message translates to:
  /// **'Tactile Pulse Pattern Triggered'**
  String get tactilePulseTriggered;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @termsDialogBody.
  ///
  /// In en, this message translates to:
  /// **'SoundSee is an assistive sound awareness system running offline edge machine learning models. It does not replace professional emergency services.'**
  String get termsDialogBody;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service *'**
  String get termsOfServiceTitle;

  /// No description provided for @testSystemAlert.
  ///
  /// In en, this message translates to:
  /// **'Test System Alert'**
  String get testSystemAlert;

  /// No description provided for @testSystemAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Triggers a full notification simulation'**
  String get testSystemAlertSubtitle;

  /// No description provided for @testUpper.
  ///
  /// In en, this message translates to:
  /// **'TEST'**
  String get testUpper;

  /// No description provided for @testWaveform.
  ///
  /// In en, this message translates to:
  /// **'Test Waveform'**
  String get testWaveform;

  /// No description provided for @triggerDetectionEvent.
  ///
  /// In en, this message translates to:
  /// **'Trigger Detection Event'**
  String get triggerDetectionEvent;

  /// No description provided for @triggerSoundWave.
  ///
  /// In en, this message translates to:
  /// **'Trigger Sound Wave'**
  String get triggerSoundWave;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @useGuestProfile.
  ///
  /// In en, this message translates to:
  /// **'Use Guest Demo Profile'**
  String get useGuestProfile;

  /// No description provided for @userAge.
  ///
  /// In en, this message translates to:
  /// **'USER AGE'**
  String get userAge;

  /// No description provided for @verifyUpper.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verifyUpper;

  /// No description provided for @vibrationGuide.
  ///
  /// In en, this message translates to:
  /// **'Vibrations Wave Guide'**
  String get vibrationGuide;

  /// No description provided for @vibrationIntensity.
  ///
  /// In en, this message translates to:
  /// **'Vibration Intensity & Waveform'**
  String get vibrationIntensity;

  /// No description provided for @vibrationsWaveGuide.
  ///
  /// In en, this message translates to:
  /// **'Vibrations Wave Guide'**
  String get vibrationsWaveGuide;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @waveformActive.
  ///
  /// In en, this message translates to:
  /// **'Continuous Emergency Vibration Waveform Active'**
  String get waveformActive;

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert critical environmental sounds into visual patterns and smart haptic vibrations.'**
  String get welcomeDesc;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time acoustic detection, intelligent tactile feedback, and safety alerts designed for deaf & hard-of-hearing individuals.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Awareness For Everyone'**
  String get welcomeTitle;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'YOUR EMAIL'**
  String get yourEmail;

  /// No description provided for @yourPhone.
  ///
  /// In en, this message translates to:
  /// **'YOUR PHONE'**
  String get yourPhone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System Preferences & Hardware Controls'**
  String get settingsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
