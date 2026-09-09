import 'package:flutter/material.dart';
import '../models/models.dart';

const List<String> taxonomyCategories = [
  'Home Safety & Household Awareness',
  'Visitor Awareness',
  'Human Communication',
  'Emergency Vehicles',
  'Road Safety',
  'Public Safety',
  'Environmental Awareness',
];

/// Map of the 25 AIISH model sound classes translated into English, Hindi, and Kannada
const Map<String, Map<String, String>> soundClassTranslations = {
  'en': {
    'air_conditioner': 'Air Conditioner',
    'children_playing': 'Children Playing',
    'engine_idling': 'Engine Idling',
    'street_music': 'Street Music',
    'alarm_fire_smoke': 'Alarm (Fire / Smoke)',
    'glass_breaking': 'Glass Breaking',
    'pressure_cooker': 'Pressure Cooker Whistle',
    'water_running': 'Water Running',
    'microwave_beep': 'Microwave Oven Beep',
    'mixer_grinder': 'Mixer / Grinder',
    'utensils': 'Utensils',
    'doorbell': 'Doorbell',
    'door_knock': 'Door Knock',
    'baby_crying': 'Baby Crying',
    'siren_emergency': 'Siren (Ambulance/Police/Fire Brigade)',
    'train_horn': 'Train Horn',
    'vehicle_horn': 'Vehicle Horn (Car/Bike/Bus/Truck)',
    'approaching_vehicles': 'Approaching Vehicles',
    'blasts': 'Blasts',
    'fire_crackers': 'Fire Crackers',
    'construction_sounds': 'Construction Sounds',
    'dog_bark': 'Dog Bark',
    'cat_meow': 'Cat Meow',
    'temple_bell': 'Temple Bell',
    'cow_mooing': 'Cow Mooing',
  },
  'hi': {
    'air_conditioner': 'एयर कंडीशनर',
    'children_playing': 'बच्चों के खेलने की आवाज़',
    'engine_idling': 'इंजन आइडलिंग',
    'street_music': 'सड़क का संगीत',
    'alarm_fire_smoke': 'अलार्म (आग / धुआँ)',
    'glass_breaking': 'कांच टूटना',
    'pressure_cooker': 'प्रेशर कुकर की सीटी',
    'water_running': 'बहता हुआ पानी',
    'microwave_beep': 'माइक्रोवेव बीप',
    'mixer_grinder': 'मिक्सर / ग्राइंडर',
    'utensils': 'बर्तनों की आवाज़',
    'doorbell': 'डोरबेल',
    'door_knock': 'दरवाज़े की दस्तक',
    'baby_crying': 'बच्चे का रोना',
    'siren_emergency': 'आपातकालीन सायरन (एंबुलेंस/पुलिस)',
    'train_horn': 'ट्रेन का हॉर्न',
    'vehicle_horn': 'वाहन का हॉर्न',
    'approaching_vehicles': 'निकट आता वाहन',
    'blasts': 'धमाका / विस्फोट',
    'fire_crackers': 'पटाखों की आवाज़',
    'construction_sounds': 'निर्माण कार्य की आवाज़',
    'dog_bark': 'कुत्ते का भौंकना',
    'cat_meow': 'बिल्ली की म्याऊं',
    'temple_bell': 'मंदिर की घंटी',
    'cow_mooing': 'गाय का रंभाना',
  },
  'kn': {
    'air_conditioner': 'ಏರ್ ಕಂಡೀಷನರ್',
    'children_playing': 'ಮಕ್ಕಳು ಆಟವಾಡುವುದು',
    'engine_idling': 'ಎಂಜಿನ್ ಐಡ್ಲಿಂಗ್',
    'street_music': 'ಬೀದಿ ಸಂಗೀತ',
    'alarm_fire_smoke': 'ಅಲಾರಾಂ (ಬೆಂಕಿ / ಹೊಗೆ)',
    'glass_breaking': 'ಗಾಜು ಒಡೆಯುವುದು',
    'pressure_cooker': 'ಪ್ರೆಶರ್ ಕುಕ್ಕರ್ ಸೀಟಿ',
    'water_running': 'ನೀರು ಹರಿಯುವುದು',
    'microwave_beep': 'ಮೈಕ್ರೋವೇವ್ ಬೀಪ್',
    'mixer_grinder': 'ಮಿಕ್ಸರ್ / ಗ್ರೈಂಡರ್',
    'utensils': 'ಪಾತ್ರೆಗಳ ಶಬ್ದ',
    'doorbell': 'ಡೋರ್‌ಬೆಲ್',
    'door_knock': 'ಬಾಗಿಲು ತಟ್ಟುವುದು',
    'baby_crying': 'ಮಗುವಿನ ಅಳು',
    'siren_emergency': 'ತುರ್ತು ಸೈರನ್ (ಆಂಬ್ಯುಲೆನ್ಸ್/ಪೊಲೀಸ್)',
    'train_horn': 'ರೈಲು ಹಾರ್ನ್',
    'vehicle_horn': 'ವಾಹನದ ಹಾರ್ನ್',
    'approaching_vehicles': 'ಹತ್ತಿರ ಬರುತ್ತಿರುವ ವಾಹನ',
    'blasts': 'ಸ್ಫೋಟ',
    'fire_crackers': 'ಪಟಾಕಿ ಶಬ್ದ',
    'construction_sounds': 'ನಿರ್ಮಾಣ ಶಬ್ದಗಳು',
    'dog_bark': 'ನಾಯಿ ಬೊಗಳುವುದು',
    'cat_meow': 'ಬೆಕ್ಕಿನ ಮಿಯಾಂವ್',
    'temple_bell': 'ದೇವಾಲಯದ ಗಂಟೆ',
    'cow_mooing': 'ಹಸುವಿನ ಅಂಬಾ ಧ್ವನಿ',
  },
};

/// Category translations
const Map<String, Map<String, String>> categoryTranslations = {
  'en': {
    'Home Safety & Household Awareness': 'Home Safety & Household Awareness',
    'Visitor Awareness': 'Visitor Awareness',
    'Human Communication': 'Human Communication',
    'Emergency Vehicles': 'Emergency Vehicles',
    'Road Safety': 'Road Safety',
    'Public Safety': 'Public Safety',
    'Environmental Awareness': 'Environmental Awareness',
  },
  'hi': {
    'Home Safety & Household Awareness': 'घरेलू सुरक्षा और घरेलू जागरूकता',
    'Visitor Awareness': 'आगंतुक जागरूकता',
    'Human Communication': 'मानव संचार',
    'Emergency Vehicles': 'आपातकालीन वाहन',
    'Road Safety': 'सड़क सुरक्षा',
    'Public Safety': 'सार्वजनिक सुरक्षा',
    'Environmental Awareness': 'पर्यावरणीय जागरूकता',
  },
  'kn': {
    'Home Safety & Household Awareness': 'ಮನೆ ಸುರಕ್ಷತೆ ಮತ್ತು ಗೃಹ ಜಾಗೃತಿ',
    'Visitor Awareness': 'ಸಂದರ್ಶಕರ ಜಾಗೃತಿ',
    'Human Communication': 'ಮಾನವ ಸಂವಹನ',
    'Emergency Vehicles': 'ತುರ್ತು ವಾಹನಗಳು',
    'Road Safety': 'ರಸ್ತೆ ಸುರಕ್ಷತೆ',
    'Public Safety': 'ಸಾರ್ವಜನಿಕ ಸುರಕ್ಷತೆ',
    'Environmental Awareness': 'ಪರಿಸರ ಜಾಗೃತಿ',
  },
};

/// Resolves sound name localized via BuildContext or direct language code
String getLocalizedSoundName(String soundIdOrName, {BuildContext? context, String? langCode}) {
  final code = langCode ?? (context != null ? Localizations.localeOf(context).languageCode : 'en');
  
  // Try matching by exact ID
  if (soundClassTranslations[code]?.containsKey(soundIdOrName) == true) {
    return soundClassTranslations[code]![soundIdOrName]!;
  }
  
  // Try finding SoundLabel by ID or Name
  final label = soundTaxonomy.firstWhere(
    (s) => s.id == soundIdOrName || s.name.toLowerCase() == soundIdOrName.toLowerCase(),
    orElse: () => SoundLabel(
      id: soundIdOrName,
      name: soundIdOrName,
      environment: EnvironmentType.indoor,
      category: 'General',
      severity: PriorityLevel.low,
      imagePath: '',
    ),
  );

  return soundClassTranslations[code]?[label.id] ??
         soundClassTranslations['en']?[label.id] ??
         label.name;
}

/// Resolves category localized
String getLocalizedCategoryName(String category, {BuildContext? context, String? langCode}) {
  final code = langCode ?? (context != null ? Localizations.localeOf(context).languageCode : 'en');
  return categoryTranslations[code]?[category] ??
         categoryTranslations['en']?[category] ??
         category;
}

/// Complete list of the 25 AIISH model sound classes
const List<SoundLabel> soundTaxonomy = [
  // AIISH model classes not present in the original UI taxonomy
  SoundLabel(
    id: 'air_conditioner',
    name: 'Air Conditioner',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/air_conditioner.png',
    iconName: 'ac_unit',
  ),
  SoundLabel(
    id: 'children_playing',
    name: 'Children Playing',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/children_playing.png',
    iconName: 'groups',
  ),
  SoundLabel(
    id: 'engine_idling',
    name: 'Engine Idling',
    environment: EnvironmentType.outdoor,
    category: 'Road Safety',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/engine_idling.png',
    iconName: 'directions_car',
  ),
  SoundLabel(
    id: 'street_music',
    name: 'Street Music',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/street_music.png',
    iconName: 'music_note',
  ),

  // 1. INDOOR — Home Safety & Household Awareness
  SoundLabel(
    id: 'alarm_fire_smoke',
    name: 'Alarm (Fire / Smoke)',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.critical,
    imagePath: 'assets/images/sounds/alarm_fire_smoke.png',
    iconName: 'local_fire_department',
  ),
  SoundLabel(
    id: 'glass_breaking',
    name: 'Glass Breaking',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.critical,
    imagePath: 'assets/images/sounds/glass_breaking.png',
    iconName: 'gavel',
  ),
  SoundLabel(
    id: 'pressure_cooker',
    name: 'Pressure Cooker Whistle',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/pressure_cooker.png',
    iconName: 'air',
  ),
  SoundLabel(
    id: 'water_running',
    name: 'Water Running',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/water_running.png',
    iconName: 'water_drop',
  ),
  SoundLabel(
    id: 'microwave_beep',
    name: 'Microwave Oven Beep',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/microwave_beep.png',
    iconName: 'microwave',
  ),
  SoundLabel(
    id: 'mixer_grinder',
    name: 'Mixer / Grinder',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/mixer_grinder.png',
    iconName: 'electric_bolt',
  ),
  SoundLabel(
    id: 'utensils',
    name: 'Utensils',
    environment: EnvironmentType.indoor,
    category: 'Home Safety & Household Awareness',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/utensils.png',
    iconName: 'restaurant',
  ),

  // 2. INDOOR — Visitor Awareness
  SoundLabel(
    id: 'doorbell',
    name: 'Doorbell',
    environment: EnvironmentType.indoor,
    category: 'Visitor Awareness',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/doorbell.png',
    iconName: 'notifications_active',
  ),
  SoundLabel(
    id: 'door_knock',
    name: 'Door Knock',
    environment: EnvironmentType.indoor,
    category: 'Visitor Awareness',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/door_knock.png',
    iconName: 'meeting_room',
  ),

  // 3. INDOOR — Human Communication
  SoundLabel(
    id: 'baby_crying',
    name: 'Baby Crying',
    environment: EnvironmentType.indoor,
    category: 'Human Communication',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/baby_crying.png',
    iconName: 'child_care',
  ),

  // 4. OUTDOOR — Emergency Vehicles
  SoundLabel(
    id: 'siren_emergency',
    name: 'Siren (Ambulance/Police/Fire Brigade)',
    environment: EnvironmentType.outdoor,
    category: 'Emergency Vehicles',
    severity: PriorityLevel.critical,
    imagePath: 'assets/images/sounds/siren_emergency.png',
    iconName: 'emergency',
  ),

  // 5. OUTDOOR — Road Safety
  SoundLabel(
    id: 'train_horn',
    name: 'Train Horn',
    environment: EnvironmentType.outdoor,
    category: 'Road Safety',
    severity: PriorityLevel.critical,
    imagePath: 'assets/images/sounds/train_horn.png',
    iconName: 'train',
  ),
  SoundLabel(
    id: 'vehicle_horn',
    name: 'Vehicle Horn (Car/Bike/Bus/Truck)',
    environment: EnvironmentType.outdoor,
    category: 'Road Safety',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/vehicle_horn.png',
    iconName: 'directions_car',
  ),
  SoundLabel(
    id: 'approaching_vehicles',
    name: 'Approaching Vehicles',
    environment: EnvironmentType.outdoor,
    category: 'Road Safety',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/approaching_vehicles.png',
    iconName: 'speed',
  ),

  // 6. OUTDOOR — Public Safety
  SoundLabel(
    id: 'blasts',
    name: 'Blasts',
    environment: EnvironmentType.outdoor,
    category: 'Public Safety',
    severity: PriorityLevel.critical,
    imagePath: 'assets/images/sounds/blasts.png',
    iconName: 'warning_amber',
  ),
  SoundLabel(
    id: 'fire_crackers',
    name: 'Fire Crackers',
    environment: EnvironmentType.outdoor,
    category: 'Public Safety',
    severity: PriorityLevel.high,
    imagePath: 'assets/images/sounds/fire_crackers.png',
    iconName: 'flare',
  ),
  SoundLabel(
    id: 'construction_sounds',
    name: 'Construction Sounds',
    environment: EnvironmentType.outdoor,
    category: 'Public Safety',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/construction_sounds.png',
    iconName: 'construction',
  ),

  // 7. OUTDOOR — Environmental Awareness
  SoundLabel(
    id: 'dog_bark',
    name: 'Dog Bark',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.medium,
    imagePath: 'assets/images/sounds/dog_bark.png',
    iconName: 'pets',
  ),
  SoundLabel(
    id: 'cat_meow',
    name: 'Cat Meow',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/cat_meowing.png',
    iconName: 'pets',
  ),
  SoundLabel(
    id: 'temple_bell',
    name: 'Temple Bell',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/temple_bell.png',
    iconName: 'notifications',
  ),
  SoundLabel(
    id: 'cow_mooing',
    name: 'Cow Mooing',
    environment: EnvironmentType.outdoor,
    category: 'Environmental Awareness',
    severity: PriorityLevel.low,
    imagePath: 'assets/images/sounds/cow_mooing.png',
    iconName: 'cruelty_free',
  ),
];
