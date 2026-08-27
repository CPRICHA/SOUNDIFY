import { SoundLabel } from '../types';

export const TAXONOMY_CATEGORIES = [
  'Home Safety & Household Awareness',
  'Visitor Awareness',
  'Human Communication',
  'Emergency Vehicles',
  'Road Safety',
  'Public Safety',
  'Environmental Awareness'
] as const;

export const SOUND_TAXONOMY: SoundLabel[] = [
  // INDOOR — Home Safety & Household Awareness
  {
    id: 'alarm_fire_smoke',
    name: 'Alarm (Fire / Smoke)',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'critical',
    imagePath: '/icons/sounds/alarm_fire_smoke.svg',
    iconName: 'Flame'
  },
  {
    id: 'glass_breaking',
    name: 'Glass Breaking',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'critical',
    imagePath: '/icons/sounds/glass_breaking.svg',
    iconName: 'ShieldAlert'
  },
  {
    id: 'pressure_cooker',
    name: 'Pressure Cooker Whistle',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'high',
    imagePath: '/icons/sounds/pressure_cooker.svg',
    iconName: 'Wind'
  },
  {
    id: 'water_running',
    name: 'Water Running',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'high',
    imagePath: '/icons/sounds/water_running.svg',
    iconName: 'Droplets'
  },
  {
    id: 'microwave_beep',
    name: 'Microwave Oven Beep',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'high',
    imagePath: '/icons/sounds/microwave_beep.svg',
    iconName: 'Radio'
  },
  {
    id: 'mixer_grinder',
    name: 'Mixer / Grinder',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/mixer_grinder.svg',
    iconName: 'Zap'
  },
  {
    id: 'motor_pump',
    name: 'Motor Sound (Water Pump)',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/motor_pump.svg',
    iconName: 'Cpu'
  },
  {
    id: 'utensils',
    name: 'Utensils',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/utensils.svg',
    iconName: 'Soup'
  },

  // INDOOR — Visitor Awareness
  {
    id: 'doorbell',
    name: 'Doorbell',
    environment: 'indoor',
    category: 'Visitor Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/doorbell.svg',
    iconName: 'Bell'
  },
  {
    id: 'door_knock',
    name: 'Door Knock',
    environment: 'indoor',
    category: 'Visitor Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/door_knock.svg',
    iconName: 'Hand'
  },

  // INDOOR — Human Communication
  {
    id: 'human_distress',
    name: 'Human Distress / Warning',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'critical',
    imagePath: '/icons/sounds/human_distress.svg',
    iconName: 'Megaphone'
  },
  {
    id: 'baby_crying',
    name: 'Baby Crying',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'high',
    imagePath: '/icons/sounds/baby_crying.svg',
    iconName: 'Heart'
  },
  {
    id: 'name_calling',
    name: 'Name Calling',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'medium',
    imagePath: '/icons/sounds/name_calling.svg',
    iconName: 'Speech'
  },
  {
    id: 'vendor_selling',
    name: 'Vendor Selling',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'medium',
    imagePath: '/icons/sounds/vendor_selling.svg',
    iconName: 'Store'
  },

  // OUTDOOR — Emergency Vehicles
  {
    id: 'siren_emergency',
    name: 'Siren (Ambulance/Police/Fire Brigade)',
    environment: 'outdoor',
    category: 'Emergency Vehicles',
    severity: 'critical',
    imagePath: '/icons/sounds/siren_emergency.svg',
    iconName: 'Siren'
  },

  // OUTDOOR — Road Safety
  {
    id: 'train_horn',
    name: 'Train Horn',
    environment: 'outdoor',
    category: 'Road Safety',
    severity: 'critical',
    imagePath: '/icons/sounds/train_horn.svg',
    iconName: 'Train'
  },
  {
    id: 'vehicle_horn',
    name: 'Vehicle Horn (Car/Bike/Bus/Truck)',
    environment: 'outdoor',
    category: 'Road Safety',
    severity: 'high',
    imagePath: '/icons/sounds/vehicle_horn.svg',
    iconName: 'Car'
  },
  {
    id: 'auto_rickshaw',
    name: 'Auto Rickshaw Horn',
    environment: 'outdoor',
    category: 'Road Safety',
    severity: 'high',
    imagePath: '/icons/sounds/auto_rickshaw.svg',
    iconName: 'Bike'
  },
  {
    id: 'approaching_vehicles',
    name: 'Approaching Vehicles',
    environment: 'outdoor',
    category: 'Road Safety',
    severity: 'high',
    imagePath: '/icons/sounds/approaching_vehicles.svg',
    iconName: 'CarFront'
  },

  // OUTDOOR — Public Safety
  {
    id: 'blasts',
    name: 'Blasts',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'critical',
    imagePath: '/icons/sounds/blasts.svg',
    iconName: 'Bomb'
  },
  {
    id: 'railway_crossing',
    name: 'Railway Crossing Alarm',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'critical',
    imagePath: '/icons/sounds/railway_crossing.svg',
    iconName: 'Activity'
  },
  {
    id: 'fire_crackers',
    name: 'Fire Crackers',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'high',
    imagePath: '/icons/sounds/fire_crackers.svg',
    iconName: 'Sparkles'
  },
  {
    id: 'construction_sounds',
    name: 'Construction Sounds',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'medium',
    imagePath: '/icons/sounds/construction_sounds.svg',
    iconName: 'Hammer'
  },
  {
    id: 'school_bell',
    name: 'School Bell',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'medium',
    imagePath: '/icons/sounds/school_bell.svg',
    iconName: 'School'
  },

  // OUTDOOR — Environmental Awareness
  {
    id: 'dog_bark',
    name: 'Dog Bark',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'medium',
    imagePath: '/icons/sounds/dog_bark.svg',
    iconName: 'PawPrint'
  },
  {
    id: 'cat_meow',
    name: 'Cat Meow',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
    imagePath: '/icons/sounds/cat_meow.svg',
    iconName: 'Cat'
  },
  {
    id: 'temple_bell',
    name: 'Temple Bell',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
    imagePath: '/icons/sounds/temple_bell.svg',
    iconName: 'BellRing'
  },
  {
    id: 'cow_mooing',
    name: 'Cow Mooing',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
    imagePath: '/icons/sounds/cow_mooing.svg',
    iconName: 'Footprints'
  }
];
