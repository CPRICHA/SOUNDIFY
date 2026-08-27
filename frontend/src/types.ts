<<<<<<< HEAD
export type SeverityType = 'critical' | 'attention' | 'medium' | 'low';

=======
export type PriorityLevel = 'critical' | 'high' | 'medium' | 'low';
export type SeverityType = PriorityLevel;
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
export type EnvironmentType = 'indoor' | 'outdoor';

export interface SoundLabel {
  id: string;
  name: string;
  environment: EnvironmentType;
  category: string;
<<<<<<< HEAD

  /**
   * Default/fallback severity.
   *
   * Actual displayed priority is calculated dynamically
   * using the current indoor/outdoor mode.
   */
  severity: SeverityType;

  iconName: string;
=======
  severity: PriorityLevel;
  imagePath: string; // Static image/SVG asset path (e.g., /icons/sounds/alarm_fire_smoke.svg)
  iconName?: string; // (Deprecated) Legacy icon identifier
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
}

export interface SoundEvent {
  id: string;
  user_id: string;
  label: string;
  severity: PriorityLevel;
  mode: EnvironmentType;
  timestamp: string;
}

export interface SavedLocation {
  id: string;
  name: string;
  address: string;
  createdAt?: number;
}

export interface FeedbackEntry {
  id: string;
  category: string;
  message: string;
  rating?: number;
  timestamp: number;
}

export interface UserProfile {
  id: string;
  name: string;
  age: number;
  phone: string;
  email: string;
  micAccess: boolean;
  termsAccepted: boolean;
  privacyPolicyAccepted: boolean;
  outputPreferences: ('text' | 'icon' | 'color')[];
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  muteLowAlerts?: boolean;
  muteMediumAlerts?: boolean;
  gpsAutoDetect?: boolean;
  savedLocations?: SavedLocation[];
  language?: 'English' | 'Hindi' | 'Kannada';
  textSize?: 'small' | 'medium' | 'large';
  highContrast?: boolean;
}
<<<<<<< HEAD

/** JSON response from Python ML POST /api/v1/classify (via Express proxy). */

export interface ClassifyTopPrediction {
  rank: number;
  label: string;
  probability: number;
}

export interface ClassifyPrediction {
  predicted_class: string;
  confidence: number;
  confidence_percent: number;
  top_predictions: ClassifyTopPrediction[];
  inference_ms: number;
  duration_s: number;
  model_name: string;
}
=======
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
