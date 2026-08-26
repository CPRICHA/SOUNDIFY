import {
  EnvironmentType,
  SeverityType,
  SoundLabel,
} from '../types';

/**
 * Priority system:
 *
 * critical = Critical 🔴
 * attention = High 🟠
 * medium = Medium 🟡
 * low = Low 🟢
 *
 * Priority changes depending on whether
 * the user is indoors or outdoors.
 */
export const SOUND_PRIORITY_MATRIX: Record<
  string,
  Record<EnvironmentType, SeverityType>
> = {
  // ============================================================
  // 0. Air Conditioner
  // ============================================================
  air_conditioner: {
    indoor: 'low',
    outdoor: 'low',
  },

  // ============================================================
  // 1. Alarm
  // ============================================================
  alarm_fire_smoke: {
    indoor: 'critical',
    outdoor: 'critical',
  },

  // ============================================================
  // 2. Approaching Vehicles
  // ============================================================
  approaching_vehicles: {
    indoor: 'medium',
    outdoor: 'attention',
  },

  // ============================================================
  // 3. Baby Crying
  // ============================================================
  baby_crying: {
    indoor: 'attention',
    outdoor: 'medium',
  },

  // ============================================================
  // 4. Cat Meow
  // ============================================================
  cat_meow: {
    indoor: 'low',
    outdoor: 'low',
  },

  // ============================================================
  // 5. Children Playing
  // ============================================================
  children_playing: {
    indoor: 'medium',
    outdoor: 'medium',
  },

  // ============================================================
  // 6. Construction Sound
  // ============================================================
  construction_sounds: {
    indoor: 'low',
    outdoor: 'medium',
  },

  // ============================================================
  // 7. Cow Mooing
  // ============================================================
  cow_mooing: {
    indoor: 'low',
    outdoor: 'low',
  },

  // ============================================================
  // 8. Dog Bark
  // ============================================================
  dog_bark: {
    indoor: 'medium',
    outdoor: 'medium',
  },

  // ============================================================
  // 9. Door Knock
  // ============================================================
  door_knock: {
    indoor: 'medium',
    outdoor: 'low',
  },

  // ============================================================
  // 10. Doorbell
  // ============================================================
  doorbell: {
    indoor: 'medium',
    outdoor: 'low',
  },

  // ============================================================
  // 11. Engine Idling
  // ============================================================
  engine_idling: {
    indoor: 'low',
    outdoor: 'medium',
  },

  // ============================================================
  // 12. Firecrackers
  // ============================================================
  fire_crackers: {
    indoor: 'medium',
    outdoor: 'attention',
  },

  // ============================================================
  // 13. Glass Breaking
  // ============================================================
  glass_breaking: {
    indoor: 'critical',
    outdoor: 'critical',
  },

  // ============================================================
  // 14. Gun Shot
  // ============================================================
  gun_shot: {
    indoor: 'critical',
    outdoor: 'critical',
  },

  // ============================================================
  // 15. Microwave Oven Beep
  // ============================================================
  microwave_beep: {
    indoor: 'attention',
    outdoor: 'low',
  },

  // ============================================================
  // 16. Mixer Grinder
  // ============================================================
  mixer_grinder: {
    indoor: 'medium',
    outdoor: 'low',
  },

  // ============================================================
  // 17. Pressure Cooker Whistle
  // ============================================================
  pressure_cooker: {
    indoor: 'attention',
    outdoor: 'low',
  },

  // ============================================================
  // 18. Siren
  // ============================================================
  siren_emergency: {
    indoor: 'critical',
    outdoor: 'critical',
  },

  // ============================================================
  // 19. Street Music
  // ============================================================
  street_music: {
    indoor: 'low',
    outdoor: 'low',
  },

  // ============================================================
  // 20. Temple Bell
  // ============================================================
  temple_bell: {
    indoor: 'low',
    outdoor: 'low',
  },

  // ============================================================
  // 21. Train Horn
  // ============================================================
  train_horn: {
    indoor: 'attention',
    outdoor: 'critical',
  },

  // ============================================================
  // 22. Utensils
  // ============================================================
  utensils: {
    indoor: 'medium',
    outdoor: 'low',
  },

  // ============================================================
  // 23. Vehicle Horn
  // ============================================================
  vehicle_horn: {
    indoor: 'medium',
    outdoor: 'attention',
  },

  // ============================================================
  // 24. Water Running
  // ============================================================
  water_running: {
    indoor: 'attention',
    outdoor: 'low',
  },
};

/**
 * Get the actual priority of a sound based on
 * the user's current environment.
 *
 * Example:
 *
 * Engine Idling + indoor  → low
 * Engine Idling + outdoor → medium
 *
 * Vehicle Horn + indoor   → medium
 * Vehicle Horn + outdoor  → attention (High)
 */
export function getSoundPriority(
  sound: SoundLabel,
  mode: EnvironmentType
): SeverityType {
  return (
    SOUND_PRIORITY_MATRIX[sound.id]?.[mode] ??
    sound.severity ??
    'low'
  );
}