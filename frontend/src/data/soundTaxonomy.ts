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
  // ============================================================
  // INDOOR — Home Safety & Household Awareness
  // ============================================================

  {
    id: 'alarm_fire_smoke',
    name: 'Alarm (Fire / Smoke)',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'critical',
<<<<<<< HEAD
    iconName: 'Flame',
=======
    imagePath: '/icons/sounds/alarm_fire_smoke.svg',
    iconName: 'Flame'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'glass_breaking',
    name: 'Glass Breaking',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'critical',
<<<<<<< HEAD
    iconName: 'ShieldAlert',
=======
    imagePath: '/icons/sounds/glass_breaking.svg',
    iconName: 'ShieldAlert'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'pressure_cooker',
    name: 'Pressure Cooker Whistle',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Wind',
=======
    severity: 'high',
    imagePath: '/icons/sounds/pressure_cooker.svg',
    iconName: 'Wind'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
<<<<<<< HEAD
    id: 'mixer_grinder',
    name: 'Mixer / Grinder',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'medium',
    iconName: 'Zap',
  },

  {
    id: 'microwave_beep',
    name: 'Microwave Oven Beep',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'attention',
    iconName: 'Radio',
  },

  {
=======
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    id: 'water_running',
    name: 'Water Running',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Droplets',
=======
    severity: 'high',
    imagePath: '/icons/sounds/water_running.svg',
    iconName: 'Droplets'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
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
<<<<<<< HEAD
    iconName: 'Cpu',
=======
    imagePath: '/icons/sounds/motor_pump.svg',
    iconName: 'Cpu'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'utensils',
    name: 'Utensils',
    environment: 'indoor',
    category: 'Home Safety & Household Awareness',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Soup',
=======
    imagePath: '/icons/sounds/utensils.svg',
    iconName: 'Soup'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  // ============================================================
  // INDOOR — Visitor Awareness
  // ============================================================

  {
    id: 'doorbell',
    name: 'Doorbell',
    environment: 'indoor',
    category: 'Visitor Awareness',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Bell',
=======
    imagePath: '/icons/sounds/doorbell.svg',
    iconName: 'Bell'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'door_knock',
    name: 'Door Knock',
    environment: 'indoor',
    category: 'Visitor Awareness',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Hand',
=======
    imagePath: '/icons/sounds/door_knock.svg',
    iconName: 'Hand'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  // ============================================================
  // INDOOR — Human Communication
  // ============================================================

  {
    id: 'human_distress',
    name: 'Human Distress / Warning',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'critical',
<<<<<<< HEAD
    iconName: 'Megaphone',
=======
    imagePath: '/icons/sounds/human_distress.svg',
    iconName: 'Megaphone'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'baby_crying',
    name: 'Baby Crying',
    environment: 'indoor',
    category: 'Human Communication',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Heart',
=======
    severity: 'high',
    imagePath: '/icons/sounds/baby_crying.svg',
    iconName: 'Heart'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'name_calling',
    name: 'Name Calling',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Speech',
=======
    imagePath: '/icons/sounds/name_calling.svg',
    iconName: 'Speech'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'vendor_selling',
    name: 'Vendor Selling',
    environment: 'indoor',
    category: 'Human Communication',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Store',
=======
    imagePath: '/icons/sounds/vendor_selling.svg',
    iconName: 'Store'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  // ============================================================
  // OUTDOOR — Emergency Vehicles
  // ============================================================

  {
    id: 'siren_emergency',
    name: 'Siren (Ambulance/Police/Fire Brigade)',
    environment: 'outdoor',
    category: 'Emergency Vehicles',
    severity: 'critical',
<<<<<<< HEAD
    iconName: 'Siren',
=======
    imagePath: '/icons/sounds/siren_emergency.svg',
    iconName: 'Siren'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  // ============================================================
  // OUTDOOR — Road Safety
  // ============================================================

  {
    id: 'train_horn',
    name: 'Train Horn',
    environment: 'outdoor',
    category: 'Road Safety',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Train',
=======
    severity: 'critical',
    imagePath: '/icons/sounds/train_horn.svg',
    iconName: 'Train'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'vehicle_horn',
    name: 'Vehicle Horn (Car/Bike/Bus/Truck)',
    environment: 'outdoor',
    category: 'Road Safety',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Car',
=======
    severity: 'high',
    imagePath: '/icons/sounds/vehicle_horn.svg',
    iconName: 'Car'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
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
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'CarFront',
  },

  {
  id: 'engine_idling',
  name: 'Engine Idling',
  environment: 'outdoor',
  category: 'Road Safety',
  severity: 'medium',
  iconName: 'Car',
  },

  {
    id: 'auto_rickshaw',
    name: 'Auto Rickshaw',
    environment: 'outdoor',
    category: 'Road Safety',
    severity: 'low',
    iconName: 'Bike',
  },
=======
    severity: 'high',
    imagePath: '/icons/sounds/approaching_vehicles.svg',
    iconName: 'CarFront'
  },
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4

  // ============================================================
  // OUTDOOR — Public Safety
  // ============================================================

  {
    id: 'blasts',
    name: 'Blasts',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'critical',
<<<<<<< HEAD
    iconName: 'Bomb',
=======
    imagePath: '/icons/sounds/blasts.svg',
    iconName: 'Bomb'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'railway_crossing',
    name: 'Railway Crossing Alarm',
    environment: 'outdoor',
    category: 'Public Safety',
<<<<<<< HEAD
    severity: 'medium',
    iconName: 'Activity',
=======
    severity: 'critical',
    imagePath: '/icons/sounds/railway_crossing.svg',
    iconName: 'Activity'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'fire_crackers',
    name: 'Fire Crackers',
    environment: 'outdoor',
    category: 'Public Safety',
<<<<<<< HEAD
    severity: 'attention',
    iconName: 'Sparkles',
=======
    severity: 'high',
    imagePath: '/icons/sounds/fire_crackers.svg',
    iconName: 'Sparkles'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'construction_sounds',
    name: 'Construction Sounds',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'Hammer',
=======
    imagePath: '/icons/sounds/construction_sounds.svg',
    iconName: 'Hammer'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'school_bell',
    name: 'School Bell',
    environment: 'outdoor',
    category: 'Public Safety',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'School',
=======
    imagePath: '/icons/sounds/school_bell.svg',
    iconName: 'School'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  // ============================================================
  // OUTDOOR — Environmental Awareness
  // ============================================================

  {
    id: 'dog_bark',
    name: 'Dog Bark',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'medium',
<<<<<<< HEAD
    iconName: 'PawPrint',
=======
    imagePath: '/icons/sounds/dog_bark.svg',
    iconName: 'PawPrint'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
<<<<<<< HEAD
    id: 'cow_mooing',
    name: 'Cow Mooing',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
    iconName: 'Footprints',
  },

  {
=======
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    id: 'cat_meow',
    name: 'Cat Meow',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
<<<<<<< HEAD
    iconName: 'Cat',
=======
    imagePath: '/icons/sounds/cat_meow.svg',
    iconName: 'Cat'
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  },

  {
    id: 'temple_bell',
    name: 'Temple Bell',
    environment: 'outdoor',
    category: 'Environmental Awareness',
    severity: 'low',
<<<<<<< HEAD
    iconName: 'BellRing',
  },
];
=======
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
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
