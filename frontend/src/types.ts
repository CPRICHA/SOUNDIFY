export type SeverityType = 'critical' | 'attention' | 'low';
export type EnvironmentType = 'indoor' | 'outdoor';

export interface SoundLabel {
  id: string;
  name: string;
  environment: EnvironmentType;
  category: string;
  severity: SeverityType;
  iconName: string; // lucide icon identifier
}

export interface SoundEvent {
  id: string;
  user_id: string;
  label: string;
  severity: SeverityType;
  mode: EnvironmentType;
  timestamp: string;
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
  gpsAutoDetect?: boolean;
  language?: 'English' | 'Hindi' | 'Kannada';
  textSize?: 'small' | 'medium' | 'large';
  highContrast?: boolean;
}

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
