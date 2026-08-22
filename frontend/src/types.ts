export type PriorityLevel = 'critical' | 'high' | 'medium' | 'low';
export type SeverityType = PriorityLevel;
export type EnvironmentType = 'indoor' | 'outdoor';

export interface SoundLabel {
  id: string;
  name: string;
  environment: EnvironmentType;
  category: string;
  severity: PriorityLevel;
  imagePath: string; // Static image/SVG asset path (e.g., /icons/sounds/alarm_fire_smoke.svg)
  iconName?: string; // (Deprecated) Legacy icon identifier
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
