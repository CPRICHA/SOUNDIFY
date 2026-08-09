import { SoundLabel } from '../types';
import { SOUND_TAXONOMY } from './soundTaxonomy';

/**
 * Model class name (AIISH_v2 / unified_labels.json) → frontend taxonomy id.
 *
 * Only maps where a clear existing taxonomy id exists.
 * Do not invent ids. Leave unmapped classes out of this table.
 *
 * Unmapped model classes (no exact UI id):
 * - Air Conditioner
 * - Children Playing
 * - Engine Idling
 * - Gun Shot          (do not force onto "blasts")
 * - Street Music
 *
 * Near-match kept (only Alarm → alarm_fire_smoke):
 * - Alarm → alarm_fire_smoke
 */
export const MODEL_TO_TAXONOMY_ID: Record<string, string> = {
  Siren: 'siren_emergency',
  'Glass Breaking': 'glass_breaking',
  Doorbell: 'doorbell',
  'Door Knock': 'door_knock',
  'Baby Crying': 'baby_crying',
  'Cat Meowing': 'cat_meow',
  'Dog Bark': 'dog_bark',
  'Vehicle Horn': 'vehicle_horn',
  'Construction Sound': 'construction_sounds',
  Firecrackers: 'fire_crackers',
  // Additional clear 1:1 name matches already in SOUND_TAXONOMY
  Alarm: 'alarm_fire_smoke',
  'Approaching Vehicles': 'approaching_vehicles',
  'Train Horn': 'train_horn',
  'Temple Bell': 'temple_bell',
  'Cow Mooing': 'cow_mooing',
  'Water Running': 'water_running',
  Utensils: 'utensils',
  'Microwave Oven Beep': 'microwave_beep',
  'Mixer Grinder': 'mixer_grinder',
  'Pressure Cooker Whistle': 'pressure_cooker',
};

/** Resolve a model predicted_class string to a frontend SoundLabel, if mapped. */
export function mapModelClassToSoundLabel(
  predictedClass: string
): SoundLabel | null {
  const taxonomyId = MODEL_TO_TAXONOMY_ID[predictedClass];
  if (!taxonomyId) {
    return null;
  }
  return SOUND_TAXONOMY.find((s) => s.id === taxonomyId) ?? null;
}
