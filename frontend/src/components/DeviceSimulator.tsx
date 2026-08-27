import React, { useState, useEffect } from 'react';
import * as Icons from 'lucide-react';
import { SoundLabel, SoundEvent, UserProfile, SeverityType, SavedLocation, FeedbackEntry } from '../types';
import { SOUND_TAXONOMY } from '../data/soundTaxonomy';
import { TRANSLATIONS, Language } from '../data/translations';

interface DeviceSimulatorProps {
  userProfile: UserProfile;
  setUserProfile: React.Dispatch<React.SetStateAction<UserProfile>>;
  currentScreen: string;
  setCurrentScreen: (screen: string) => void;
  lastDetectedSound: SoundLabel | null;
  setLastDetectedSound: React.Dispatch<React.SetStateAction<SoundLabel | null>>;
  showTextAlert: boolean;
  setShowTextAlert: (show: boolean) => void;
  showIconAlert: boolean;
  setShowIconAlert: (show: boolean) => void;
  isListening: boolean;
  setIsListening: (listening: boolean) => void;
  mode: 'indoor' | 'outdoor';
  setMode: (mode: 'indoor' | 'outdoor') => void;
  historyList: SoundEvent[];
  onTriggerEmergency: (actionType: string, message: string) => void;
  isVibrating: boolean;
  vibrationPattern: string;
  vibrationProgress: number;
  onTriggerSound: (sound: SoundLabel) => void;
  onTriggerHapticVibration: (severity: SeverityType) => void;
}

// Image-based Sound Icon rendering helper
export const DynamicIcon = ({
  src,
  name,
  className = '',
  size = 20,
  alt
}: {
  src?: string;
  name?: string;
  className?: string;
  size?: number;
  alt?: string;
}) => {
  const imageSrc = src || (name ? `/icons/sounds/${name}.svg` : '/icons/sounds/alarm_fire_smoke.svg');
  return (
    <img
      src={imageSrc}
      alt={alt || name || 'Sound Icon'}
      className={`inline-block object-contain ${className}`}
      style={{ width: size, height: size }}
      loading="lazy"
    />
  );
};

// Sound-specific icon component mapped to taxonomy & Lucide icons with strict severity color-coding
export const SoundSpecificIcon: React.FC<{
  sound?: SoundLabel | null;
  soundName?: string;
  soundId?: string;
  severity?: SeverityType;
  size?: number;
  className?: string;
  overrideColor?: string;
}> = ({ sound, soundName, soundId, severity, size = 20, className = '', overrideColor }) => {
  const targetSound = sound || (soundName || soundId ? SOUND_TAXONOMY.find(
    s => (soundId && s.id.toLowerCase() === soundId.toLowerCase()) || 
         (soundName && s.name.toLowerCase() === soundName.toLowerCase())
  ) : null);

  const targetSeverity = severity || targetSound?.severity || 'low';
  const iconKey = targetSound?.iconName;

  // Severity color tint (Critical = red, High = orange, Medium = blue, Low = green)
  const severityColorClass = overrideColor || (
    targetSeverity === 'critical' ? 'text-red-600' :
    targetSeverity === 'high' ? 'text-orange-600' :
    targetSeverity === 'medium' ? 'text-blue-600' :
    'text-green-600'
  );

  const IconComponent = (iconKey && (Icons as any)[iconKey]) 
    ? (Icons as any)[iconKey] 
    : Icons.Volume2;

  return (
    <IconComponent 
      size={size} 
      className={`${severityColorClass} ${className} shrink-0`} 
      strokeWidth={2.2}
    />
  );
};

export const getPriorityWord = (severity?: SeverityType): string => {
  switch (severity) {
    case 'critical': return 'Critical';
    case 'high': return 'High';
    case 'medium': return 'Medium';
    case 'low': return 'Low';
    default: return 'Low';
  }
};

export const getSeverityTextColor = (severity: SeverityType, isHC: boolean) => {
  switch (severity) {
    case 'critical': return isHC ? 'text-red-700 font-black' : 'text-red-600 font-bold';
    case 'high': return isHC ? 'text-orange-700 font-black' : 'text-orange-600 font-bold';
    case 'medium': return isHC ? 'text-blue-700 font-black' : 'text-blue-600 font-bold';
    case 'low': return isHC ? 'text-green-700 font-black' : 'text-green-600 font-bold';
    default: return isHC ? 'text-slate-950 font-black' : 'text-slate-800 font-bold';
  }
};

export const getSeverityBgClass = (severity: SeverityType) => {
  switch (severity) {
    case 'critical': return 'bg-red-50 text-red-600 border-red-200';
    case 'high': return 'bg-orange-50 text-orange-600 border-orange-200';
    case 'medium': return 'bg-blue-50 text-blue-600 border-blue-200';
    case 'low': return 'bg-green-50 text-green-600 border-green-200';
    default: return 'bg-slate-50 text-slate-600 border-slate-200';
  }
};

export const getFullSeverityBannerBgClass = (severity: SeverityType, isHC: boolean) => {
  if (isHC) {
    switch (severity) {
      case 'critical': return 'bg-red-700 border-2 border-slate-950 text-white shadow-xl shadow-red-950/20';
      case 'high': return 'bg-orange-600 border-2 border-slate-950 text-white shadow-xl shadow-orange-950/20';
      case 'medium': return 'bg-blue-700 border-2 border-slate-950 text-white shadow-xl shadow-blue-950/20';
      case 'low': return 'bg-green-700 border-2 border-slate-950 text-white shadow-xl shadow-green-950/20';
      default: return 'bg-slate-900 border-2 border-slate-950 text-white shadow-xl';
    }
  }
  switch (severity) {
    case 'critical': return 'bg-red-600 border-red-500 text-white shadow-xl shadow-red-500/25';
    case 'high': return 'bg-orange-500 border-orange-400 text-white shadow-xl shadow-orange-500/25';
    case 'medium': return 'bg-blue-600 border-blue-500 text-white shadow-xl shadow-blue-500/25';
    case 'low': return 'bg-green-600 border-green-500 text-white shadow-xl shadow-green-500/25';
    default: return 'bg-slate-800 border-slate-700 text-white shadow-xl';
  }
};

export const DeviceSimulator: React.FC<DeviceSimulatorProps> = ({
  userProfile,
  setUserProfile,
  currentScreen,
  setCurrentScreen,
  lastDetectedSound,
  setLastDetectedSound,
  showTextAlert,
  setShowTextAlert,
  showIconAlert,
  setShowIconAlert,
  isListening,
  setIsListening,
  mode,
  setMode,
  historyList,
  onTriggerEmergency,
  isVibrating,
  vibrationPattern,
  vibrationProgress,
  onTriggerSound,
  onTriggerHapticVibration
}) => {
  const currentLang: Language = userProfile.language || 'English';
  const t = (key: string): string => {
    return TRANSLATIONS[currentLang]?.[key] || TRANSLATIONS['English']?.[key] || key;
  };

  const getSoundName = (sound?: SoundLabel | null, fallbackName?: string): string => {
    if (!sound && !fallbackName) return '';
    const soundObj = sound || SOUND_TAXONOMY.find(s => s.name.toLowerCase() === fallbackName?.toLowerCase() || s.id.toLowerCase() === fallbackName?.toLowerCase());
    if (soundObj) {
      const key = `sound_${soundObj.id}`;
      return TRANSLATIONS[currentLang]?.[key] || TRANSLATIONS['English']?.[key] || soundObj.name;
    }
    return fallbackName || '';
  };

  const getCategoryName = (category?: string): string => {
    if (!category) return t('categoryGeneral');
    switch (category) {
      case 'Home Safety & Household Awareness': return t('cat_home_safety');
      case 'Visitor Awareness': return t('cat_visitor_awareness');
      case 'Human Communication': return t('cat_human_comm');
      case 'Emergency Vehicles': return t('cat_emergency_vehicles');
      case 'Road Safety': return t('cat_road_safety');
      case 'Public Safety': return t('cat_public_safety');
      case 'Environmental Awareness': return t('cat_env_awareness');
      default: return category;
    }
  };

  const getPriorityWord = (severity?: SeverityType): string => {
    switch (severity) {
      case 'critical': return t('labelCritical');
      case 'high': return t('labelHigh');
      case 'medium': return t('labelMedium');
      case 'low': return t('labelLow');
      default: return t('labelLow');
    }
  };

  const isHC = !!userProfile.highContrast;

  // Theme styling helpers for High Contrast & Font Sizing
  const fontSizeClass = userProfile.textSize === 'small' ? 'app-text-small' : userProfile.textSize === 'large' ? 'app-text-large' : 'app-text-medium';
  const bgClass = isHC ? 'bg-white' : 'bg-slate-50';
  const textClass = isHC ? 'text-slate-950' : 'text-slate-800';
  const textMutedClass = isHC ? 'text-slate-900 font-bold' : 'text-slate-500';
  const textMutedLabelClass = isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400';
  const borderClass = isHC ? 'border-slate-950 border-2' : 'border-slate-100';
  const borderSubtleClass = isHC ? 'border-slate-950 border-2' : 'border-slate-200';
  const cardClass = isHC 
    ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' 
    : 'bg-white border border-slate-100 text-slate-800 shadow-sm';
  const inputClass = isHC
    ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold placeholder-slate-700'
    : 'bg-white border border-slate-200 text-slate-800';
  const badgeClass = isHC
    ? 'bg-slate-950 text-white font-extrabold border-2 border-slate-950'
    : 'bg-indigo-50 text-indigo-700 border border-indigo-100';
  const secondaryBadgeClass = isHC
    ? 'bg-white text-slate-950 font-extrabold border-2 border-slate-950'
    : 'bg-slate-100 text-slate-600 border border-slate-150';

  // Local state for onboarding form inputs
  const [isAppBackgrounded, setIsAppBackgrounded] = useState(false);
  const [formName, setFormName] = useState(userProfile.name);
  const [formAge, setFormAge] = useState(userProfile.age.toString());
  const [formCountryCode, setFormCountryCode] = useState(() => {
    const phone = userProfile.phone || '';
    if (phone.startsWith('+91')) return '+91';
    if (phone.startsWith('+1')) return '+1';
    if (phone.startsWith('+44')) return '+44';
    if (phone.startsWith('+61')) return '+61';
    if (phone.startsWith('+971')) return '+971';
    return '+91';
  });
  const [formPhone, setFormPhone] = useState(() => {
    const raw = userProfile.phone || '';
    const digits = raw.replace(/\D/g, '');
    return digits.length >= 10 ? digits.slice(-10) : digits;
  });
  const [formEmail, setFormEmail] = useState(userProfile.email);
  const [formMic, setFormMic] = useState(userProfile.micAccess);
  const [formLocation, setFormLocation] = useState(!!userProfile.gpsAutoDetect);
  const [formTerms, setFormTerms] = useState(userProfile.termsAccepted);
  const [formPrivacy, setFormPrivacy] = useState(userProfile.privacyPolicyAccepted);
  const [selectedSimSoundId, setSelectedSimSoundId] = useState(SOUND_TAXONOMY[0]?.id || '');

  // Saved locations management state
  const [isAddingLocation, setIsAddingLocation] = useState(false);
  const [editingLocationId, setEditingLocationId] = useState<string | null>(null);
  const [locFormName, setLocFormName] = useState('');
  const [locFormAddress, setLocFormAddress] = useState('');

  // Onboarding saved locations form state
  const [onboardingLocName, setOnboardingLocName] = useState('');
  const [onboardingLocAddress, setOnboardingLocAddress] = useState('');

  const handleAddLocation = (name: string, address: string) => {
    if (!name.trim() || !address.trim()) return;
    const newLoc: SavedLocation = {
      id: `loc_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      name: name.trim(),
      address: address.trim(),
      createdAt: Date.now()
    };
    setUserProfile(prev => ({
      ...prev,
      savedLocations: [...(prev.savedLocations || []), newLoc]
    }));
  };

  const handleUpdateLocation = (id: string, name: string, address: string) => {
    if (!name.trim() || !address.trim()) return;
    setUserProfile(prev => ({
      ...prev,
      savedLocations: (prev.savedLocations || []).map(loc =>
        loc.id === id ? { ...loc, name: name.trim(), address: address.trim() } : loc
      )
    }));
    setEditingLocationId(null);
    setLocFormName('');
    setLocFormAddress('');
  };

  const handleDeleteLocation = (id: string) => {
    setUserProfile(prev => ({
      ...prev,
      savedLocations: (prev.savedLocations || []).filter(loc => loc.id !== id)
    }));
  };

  // Rating & Feedback states (Purely local storage / native OS review simulator, 0 DB/network calls)
  const [showRateModal, setShowRateModal] = useState(false);
  const [ratingStars, setRatingStars] = useState(5);
  const [showFeedbackModal, setShowFeedbackModal] = useState(false);
  const [feedbackCategory, setFeedbackCategory] = useState('General');
  const [feedbackMessage, setFeedbackMessage] = useState('');
  const [feedbackRating, setFeedbackRating] = useState(5);
  const [feedbackToast, setFeedbackToast] = useState<string | null>(null);

  const handleSaveFeedback = () => {
    if (!feedbackMessage.trim()) return;
    const newFeedback: FeedbackEntry = {
      id: `fb_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`,
      category: feedbackCategory,
      message: feedbackMessage.trim(),
      rating: feedbackRating,
      timestamp: Date.now()
    };
    try {
      const existingStr = localStorage.getItem('soundsee_local_feedback');
      const existingList: FeedbackEntry[] = existingStr ? JSON.parse(existingStr) : [];
      localStorage.setItem('soundsee_local_feedback', JSON.stringify([...existingList, newFeedback]));
    } catch {
      // Offline fallback
    }
    setShowFeedbackModal(false);
    setFeedbackMessage('');
    setFeedbackToast(t('feedbackSuccessToast') || 'Feedback saved locally. Thank you!');
    setTimeout(() => {
      setFeedbackToast(null);
    }, 3500);
  };

  const updateProfileField = (key: keyof UserProfile, value: any) => {
    setUserProfile(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const Switch = ({ checked, onChange, disabled = false }: { checked: boolean; onChange: () => void; disabled?: boolean }) => {
    return (
      <button
        type="button"
        disabled={disabled}
        onClick={onChange}
        className={`relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 focus:outline-none transition-colors duration-200 ease-in-out ${
          disabled 
            ? 'bg-slate-200 border-transparent cursor-not-allowed' 
            : isHC
            ? checked 
              ? 'bg-slate-950 border-slate-950' 
              : 'bg-slate-300 border-slate-950'
            : checked 
            ? 'bg-indigo-600 border-transparent' 
            : 'bg-slate-200 border-transparent'
        }`}
      >
        <span
          className={`pointer-events-none inline-block h-3.5 w-3.5 transform rounded-full bg-white shadow transition duration-200 ease-in-out ${
            checked ? 'translate-x-4' : 'translate-x-0'
          }`}
        />
      </button>
    );
  };

  // Pref selection inside simulator
  const handleTogglePref = (pref: 'text' | 'icon' | 'color') => {
    let current = [...userProfile.outputPreferences];
    if (current.includes(pref)) {
      if ((pref === 'text' && !current.includes('icon')) || (pref === 'icon' && !current.includes('text'))) {
        alert("At least one of Text or Icon must be selected.");
        return;
      }
      current = current.filter(p => p !== pref);
    } else {
      current.push(pref);
    }
    setUserProfile(prev => ({ ...prev, outputPreferences: current }));
  };

  // Onboarding Submit
  const handleOnboardingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName || !formAge || !formPhone || !formMic || !formLocation || !formTerms || !formPrivacy) {
      alert("Please fill required fields (*) and grant necessary permissions.");
      return;
    }
    if (formPhone.length !== 10) {
      alert("⚠️ Phone Number Error: Please enter exactly a 10-digit numeric phone number.");
      return;
    }
    setUserProfile(prev => ({
      ...prev,
      name: formName,
      age: parseInt(formAge) || 0,
      phone: `${formCountryCode}${formPhone}`,
      email: formEmail,
      micAccess: formMic,
      gpsAutoDetect: formLocation,
      termsAccepted: formTerms,
      privacyPolicyAccepted: formPrivacy,
    }));
    setCurrentScreen('preference');
  };

  // Auto-redirect for splash
  useEffect(() => {
    if (currentScreen === 'splash') {
      const timer = setTimeout(() => {
        setCurrentScreen('auth');
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [currentScreen]);

  // Auto-dismiss last detected sound after 4 seconds to transition back to listening/idle state
  useEffect(() => {
    if (lastDetectedSound) {
      const timer = setTimeout(() => {
        setLastDetectedSound(null);
        setShowTextAlert(false);
        setShowIconAlert(false);
      }, 4000);
      return () => clearTimeout(timer);
    }
  }, [lastDetectedSound, setLastDetectedSound, setShowTextAlert, setShowIconAlert]);

  return (
    <div className="flex flex-col items-center">
      {/* Device wrapper mockup */}
      <div className="relative w-[340px] h-[680px] bg-slate-900 rounded-[48px] p-4 shadow-2xl border-4 border-slate-800 transition-all duration-300">
        {/* Device camera notch */}
        <div className="absolute top-6 left-1/2 -translate-x-1/2 w-32 h-6 bg-slate-900 rounded-full z-50 flex items-center justify-center">
          <div className="w-3 h-3 bg-slate-800 rounded-full mr-2"></div>
          <div className="w-16 h-1 bg-slate-800 rounded-full"></div>
        </div>

        {/* Dynamic color flash border overlay (Color Coded Alert preference) */}
        {lastDetectedSound && userProfile.outputPreferences.includes('color') && (
          <div
            className={`absolute inset-3 rounded-[36px] border-[6px] pointer-events-none z-40 animate-pulse duration-300 ${
              lastDetectedSound.severity === 'critical'
                ? 'border-red-500 shadow-[inset_0_0_20px_rgba(239,68,68,0.7)]'
                : lastDetectedSound.severity === 'high'
                ? 'border-orange-500 shadow-[inset_0_0_20px_rgba(249,115,22,0.7)]'
                : lastDetectedSound.severity === 'medium'
                ? 'border-blue-500 shadow-[inset_0_0_20px_rgba(37,99,235,0.6)]'
                : 'border-green-400 shadow-[inset_0_0_15px_rgba(52,211,153,0.5)]'
            }`}
          />
        )}

        {/* Screen inner container */}
        <div className={`relative w-full h-full ${bgClass} ${textClass} ${fontSizeClass} rounded-[32px] overflow-hidden flex flex-col pt-8 pb-4 select-none font-sans transition-all duration-500 ${isVibrating ? 'animate-shake' : ''}`}>
          
          {/* Status bar */}
          <div className={`px-5 py-1.5 flex justify-between items-center text-[11px] border-b bg-slate-50/80 backdrop-blur z-30 ${isHC ? 'text-slate-950 border-slate-900 font-extrabold' : 'text-slate-600 border-slate-100 font-medium'}`}>
            <div className="flex items-center gap-1.5">
              <span>09:41 AM</span>
              {currentScreen !== 'splash' && currentScreen !== 'auth' && currentScreen !== 'onboarding' && currentScreen !== 'preference' && (
                <button
                  onClick={() => {
                    if (!isAppBackgrounded && typeof window !== 'undefined' && 'Notification' in window && Notification.permission === 'default') {
                      try {
                        Notification.requestPermission();
                      } catch (_) {}
                    }
                    setIsAppBackgrounded(!isAppBackgrounded);
                  }}
                  title={isAppBackgrounded ? "Unlock Phone / Open SoundSee" : "Lock Phone / Put SoundSee in Background"}
                  className={`px-1.5 py-0.5 rounded text-[9px] font-bold flex items-center gap-0.5 transition active:scale-95 cursor-pointer ${
                    isAppBackgrounded 
                      ? 'bg-amber-100 text-amber-700 border border-amber-200' 
                      : isHC
                      ? 'bg-white border-2 border-slate-950 text-slate-950'
                      : 'bg-slate-150 hover:bg-slate-200 text-slate-600 border border-slate-250'
                  }`}
                >
                  {isAppBackgrounded ? <Icons.Lock size={9} /> : <Icons.Unlock size={9} />}
                  <span>{isAppBackgrounded ? t('labelLocked') : t('labelActive')}</span>
                </button>
              )}
            </div>
            <div className="flex items-center gap-1.5">
              <Icons.Wifi size={11} />
              <Icons.BatteryFull size={13} />
            </div>
          </div>

          {/* =======================================================
              ALERT BANNER LAYOUTS OVERLAID OVER HISTORY/SETTINGS (NOT HOME SCREEN)
             ======================================================= */}
          {lastDetectedSound && currentScreen !== 'home' && !isAppBackgrounded && (
            <div className="absolute top-12 left-3 right-3 z-50 flex flex-col gap-2 transition-all duration-300 animate-slideDown">
              {userProfile.outputPreferences.includes('icon') && userProfile.outputPreferences.includes('color') ? (
                <div className={`relative p-3.5 rounded-2xl shadow-xl flex flex-col items-center justify-center border ${
                  getFullSeverityBannerBgClass(lastDetectedSound.severity, isHC)
                }`}>
                  <button 
                    onClick={() => {
                      setLastDetectedSound(null);
                      setShowTextAlert(false);
                      setShowIconAlert(false);
                    }} 
                    className="absolute top-2 right-2 text-white/80 hover:text-white p-1 hover:bg-white/20 rounded-full transition cursor-pointer active:scale-95 z-10"
                  >
                    <Icons.X size={16} />
                  </button>
                  
                  <div className="p-2.5 bg-white/20 rounded-2xl flex items-center justify-center my-0.5">
                    <SoundSpecificIcon sound={lastDetectedSound} size={32} overrideColor="text-white" />
                  </div>
                  
                  {userProfile.outputPreferences.includes('text') && (
                    <p className="text-white text-xs font-bold text-center mt-1 truncate max-w-full drop-shadow-sm">
                      {lastDetectedSound.name} — {getPriorityWord(lastDetectedSound.severity)}
                    </p>
                  )}
                </div>
              ) : (
                <div className={`p-2.5 rounded-2xl shadow-xl flex items-center justify-between border gap-2.5 ${
                  isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-white border-slate-200 text-slate-900'
                }`}>
                  <div className="flex items-center gap-2.5 min-w-0 flex-1">
                    {userProfile.outputPreferences.includes('icon') && (
                      <div className={`p-2 rounded-xl shrink-0 border ${getSeverityBgClass(lastDetectedSound.severity)}`}>
                        <SoundSpecificIcon sound={lastDetectedSound} size={20} />
                      </div>
                    )}
                    {userProfile.outputPreferences.includes('text') && (
                      <div className="min-w-0 flex-1">
                        <p className={`text-xs leading-tight break-words ${
                          userProfile.outputPreferences.includes('color')
                            ? getSeverityTextColor(lastDetectedSound.severity, isHC)
                            : isHC ? 'text-slate-950 font-black' : 'text-slate-800 font-bold'
                        }`}>
                          {lastDetectedSound.name} — {getPriorityWord(lastDetectedSound.severity)}
                        </p>
                      </div>
                    )}
                    {!userProfile.outputPreferences.includes('text') && !userProfile.outputPreferences.includes('icon') && (
                      <div className="min-w-0 flex-1">
                        <p className={`text-xs font-bold truncate ${isHC ? 'text-slate-950' : 'text-slate-800'}`}>
                          Sound Detected
                        </p>
                      </div>
                    )}
                  </div>
                  <div className={`text-[9px] font-semibold capitalize px-1.5 py-0.5 rounded-md shrink-0 ${
                    isHC ? 'bg-slate-950 text-white font-bold' : 'bg-indigo-50 text-indigo-600'
                  }`}>
                    {mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                  </div>
                  <button 
                    onClick={() => {
                      setLastDetectedSound(null);
                      setShowTextAlert(false);
                      setShowIconAlert(false);
                    }} 
                    className="text-slate-400 hover:text-slate-700 p-1 hover:bg-slate-100 rounded-full transition cursor-pointer active:scale-95 shrink-0"
                  >
                    <Icons.X size={16} />
                  </button>
                </div>
              )}
            </div>
          )}

          {/* =======================================================
              SCREEN CONTENTS
             ======================================================= */}
          <div className={`flex-1 overflow-y-auto no-scrollbar relative flex flex-col ${bgClass}`}>
            
            {isAppBackgrounded && (
              <div 
                className="absolute inset-0 bg-cover bg-center flex flex-col justify-between p-6 text-white z-40 transition-all duration-500 animate-fadeIn"
                style={{
                  backgroundImage: 'linear-gradient(to bottom, #1e1b4b, #2d103d, #0f172a)'
                }}
              >
                {/* Wallpaper clock */}
                <div className="text-center pt-10">
                  <h1 className="text-4xl font-light font-sans tracking-tight">09:41</h1>
                  <p className="text-xs text-indigo-200 font-medium mt-1">{t('lockscreenDate')}</p>
                </div>
 
                {/* Notification Area */}
                <div className="flex-1 flex flex-col justify-center gap-3 py-6">
                  {lastDetectedSound ? (
                    (lastDetectedSound.severity === 'critical' || lastDetectedSound.severity === 'high') ? (
                      /* FULL-SCREEN INTENT TAKEOVER (Android System-Level Alert Delivery) */
                      <div className="absolute inset-0 bg-slate-950/95 backdrop-blur-xl z-50 flex flex-col justify-between p-5 text-white animate-fadeIn">
                        {/* Header badge */}
                        <div className="flex items-center justify-between">
                          <div className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold flex items-center gap-1.5 border ${
                            lastDetectedSound.severity === 'critical'
                              ? 'bg-red-500/20 text-red-400 border-red-500/40'
                              : 'bg-orange-500/20 text-orange-400 border-orange-500/40'
                          }`}>
                            <span className="w-2 h-2 rounded-full bg-red-500 animate-ping"></span>
                            <span>{lastDetectedSound.severity === 'critical' ? t('criticalAlertOverlayTitle') : t('highAlertOverlayTitle')}</span>
                          </div>
                          <button
                            onClick={() => {
                              setLastDetectedSound(null);
                              setShowTextAlert(false);
                              setShowIconAlert(false);
                            }}
                            className="p-1 text-white/60 hover:text-white rounded-full hover:bg-white/10"
                          >
                            <Icons.X size={16} />
                          </button>
                        </div>

                        {/* Center pulsing radar & icon */}
                        <div className="flex flex-col items-center justify-center my-auto">
                          <div className="relative flex items-center justify-center">
                            <div className={`absolute w-36 h-36 rounded-full animate-ping opacity-30 ${
                              lastDetectedSound.severity === 'critical' ? 'bg-red-500' : 'bg-orange-500'
                            }`}></div>
                            <div className={`absolute w-28 h-28 rounded-full opacity-40 ${
                              lastDetectedSound.severity === 'critical' ? 'bg-red-600' : 'bg-orange-600'
                            }`}></div>
                            <div className={`relative w-20 h-20 rounded-full flex items-center justify-center shadow-2xl ${
                              lastDetectedSound.severity === 'critical' ? 'bg-red-600' : 'bg-orange-500'
                            }`}>
                              <SoundSpecificIcon sound={lastDetectedSound} size={40} overrideColor="text-white" />
                            </div>
                          </div>

                          <h2 className="text-xl font-black text-white text-center mt-5 mb-1">
                            {getSoundName(lastDetectedSound)}
                          </h2>
                          <p className="text-xs text-white/70 font-semibold uppercase tracking-wider text-center">
                            {getCategoryName(lastDetectedSound.category)} • {mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                          </p>

                          {/* Haptic indication */}
                          <div className="mt-3 px-3 py-1 bg-white/10 rounded-full border border-white/10 flex items-center gap-1.5 text-[10px] text-white/80">
                            <Icons.Vibrate size={12} className="animate-pulse" />
                            <span>{t('systemVibrationActive')}</span>
                          </div>
                        </div>

                        {/* Actions */}
                        <div className="flex flex-col gap-2">
                          {userProfile.emergencyContactPhone && (
                            <button
                              onClick={() => {
                                onTriggerEmergency('CALL_EMERGENCY', `Automated alert: ${getSoundName(lastDetectedSound)} detected.`);
                                alert(`${t('toastEmergencyDispatched')} ${userProfile.emergencyContactName || 'contact'} (${userProfile.emergencyContactPhone}).`);
                              }}
                              className="w-full py-2.5 bg-red-600 hover:bg-red-700 active:scale-95 text-white font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition shadow-lg"
                            >
                              <Icons.PhoneCall size={14} />
                              <span>{t('btnEmergencyContact')}</span>
                            </button>
                          )}
                          <div className="grid grid-cols-2 gap-2">
                            <button
                              onClick={() => {
                                setLastDetectedSound(null);
                                setShowTextAlert(false);
                                setShowIconAlert(false);
                              }}
                              className="py-2.5 bg-white/15 hover:bg-white/25 active:scale-95 text-white font-bold rounded-xl text-xs transition border border-white/20 flex items-center justify-center gap-1"
                            >
                              <Icons.BellOff size={13} />
                              <span>{t('btnSnooze')}</span>
                            </button>
                            <button
                              onClick={() => {
                                setLastDetectedSound(null);
                                setShowTextAlert(false);
                                setShowIconAlert(false);
                                setIsAppBackgrounded(false);
                                setCurrentScreen('home');
                              }}
                              className="py-2.5 bg-white hover:bg-slate-100 active:scale-95 text-slate-900 font-extrabold rounded-xl text-xs transition shadow flex items-center justify-center gap-1"
                            >
                              <Icons.CheckCircle2 size={13} />
                              <span>{t('btnDismiss')}</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    ) : (
                      /* HEADS-UP NOTIFICATION (Medium / Low Priority) */
                      userProfile.outputPreferences.includes('icon') && userProfile.outputPreferences.includes('color') ? (
                      <div 
                        onClick={() => {
                          setIsAppBackgrounded(false);
                        }}
                        className={`w-full p-4 rounded-2xl shadow-2xl border transition-all duration-300 hover:scale-[1.02] cursor-pointer animate-slideDown flex flex-col items-center justify-center text-white ${
                          getFullSeverityBannerBgClass(lastDetectedSound.severity, isHC)
                        }`}
                      >
                        <div className="p-3 bg-white/20 rounded-2xl flex items-center justify-center my-1">
                          <SoundSpecificIcon sound={lastDetectedSound} size={36} overrideColor="text-white" />
                        </div>

                        {userProfile.outputPreferences.includes('text') && (
                          <h4 className="font-bold text-xs text-white text-center mt-1 truncate max-w-full drop-shadow-sm">
                            {getSoundName(lastDetectedSound)} — {getPriorityWord(lastDetectedSound.severity)}
                          </h4>
                        )}

                        <div className="mt-2">
                          <span className="text-[9px] font-semibold capitalize px-2 py-0.5 rounded-md bg-white/20 text-white inline-block">
                            {mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                          </span>
                        </div>
                      </div>
                    ) : (
                      <div 
                        onClick={() => {
                          // Open app on notification click
                          setIsAppBackgrounded(false);
                        }}
                        className={`w-full bg-white/95 backdrop-blur-md text-slate-900 p-3 rounded-2xl shadow-2xl border-l-[6px] transition-all duration-300 hover:scale-[1.02] cursor-pointer animate-slideDown flex items-center justify-between gap-2.5 ${
                          lastDetectedSound.severity === 'critical'
                            ? 'border-red-600'
                            : lastDetectedSound.severity === 'high'
                            ? 'border-orange-500'
                            : lastDetectedSound.severity === 'medium'
                            ? 'border-blue-500'
                            : 'border-green-600'
                        }`}
                      >
                        <div className="flex items-center gap-2.5 min-w-0 flex-1">
                          {userProfile.outputPreferences.includes('icon') && (
                            <div className={`p-2 rounded-xl shrink-0 border ${getSeverityBgClass(lastDetectedSound.severity)}`}>
                              <SoundSpecificIcon sound={lastDetectedSound} size={20} />
                            </div>
                          )}
                          <div className="flex-1 min-w-0 text-left">
                            {userProfile.outputPreferences.includes('text') ? (
                              <h4 className={`text-xs leading-snug break-words ${
                                userProfile.outputPreferences.includes('color')
                                  ? getSeverityTextColor(lastDetectedSound.severity, isHC)
                                  : 'text-slate-900 font-bold'
                              }`}>
                                {getSoundName(lastDetectedSound)} — {getPriorityWord(lastDetectedSound.severity)}
                              </h4>
                            ) : (
                              <h4 className="font-bold text-xs text-slate-900 leading-snug truncate">
                                {t('soundDetected')}
                              </h4>
                            )}
                          </div>
                        </div>

                        <div className={`text-[9px] font-semibold capitalize px-1.5 py-0.5 rounded-md shrink-0 ${
                          isHC ? 'bg-slate-950 text-white font-bold' : 'bg-indigo-50 text-indigo-600'
                        }`}>
                          {mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                        </div>
                      </div>
                    )
                    )
                  ) : (
                    <div className="text-center text-white/40 text-[10px] font-medium py-10">
                      {t('noNotifications')}
                    </div>
                  )}
                </div>
 
                {/* Bottom unlock hint */}
                <div className="text-center pb-4">
                  <button 
                    onClick={() => setIsAppBackgrounded(false)}
                    className="bg-white/10 hover:bg-white/20 active:scale-95 backdrop-blur border border-white/10 px-4 py-2 rounded-full text-[10px] font-bold tracking-wider uppercase transition cursor-pointer"
                  >
                    {t('btnClickUnlock')}
                  </button>
                </div>
              </div>
            )}

            {/* SCREEN 1: SPLASH SCREEN */}
            {currentScreen === 'splash' && (
              <div className="absolute inset-0 bg-indigo-600 flex flex-col items-center justify-center p-6 text-white z-20">
                <div className="w-20 h-20 bg-white rounded-full flex items-center justify-center mb-6 shadow-lg animate-bounce">
                  <Icons.Ear size={42} className="text-indigo-600" />
                </div>
                <h1 className="font-display text-4xl font-extrabold tracking-tight mb-2">{t('appName')}</h1>
                <p className="text-indigo-100 text-sm font-medium text-center max-w-[200px]">
                  {t('appSubtitle')}
                </p>
                <div className="mt-12 flex gap-1.5">
                  <div className="w-2 h-2 bg-white/40 rounded-full animate-pulse"></div>
                  <div className="w-2 h-2 bg-white/70 rounded-full animate-pulse delay-100"></div>
                  <div className="w-2 h-2 bg-white rounded-full animate-pulse delay-200"></div>
                </div>
              </div>
            )}

            {/* SCREEN 2: AUTH LANDING */}
            {currentScreen === 'auth' && (
              <div className="flex-1 flex flex-col p-6 justify-between animate-fadeIn">
                <div className="text-center pt-8">
                  <div className={`inline-flex p-5 rounded-full mb-6 ${isHC ? 'bg-slate-950 text-white' : 'bg-indigo-50 text-indigo-600'}`}>
                    <Icons.User size={48} />
                  </div>
                  <h2 className={`font-display text-2xl font-bold mb-2 ${isHC ? 'text-slate-950' : 'text-slate-800'}`}>{t('welcomeTitle')}</h2>
                  <p className={`text-xs px-4 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                    {t('welcomeDesc')}
                  </p>
                </div>

                <div className="flex flex-col gap-3">
                  <button
                    onClick={() => setCurrentScreen('onboarding')}
                    className={`w-full font-semibold py-3.5 rounded-2xl transition active:scale-95 text-sm shadow-sm ${
                      isHC 
                        ? 'bg-slate-950 text-white hover:bg-black border-2 border-slate-950' 
                        : 'bg-indigo-600 text-white hover:bg-indigo-700'
                    }`}
                  >
                    {t('btnGetStarted')}
                  </button>
                  <button
                    onClick={() => {
                      // Skip with sample profile
                      setUserProfile({
                        id: 'usr_123',
                        name: 'John Doe',
                        age: 28,
                        phone: '+919876543210',
                        email: 'deekshakuselan23@gmail.com',
                        micAccess: true,
                        termsAccepted: true,
                        privacyPolicyAccepted: true,
                        outputPreferences: ['text', 'icon', 'color'],
                        emergencyContactName: '',
                        emergencyContactPhone: '',
                        muteLowAlerts: false,
                        gpsAutoDetect: false,
                        savedLocations: [
                          { id: 'loc_home', name: 'Home', address: '124 Maple Street, Apt 3B', createdAt: Date.now() - 100000 },
                          { id: 'loc_work', name: 'Office', address: '742 Evergreen Tech Park, Tower B', createdAt: Date.now() - 50000 }
                        ],
                        language: 'English',
                        textSize: 'medium',
                        highContrast: false,
                      });
                      setCurrentScreen('home');
                    }}
                    className={`w-full font-semibold py-3.5 rounded-2xl transition active:scale-95 text-sm ${
                      isHC
                        ? 'bg-white text-slate-950 border-2 border-slate-950 font-extrabold hover:bg-slate-50'
                        : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    {t('btnGuestDemo')}
                  </button>
                </div>
              </div>
            )}

            {/* SCREEN 3: ONBOARDING */}
            {currentScreen === 'onboarding' && (
              <div className="flex-1 flex flex-col p-6 animate-fadeIn">
                <div className="mb-4">
                  <h2 className="font-display text-xl font-bold">{t('createProfileTitle')}</h2>
                  <p className={`text-xs ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>{t('createProfileDesc')}</p>
                </div>

                <form onSubmit={handleOnboardingSubmit} className="flex-1 flex flex-col justify-between">
                  <div className="space-y-3.5">
                    <div>
                      <label className={`block text-[10px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}`}>{t('labelName')}</label>
                      <input
                        type="text"
                        required
                        value={formName}
                        onChange={e => setFormName(e.target.value)}
                        className={`w-full px-3.5 py-2.5 text-sm rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                        placeholder={t('placeholderName')}
                      />
                    </div>

                    <div className="grid grid-cols-12 gap-3">
                      <div className="col-span-4">
                        <label className={`block text-[10px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}`}>{t('labelAge')}</label>
                        <input
                          type="number"
                          required
                          value={formAge}
                          onChange={e => setFormAge(e.target.value)}
                          className={`w-full px-3 py-2.5 text-sm rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                          placeholder={t('placeholderAge')}
                        />
                      </div>
                      <div className="col-span-8">
                        <label className={`block text-[10px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}`}>{t('labelPhone')}</label>
                        <div className="flex gap-1">
                          <select
                            value={formCountryCode}
                            onChange={e => setFormCountryCode(e.target.value)}
                            className={`rounded-xl px-1.5 py-2.5 text-xs focus:border-indigo-500 focus:outline-none font-semibold shrink-0 select-none cursor-pointer w-[72px] ${inputClass}`}
                          >
                            <option value="+91">🇮🇳 +91</option>
                            <option value="+1">🇺🇸 +1</option>
                            <option value="+44">🇬🇧 +44</option>
                            <option value="+61">🇦🇺 +61</option>
                            <option value="+971">🇦🇪 +971</option>
                          </select>
                          <input
                            type="text"
                            required
                            value={formPhone}
                            onChange={e => {
                              const cleanVal = e.target.value.replace(/\D/g, '').slice(0, 10);
                              setFormPhone(cleanVal);
                            }}
                            className={`w-full min-w-0 px-2.5 py-2.5 text-sm rounded-xl focus:border-indigo-500 focus:outline-none font-mono ${inputClass}`}
                            placeholder={t('placeholderPhone')}
                            maxLength={10}
                          />
                        </div>
                      </div>
                    </div>

                    <div>
                      <label className={`block text-[10px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}`}>{t('labelEmail')}</label>
                      <input
                        type="email"
                        value={formEmail}
                        onChange={e => setFormEmail(e.target.value)}
                        className={`w-full px-3.5 py-2.5 text-sm rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                        placeholder={t('placeholderEmail')}
                      />
                    </div>

                    {/* Checkboxes */}
                    <div className="pt-2 space-y-2">
                      <label className="flex items-start gap-2.5 cursor-pointer">
                        <input
                          type="checkbox"
                          required
                          checked={formMic}
                          onChange={e => setFormMic(e.target.checked)}
                          className="mt-0.5 accent-indigo-600 rounded text-indigo-600"
                        />
                        <span className={`text-[11px] leading-tight ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-600'}`}>{t('checkboxMic')}</span>
                      </label>

                      <label className="flex items-start gap-2.5 cursor-pointer">
                        <input
                          type="checkbox"
                          required
                          checked={formLocation}
                          onChange={e => setFormLocation(e.target.checked)}
                          className="mt-0.5 accent-indigo-600 rounded text-indigo-600"
                        />
                        <span className={`text-[11px] leading-tight ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-600'}`}>{t('checkboxLocation')}</span>
                      </label>

                      <label className="flex items-start gap-2.5 cursor-pointer">
                        <input
                          type="checkbox"
                          required
                          checked={formTerms}
                          onChange={e => setFormTerms(e.target.checked)}
                          className="mt-0.5 accent-indigo-600 rounded text-indigo-600"
                        />
                        <span className={`text-[11px] leading-tight ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-600'}`}>{t('checkboxTerms')}</span>
                      </label>

                      <label className="flex items-start gap-2.5 cursor-pointer">
                        <input
                          type="checkbox"
                          required
                          checked={formPrivacy}
                          onChange={e => setFormPrivacy(e.target.checked)}
                          className="mt-0.5 accent-indigo-600 rounded text-indigo-600"
                        />
                        <span className={`text-[11px] leading-tight ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-600'}`}>{t('checkboxPrivacy')}</span>
                      </label>
                    </div>
                  </div>

                  <button
                    type="submit"
                    className={`w-full font-semibold py-3.5 rounded-2xl transition active:scale-95 text-sm mt-4 ${
                      isHC 
                        ? 'bg-slate-950 text-white hover:bg-black border-2 border-slate-950 font-bold' 
                        : 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-sm'
                    }`}
                  >
                    {t('btnNextPrefs')}
                  </button>
                </form>
              </div>
            )}

            {/* SCREEN 4: OUTPUT STYLE PREFERENCE */}
            {currentScreen === 'preference' && (
              <div className="flex-1 flex flex-col p-6 justify-between animate-fadeIn">
                <div>
                  <h2 className="font-display text-xl font-bold mb-1">{t('prefTitle')}</h2>
                  <p className={`text-xs mb-6 ${isHC ? 'text-slate-950 font-semibold' : 'text-slate-500'}`}>{t('prefDesc')}</p>

                  <div className="space-y-3">
                    {/* Preference Card: Text */}
                    <div
                      onClick={() => handleTogglePref('text')}
                      className={`p-3.5 rounded-2xl border-2 cursor-pointer transition flex items-center gap-3.5 ${
                        userProfile.outputPreferences.includes('text')
                          ? isHC 
                            ? 'border-slate-950 bg-slate-950 text-white shadow-none'
                            : 'border-indigo-600 bg-indigo-50/50 text-indigo-900'
                          : isHC
                            ? 'border-slate-400 bg-white text-slate-900 hover:border-slate-600 font-bold'
                            : 'border-slate-100 bg-white text-slate-700 hover:border-slate-200'
                      }`}
                    >
                      <div className={`p-2.5 rounded-xl ${
                        userProfile.outputPreferences.includes('text')
                          ? isHC ? 'bg-slate-900 text-white' : 'bg-indigo-100 text-indigo-700'
                          : isHC ? 'bg-slate-100 text-slate-900 border border-slate-300' : 'bg-slate-50 text-slate-500'
                      }`}>
                        <Icons.Type size={20} />
                      </div>
                      <div className="flex-1 text-left">
                        <h4 className="font-bold text-xs">{t('prefTextTitle')}</h4>
                        <p className={`text-[10px] ${
                          userProfile.outputPreferences.includes('text') && isHC ? 'text-slate-200' : isHC ? 'text-slate-700 font-medium' : 'text-slate-400'
                        }`}>{t('prefTextDesc')}</p>
                      </div>
                      <div className={`w-5 h-5 rounded-md border flex items-center justify-center ${
                        userProfile.outputPreferences.includes('text')
                          ? isHC ? 'bg-white border-white text-slate-950 font-black' : 'bg-indigo-600 border-indigo-600 text-white'
                          : isHC ? 'border-slate-400 bg-white' : 'border-slate-300'
                      }`}>
                        {userProfile.outputPreferences.includes('text') && <Icons.Check size={12} />}
                      </div>
                    </div>

                    {/* Preference Card: Icon */}
                    <div
                      onClick={() => handleTogglePref('icon')}
                      className={`p-3.5 rounded-2xl border-2 cursor-pointer transition flex items-center gap-3.5 ${
                        userProfile.outputPreferences.includes('icon')
                          ? isHC 
                            ? 'border-slate-950 bg-slate-950 text-white shadow-none'
                            : 'border-indigo-600 bg-indigo-50/50 text-indigo-900'
                          : isHC
                            ? 'border-slate-400 bg-white text-slate-900 hover:border-slate-600 font-bold'
                            : 'border-slate-100 bg-white text-slate-700 hover:border-slate-200'
                      }`}
                    >
                      <div className={`p-2.5 rounded-xl ${
                        userProfile.outputPreferences.includes('icon')
                          ? isHC ? 'bg-slate-900 text-white' : 'bg-indigo-100 text-indigo-700'
                          : isHC ? 'bg-slate-100 text-slate-900 border border-slate-300' : 'bg-slate-50 text-slate-500'
                      }`}>
                        <Icons.Image size={20} />
                      </div>
                      <div className="flex-1 text-left">
                        <h4 className="font-bold text-xs">{t('prefIconTitle')}</h4>
                        <p className={`text-[10px] ${
                          userProfile.outputPreferences.includes('icon') && isHC ? 'text-slate-200' : isHC ? 'text-slate-700 font-medium' : 'text-slate-400'
                        }`}>{t('prefIconDesc')}</p>
                      </div>
                      <div className={`w-5 h-5 rounded-md border flex items-center justify-center ${
                        userProfile.outputPreferences.includes('icon')
                          ? isHC ? 'bg-white border-white text-slate-950 font-black' : 'bg-indigo-600 border-indigo-600 text-white'
                          : isHC ? 'border-slate-400 bg-white' : 'border-slate-300'
                      }`}>
                        {userProfile.outputPreferences.includes('icon') && <Icons.Check size={12} />}
                      </div>
                    </div>

                    {/* Preference Card: Color Coded */}
                    <div
                      onClick={() => handleTogglePref('color')}
                      className={`p-3.5 rounded-2xl border-2 cursor-pointer transition flex items-center gap-3.5 ${
                        userProfile.outputPreferences.includes('color')
                          ? isHC 
                            ? 'border-slate-950 bg-slate-950 text-white shadow-none'
                            : 'border-indigo-600 bg-indigo-50/50 text-indigo-900'
                          : isHC
                            ? 'border-slate-400 bg-white text-slate-900 hover:border-slate-600 font-bold'
                            : 'border-slate-100 bg-white text-slate-700 hover:border-slate-200'
                      }`}
                    >
                      <div className={`p-2.5 rounded-xl ${
                        userProfile.outputPreferences.includes('color')
                          ? isHC ? 'bg-slate-900 text-white' : 'bg-indigo-100 text-indigo-700'
                          : isHC ? 'bg-slate-100 text-slate-900 border border-slate-300' : 'bg-slate-50 text-slate-500'
                      }`}>
                        <Icons.Palette size={20} />
                      </div>
                      <div className="flex-1 text-left">
                        <h4 className="font-bold text-xs">{t('prefColorTitle')}</h4>
                        <p className={`text-[10px] ${
                          userProfile.outputPreferences.includes('color') && isHC ? 'text-slate-200' : isHC ? 'text-slate-700 font-medium' : 'text-slate-400'
                        }`}>{t('prefColorDesc')}</p>
                      </div>
                      <div className={`w-5 h-5 rounded-md border flex items-center justify-center ${
                        userProfile.outputPreferences.includes('color')
                          ? isHC ? 'bg-white border-white text-slate-950 font-black' : 'bg-indigo-600 border-indigo-600 text-white'
                          : isHC ? 'border-slate-400 bg-white' : 'border-slate-300'
                      }`}>
                        {userProfile.outputPreferences.includes('color') && <Icons.Check size={12} />}
                      </div>
                    </div>
                  </div>
                </div>

                <button
                  onClick={() => setCurrentScreen('onboarding-locations')}
                  disabled={userProfile.outputPreferences.length === 0}
                  className={`w-full font-semibold py-3.5 rounded-2xl transition active:scale-95 text-sm disabled:opacity-40 disabled:cursor-not-allowed ${
                    isHC 
                      ? 'bg-slate-950 text-white hover:bg-black border-2 border-slate-950 font-bold' 
                      : 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-sm'
                  }`}
                >
                  {t('btnNextLocations')}
                </button>
              </div>
            )}

            {/* SCREEN 4B: ONBOARDING - SAVED LOCATIONS (OPTIONAL STEP) */}
            {currentScreen === 'onboarding-locations' && (
              <div className="flex-1 flex flex-col p-5 justify-between animate-fadeIn overflow-y-auto no-scrollbar">
                <div>
                  <div className="text-center pt-2 pb-3">
                    <div className={`inline-flex p-3.5 rounded-full mb-2 ${isHC ? 'bg-slate-950 text-white' : 'bg-indigo-50 text-indigo-600'}`}>
                      <Icons.MapPin size={26} />
                    </div>
                    <h2 className={`font-display text-xl font-bold ${isHC ? 'text-slate-950' : 'text-slate-800'}`}>
                      {t('onboardingLocationsTitle')}
                    </h2>
                    <p className={`text-xs mt-1 px-1 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('onboardingLocationsDesc')}
                    </p>
                  </div>

                  {/* Form to add a location */}
                  <div className={`p-3.5 rounded-2xl border text-left mb-3 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-white border-slate-200 text-slate-800 shadow-sm'}`}>
                    <div className="mb-2.5">
                      <span className={`text-[9px] font-bold uppercase tracking-wider block mb-1.5 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                        {t('quickSuggestions')}
                      </span>
                      <div className="flex flex-wrap gap-1.5">
                        {[
                          { label: t('suggestionHome'), val: 'Home', icon: Icons.Home },
                          { label: t('suggestionSchoolCollege'), val: 'School / College', icon: Icons.GraduationCap },
                          { label: t('suggestionOffice'), val: 'Office', icon: Icons.Briefcase },
                          { label: t('suggestionGym'), val: 'Gym', icon: Icons.Dumbbell },
                        ].map(s => {
                          const SuggestionIcon = s.icon;
                          return (
                            <button
                              key={s.val}
                              type="button"
                              onClick={() => setOnboardingLocName(s.label)}
                              className={`inline-flex items-center gap-1 px-2 py-1 rounded-lg text-[10px] font-bold transition active:scale-95 cursor-pointer ${
                                onboardingLocName === s.label
                                  ? isHC ? 'bg-slate-950 text-white border border-slate-950' : 'bg-indigo-600 text-white'
                                  : isHC ? 'bg-white border border-slate-950 text-slate-950 hover:bg-slate-100' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                              }`}
                            >
                              <SuggestionIcon size={11} className="shrink-0" />
                              <span>{s.label}</span>
                            </button>
                          );
                        })}
                      </div>
                    </div>

                    <div className="space-y-2.5">
                      <div>
                        <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                          {t('labelLocationName')}
                        </label>
                        <input
                          type="text"
                          value={onboardingLocName}
                          onChange={e => setOnboardingLocName(e.target.value)}
                          placeholder={t('placeholderLocationName')}
                          className={`w-full px-3 py-2 text-xs rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                        />
                      </div>

                      <div>
                        <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                          {t('labelLocationAddress')}
                        </label>
                        <input
                          type="text"
                          value={onboardingLocAddress}
                          onChange={e => setOnboardingLocAddress(e.target.value)}
                          placeholder={t('placeholderLocationAddress')}
                          className={`w-full px-3 py-2 text-xs rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                        />
                      </div>

                      <button
                        type="button"
                        onClick={() => {
                          if (onboardingLocName.trim() && onboardingLocAddress.trim()) {
                            handleAddLocation(onboardingLocName, onboardingLocAddress);
                            setOnboardingLocName('');
                            setOnboardingLocAddress('');
                          } else {
                            alert("Please enter both a Location Name and an Address.");
                          }
                        }}
                        disabled={!onboardingLocName.trim() || !onboardingLocAddress.trim()}
                        className={`w-full flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold transition active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed ${
                          isHC
                            ? 'bg-slate-950 text-white border-2 border-slate-950 font-extrabold'
                            : 'bg-indigo-600 text-white hover:bg-indigo-700'
                        }`}
                      >
                        <Icons.Plus size={14} />
                        <span>{t('btnAddLocation')}</span>
                      </button>
                    </div>
                  </div>

                  {/* List of currently saved locations in this step */}
                  {(userProfile.savedLocations && userProfile.savedLocations.length > 0) && (
                    <div className="space-y-1.5 mb-3">
                      <span className={`text-[9px] font-bold uppercase tracking-wider block text-left ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                        {t('sectionSavedLocations')} ({userProfile.savedLocations.length})
                      </span>
                      {userProfile.savedLocations.map(loc => (
                        <div
                          key={loc.id}
                          className={`p-2.5 rounded-xl border flex items-center justify-between text-left ${
                            isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border-slate-200 text-slate-800'
                          }`}
                        >
                          <div className="flex items-start gap-2 min-w-0 flex-1 pr-2">
                            <div className={`p-1.5 rounded-lg shrink-0 ${isHC ? 'bg-slate-950 text-white' : 'bg-indigo-100 text-indigo-700'}`}>
                              <Icons.MapPin size={13} />
                            </div>
                            <div className="min-w-0">
                              <div className="text-xs font-bold truncate">{loc.name}</div>
                              <div className={`text-[10px] truncate leading-tight ${isHC ? 'text-slate-800 font-medium' : 'text-slate-500'}`}>{loc.address}</div>
                            </div>
                          </div>
                          <button
                            type="button"
                            onClick={() => handleDeleteLocation(loc.id)}
                            className="text-slate-400 hover:text-rose-600 p-1 rounded-lg transition active:scale-95 cursor-pointer"
                            title="Remove"
                          >
                            <Icons.Trash2 size={13} />
                          </button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Bottom Action buttons */}
                <div className="space-y-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setCurrentScreen('home')}
                    className={`w-full font-semibold py-3 rounded-2xl transition active:scale-95 text-sm shadow-sm ${
                      isHC
                        ? 'bg-slate-950 text-white hover:bg-black border-2 border-slate-950 font-bold'
                        : 'bg-indigo-600 text-white hover:bg-indigo-700'
                    }`}
                  >
                    {t('btnSaveAndContinue')}
                  </button>
                  <button
                    type="button"
                    onClick={() => setCurrentScreen('home')}
                    className={`w-full py-2.5 rounded-xl text-xs font-bold transition active:scale-95 ${
                      isHC
                        ? 'bg-white text-slate-950 border-2 border-slate-950 hover:bg-slate-50 font-extrabold'
                        : 'text-slate-500 hover:text-slate-700 hover:bg-slate-100'
                    }`}
                  >
                    {t('btnSkipForNow')}
                  </button>
                </div>
              </div>
            )}

            {/* SCREEN 5: HOME SCREEN */}
            {currentScreen === 'home' && (
              <div className="flex flex-col p-5 animate-fadeIn">
                {/* Mode description header */}
                <div className={`flex items-center justify-between mb-3 p-2.5 rounded-2xl shrink-0 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold' : 'bg-slate-100/50 border border-slate-100'}`}>
                  <div className="flex items-center gap-2">
                    <div className={`p-1.5 rounded-lg ${isHC ? 'bg-slate-950 text-white' : 'bg-indigo-50 text-indigo-600'}`}>
                      {mode === 'indoor' ? <Icons.Home size={16} /> : <Icons.Compass size={16} />}
                    </div>
                    <div className="text-left">
                      <div className={`text-[10px] font-bold uppercase tracking-wider leading-none ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('scanningLabel')}</div>
                      <div className={`font-bold text-[13px] leading-tight ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-700'}`}>
                        {mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                      </div>
                    </div>
                  </div>

                  <div className={`flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full border ${isHC ? 'text-green-800 bg-white border-2 border-green-800 font-extrabold' : 'text-green-600 bg-green-50 border-green-100'}`}>
                    <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse"></span>
                    <span>{t('gpsActive')}</span>
                  </div>
                </div>

                {/* Sub-toggle buttons */}
                <div className={`flex p-1 rounded-xl mb-4 text-xs font-bold shrink-0 ${isHC ? 'bg-white border-2 border-slate-950' : 'bg-slate-200/60'}`}>
                  <button
                    onClick={() => {
                      setMode('indoor');
                      setLastDetectedSound(null);
                    }}
                    className={`flex-1 py-2 text-center rounded-lg transition-all ${
                      mode === 'indoor' 
                        ? isHC 
                          ? 'bg-slate-950 text-white font-black' 
                          : 'bg-white text-indigo-600 shadow-sm' 
                        : isHC 
                          ? 'bg-white text-slate-950 font-bold border border-transparent'
                          : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    {t('btnIndoor')}
                  </button>
                  <button
                    onClick={() => {
                      setMode('outdoor');
                      setLastDetectedSound(null);
                    }}
                    className={`flex-1 py-2 text-center rounded-lg transition-all ${
                      mode === 'outdoor' 
                        ? isHC 
                          ? 'bg-slate-950 text-white font-black' 
                          : 'bg-white text-indigo-600 shadow-sm' 
                        : isHC 
                          ? 'bg-white text-slate-950 font-bold border border-transparent'
                          : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    {t('btnOutdoor')}
                  </button>
                </div>

                {/* Main Mic Ripple Section (Styled after Immersive UI design) */}
                <div className="flex flex-col items-center justify-center py-4 relative shrink-0">
                  <div className="relative flex items-center justify-center w-full min-h-[200px]">
                    {/* Concentric Listening Rings from design HTML */}
                    {isListening ? (
                      <>
                        <div className={`absolute w-[200px] h-[200px] border rounded-full animate-pulse opacity-90 transition-all duration-300 ${
                          lastDetectedSound
                            ? lastDetectedSound.severity === 'critical'
                              ? 'border-red-300 bg-red-50/10'
                              : lastDetectedSound.severity === 'high'
                              ? 'border-orange-300 bg-orange-50/10'
                              : lastDetectedSound.severity === 'medium'
                              ? 'border-blue-300 bg-blue-50/10'
                              : 'border-green-300 bg-green-50/10'
                            : isHC ? 'border-slate-950/45 bg-slate-100/10' : 'border-indigo-100'
                        }`}></div>
                        <div className={`absolute w-[150px] h-[150px] border-2 rounded-full animate-ping opacity-40 transition-all duration-300 ${
                          lastDetectedSound
                            ? lastDetectedSound.severity === 'critical'
                              ? 'border-red-200/50'
                              : lastDetectedSound.severity === 'high'
                              ? 'border-orange-200/50'
                              : lastDetectedSound.severity === 'medium'
                              ? 'border-blue-200/50'
                              : 'border-green-200/50'
                            : isHC ? 'border-slate-950/30' : 'border-indigo-100/50'
                        }`}></div>
                        
                        {/* Core Ambient Inner Ring */}
                        <div className={`absolute w-[110px] h-[110px] border-2 rounded-full shadow-inner z-0 transition-all duration-300 ${
                          lastDetectedSound
                            ? lastDetectedSound.severity === 'critical'
                              ? 'bg-red-50 border-red-100/80'
                              : lastDetectedSound.severity === 'high'
                              ? 'bg-orange-50 border-orange-100/80'
                              : lastDetectedSound.severity === 'medium'
                              ? 'bg-blue-50 border-blue-100/80'
                              : 'bg-green-50 border-green-100/80'
                            : isHC ? 'bg-white border-2 border-slate-950' : 'bg-indigo-50 border-indigo-100/80'
                        }`} />
                      </>
                    ) : (
                      <div className={`absolute w-[110px] h-[110px] border-2 rounded-full shadow-inner ${isHC ? 'bg-white border-2 border-slate-950' : 'bg-slate-100 border-slate-200'}`} />
                    )}

                    {/* Microphone button inside concentric rings */}
                    <button
                      onClick={() => {
                        if (lastDetectedSound) {
                          setLastDetectedSound(null);
                          setShowTextAlert(false);
                          setShowIconAlert(false);
                        } else {
                          setIsListening(!isListening);
                        }
                      }}
                      className={`relative w-14 h-14 rounded-full flex items-center justify-center transition-all duration-500 shadow-lg z-10 hover:scale-105 active:scale-95 ${
                        lastDetectedSound
                          ? userProfile.outputPreferences.includes('icon')
                            ? lastDetectedSound.severity === 'critical'
                              ? isHC ? 'bg-red-800 text-white border-2 border-red-950' : 'bg-red-600 text-white hover:bg-red-700'
                              : lastDetectedSound.severity === 'high'
                              ? isHC ? 'bg-orange-600 text-white border-2 border-orange-950 font-bold' : 'bg-orange-500 text-white hover:bg-orange-600'
                              : lastDetectedSound.severity === 'medium'
                              ? isHC ? 'bg-blue-600 text-white border-2 border-blue-950 font-bold' : 'bg-blue-600 text-white hover:bg-blue-700'
                              : isHC ? 'bg-green-800 text-white border-2 border-green-950' : 'bg-green-600 text-white hover:bg-green-700'
                            : isHC ? 'bg-slate-950 text-white border-2 border-slate-950' : 'bg-slate-700 text-white'
                          : isListening
                          ? isHC ? 'bg-slate-950 text-white border-2 border-slate-950' : 'bg-indigo-600 text-white hover:bg-indigo-700'
                          : isHC ? 'bg-white text-slate-950 border-2 border-slate-950 font-extrabold hover:bg-slate-50' : 'bg-slate-300 text-slate-700 hover:bg-slate-400'
                      }`}
                    >
                      {/* Idle mic icon */}
                      <div className={`absolute inset-0 flex items-center justify-center transition-all duration-500 ${
                        lastDetectedSound 
                          ? 'opacity-0 scale-50 rotate-90 pointer-events-none' 
                          : 'opacity-100 scale-100 rotate-0'
                      }`}>
                        {isListening ? <Icons.Mic size={20} /> : <Icons.MicOff size={20} />}
                      </div>
                      
                      {/* Detected sound icon */}
                      <div className={`absolute inset-0 flex items-center justify-center transition-all duration-500 ${
                        lastDetectedSound && userProfile.outputPreferences.includes('icon')
                          ? 'opacity-100 scale-100 rotate-0' 
                          : 'opacity-0 scale-50 -rotate-90 pointer-events-none'
                      }`}>
                        {lastDetectedSound && userProfile.outputPreferences.includes('icon') && (
                          <SoundSpecificIcon sound={lastDetectedSound} size={22} className="text-white" />
                        )}
                      </div>
                    </button>
                  </div>

                  <div className="text-center mt-2.5 z-10 flex flex-col items-center">
                    {lastDetectedSound ? (
                      <div className="animate-fadeIn flex flex-col items-center">
                        {userProfile.outputPreferences.includes('text') && (
                          <p className={`text-[13px] tracking-tight capitalize ${
                            userProfile.outputPreferences.includes('color')
                              ? getSeverityTextColor(lastDetectedSound.severity, isHC)
                              : isHC ? 'text-slate-950 font-black' : 'text-slate-900 font-bold'
                          }`}>
                            {getSoundName(lastDetectedSound)} — {getPriorityWord(lastDetectedSound.severity)}
                          </p>
                        )}
                        {!userProfile.outputPreferences.includes('text') && userProfile.outputPreferences.includes('icon') && (
                          <p className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-700'}`}>
                            {t('soundDetected')}
                          </p>
                        )}
                        {!userProfile.outputPreferences.includes('text') && !userProfile.outputPreferences.includes('icon') && (
                          <p className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-700'}`}>
                            {t('alertActive')}
                          </p>
                        )}
                      </div>
                    ) : (
                      <p className={`text-[12px] font-bold ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-800'}`}>
                        {isListening ? t('statusListening') : t('statusPaused')}
                      </p>
                    )}
                  </div>
                </div>

                {/* Emergency controls inside simulator (Outdoor + Critical alert triggers) */}
                {mode === 'outdoor' && lastDetectedSound && lastDetectedSound.severity === 'critical' && (
                  <div className={`mb-4 p-3 rounded-2xl flex flex-col gap-2 animate-bounce shrink-0 ${isHC ? 'bg-white border-2 border-red-800 text-slate-950' : 'bg-red-50 border border-red-100'}`}>
                    <div className="flex items-center gap-1.5 text-xs font-bold text-red-700 justify-center">
                      <Icons.ShieldAlert size={14} />
                      <span>{t('safetyHelpers')}</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => {
                          if (!userProfile.emergencyContactName || !userProfile.emergencyContactPhone) {
                            alert(`⚠️ ${t('alertSafetyDispatchRequired')}`);
                            setCurrentScreen('vibration');
                          } else {
                            onTriggerEmergency(
                              'CALL_EMERGENCY', 
                              `Urgent sound registered: '${getSoundName(lastDetectedSound)}'. Emergency dispatch invoked for contact: ${userProfile.emergencyContactName} (${userProfile.emergencyContactPhone}).`
                            );
                            alert(`${t('toastEmergencyDispatched')} ${userProfile.emergencyContactName} (${userProfile.emergencyContactPhone})`);
                          }
                        }}
                        className={`font-bold py-2 rounded-xl text-[10px] flex items-center justify-center gap-1 active:scale-95 transition ${
                          isHC ? 'bg-red-800 text-white border-2 border-red-950 hover:bg-red-900' : 'bg-red-600 text-white hover:bg-red-700'
                        }`}
                      >
                        <Icons.PhoneCall size={11} />
                        <span>{t('btnCallEmergency')}</span>
                      </button>
                      <button
                        onClick={() => {
                          onTriggerEmergency('REACHED_SAFE_SPOT', `${userProfile.name} reports reaching a safe location.`);
                          alert("Status marked: Reached Safe Spot!");
                          setLastDetectedSound(null);
                        }}
                        className={`font-bold py-2 rounded-xl text-[10px] flex items-center justify-center gap-1 active:scale-95 transition ${
                          isHC ? 'bg-green-800 text-white border-2 border-green-950 hover:bg-green-900' : 'bg-green-600 text-white hover:bg-green-700'
                        }`}
                      >
                        <Icons.CheckCircle size={11} />
                        <span>{t('btnReachedSafe')}</span>
                      </button>
                    </div>
                  </div>
                )}

                {/* Interactive Sound Trigger Dropdown directly inside phone mockup */}
                <div className={`border p-3 rounded-2xl mb-4 text-left shrink-0 ${isHC ? 'bg-white border-2 border-slate-950' : 'bg-slate-100/85 border-slate-200/60'}`}>
                  <div className="text-[10px] font-bold uppercase mb-1.5 flex items-center gap-1">
                    <Icons.Volume2 size={10} className="text-indigo-600" />
                    <span className={isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}>{t('triggerSoundWave')}</span>
                  </div>
                  <div className="flex gap-1.5">
                    <select
                      value={selectedSimSoundId}
                      onChange={e => {
                        setSelectedSimSoundId(e.target.value);
                        const sound = SOUND_TAXONOMY.find(s => s.id === e.target.value);
                        if (sound) {
                          onTriggerSound(sound);
                        }
                      }}
                      className={`w-full text-[11px] px-2 py-1.5 rounded-lg focus:border-indigo-500 focus:outline-none ${inputClass}`}
                    >
                      <option value="">{t('selectSoundPlaceholder')}</option>
                      {SOUND_TAXONOMY.filter(s => s.environment === mode).map(s => (
                        <option key={s.id} value={s.id}>
                          {getSoundName(s)} ({getPriorityWord(s.severity)})
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Recent logs inline overview */}
                <div className={`border-t pt-3.5 ${isHC ? 'border-slate-350' : 'border-slate-100'}`}>
                  <div className="flex justify-between items-center mb-2">
                    <span className={`text-[11px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}`}>{t('recentHistory')}</span>
                    <button onClick={() => setCurrentScreen('history')} className={`text-[10px] font-bold flex items-center gap-0.5 ${isHC ? 'text-slate-950 font-extrabold border-b border-slate-950' : 'text-indigo-600'}`}>
                      <span>{t('viewAll')}</span>
                      <Icons.ChevronRight size={10} />
                    </button>
                  </div>
                  <div className="flex flex-col gap-2">
                    {historyList.length === 0 ? (
                      <div className={`text-center py-4 text-[10px] font-medium ${isHC ? 'text-slate-900 font-bold' : 'text-slate-400'}`}>
                        {t('noRecentSignals')}
                      </div>
                    ) : (
                      historyList.slice(0, 3).map((evt, idx) => {
                        let containerStyle = isHC 
                          ? 'bg-white border-2 border-green-800 text-green-900 font-bold'
                          : 'bg-green-50/50 border-green-100 text-green-700';

                        if (evt.severity === 'critical') {
                          containerStyle = isHC
                            ? 'bg-white border-2 border-red-800 text-red-900 font-bold'
                            : 'bg-red-50/70 border-red-100 text-red-700';
                        } else if (evt.severity === 'high') {
                          containerStyle = isHC
                            ? 'bg-white border-2 border-orange-600 text-orange-900 font-bold'
                            : 'bg-orange-50/50 border-orange-100 text-orange-700';
                        } else if (evt.severity === 'medium') {
                          containerStyle = isHC
                            ? 'bg-white border-2 border-blue-600 text-blue-900 font-bold'
                            : 'bg-blue-50/50 border-blue-100 text-blue-700';
                        }

                        return (
                          <div 
                            key={idx} 
                            onClick={() => setCurrentScreen('history')}
                            className={`${containerStyle} border p-2.5 rounded-[16px] flex items-center justify-between gap-2.5 animate-fadeIn transition-all hover:shadow-sm text-left cursor-pointer hover:opacity-95`}
                          >
                            <div className="flex items-center gap-2.5 min-w-0 flex-1">
                              <div className={`p-1.5 rounded-lg shrink-0 border ${getSeverityBgClass(evt.severity)}`}>
                                <SoundSpecificIcon soundName={evt.label} severity={evt.severity} size={15} />
                              </div>
                              <div className="min-w-0 flex-1">
                                <p className={`font-bold text-[11px] leading-tight break-words capitalize ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-800'}`}>{getSoundName(null, evt.label)}</p>
                              </div>
                            </div>
                            <div className="shrink-0">
                              <div className={`text-[8px] font-semibold capitalize px-1.5 py-0.5 rounded-md ${
                                isHC ? 'bg-slate-950 text-white font-bold' : 'bg-indigo-50 text-indigo-600'
                              }`}>
                                {evt.mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}
                              </div>
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* SCREEN 8: DETAILED HISTORY */}
            {currentScreen === 'history' && (
              <div className="flex-1 flex flex-col p-5 animate-fadeIn">
                <div className="flex justify-between items-center mb-4">
                  <div className="text-left">
                    <h2 className={`font-display text-lg font-bold ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-800'}`}>{t('historyTitle')}</h2>
                    <p className={`text-[10px] ${isHC ? 'text-slate-950 font-semibold' : 'text-slate-500'}`}>{t('historyDesc')}</p>
                  </div>
                </div>

                <div className="flex-1 space-y-2 overflow-y-auto pr-1 no-scrollbar max-h-[460px]">
                  {historyList.length === 0 ? (
                    <div className="text-center py-12">
                      <div className={`p-3 rounded-full inline-block mb-2 ${isHC ? 'bg-slate-950 text-white' : 'bg-slate-100 text-slate-400'}`}>
                        <Icons.ClipboardList size={28} />
                      </div>
                      <p className={`text-xs font-bold ${isHC ? 'text-slate-950' : 'text-slate-500'}`}>{t('historyEmpty')}</p>
                      <p className={`text-[10px] mt-0.5 ${isHC ? 'text-slate-950 font-medium' : 'text-slate-400'}`}>{t('historyEmptySub')}</p>
                    </div>
                  ) : (
                    historyList.map((evt, idx) => {
                      return (
                        <div key={idx} className={`p-3 rounded-2xl flex items-center justify-between gap-2.5 animate-fadeIn ${
                          isHC ? 'bg-white border-2 border-slate-950 shadow-none' : 'bg-white border border-slate-100/80 shadow-sm'
                        }`}>
                          <div className="flex items-center gap-3 min-w-0 flex-1">
                            <div className={`p-2 rounded-xl shrink-0 border ${getSeverityBgClass(evt.severity)}`}>
                              <SoundSpecificIcon soundName={evt.label} severity={evt.severity} size={18} />
                            </div>
                            <div className="text-left min-w-0 flex-1">
                              <div className={`font-bold text-xs leading-snug break-words ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-800'}`}>{getSoundName(null, evt.label)}</div>
                            </div>
                          </div>
                          <div className="shrink-0">
                            <div className={`text-[9px] font-semibold capitalize px-1.5 py-0.5 rounded-md inline-block ${
                              isHC ? 'bg-slate-950 text-white border border-slate-950 font-bold' : 'bg-indigo-50 text-indigo-600'
                            }`}>{evt.mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}</div>
                          </div>
                        </div>
                      );
                    })
                  )}
                </div>
              </div>
            )}

            {/* SCREEN 9: NEW RESTURED SETTINGS SCREEN */}
            {currentScreen === 'vibration' && (
              <div className="flex flex-col animate-fadeIn h-full">
                {/* Header */}
                <div className={`px-5 py-3 border-b flex justify-between items-center shrink-0 ${
                  isHC ? 'border-slate-950 bg-white text-slate-950 border-b-2' : 'border-slate-100 bg-white text-slate-800'
                }`}>
                  <div>
                    <h2 className="font-display text-sm font-black">{t('settingsTitle')}</h2>
                    <p className={`text-[9px] font-semibold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('settingsSub')}</p>
                  </div>
                </div>

                {/* Main scroll area */}
                <div className={`flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 max-h-[460px] ${isHC ? 'bg-white' : 'bg-slate-50/50'}`}>
                  
                  {/* Global Safety Alert for Emergency Contact */}
                  {(!userProfile.emergencyContactName || !userProfile.emergencyContactPhone) && (
                    <div className={`p-3 rounded-2xl flex items-start gap-2 text-left animate-pulse ${
                      isHC ? 'bg-white border-2 border-rose-700 text-rose-800 font-bold' : 'bg-rose-50 border border-rose-200 text-rose-700'
                    }`}>
                      <Icons.AlertTriangle size={16} className={`${isHC ? 'text-rose-700 font-bold' : 'text-rose-600'} shrink-0 mt-0.5`} />
                      <div>
                        <div className={`font-bold text-[10px] uppercase tracking-wider ${isHC ? 'text-rose-900 font-extrabold' : ''}`}>{t('requiredSafetyTitle')}</div>
                        <p className={`text-[9px] leading-tight ${isHC ? 'text-rose-800 font-bold' : 'text-rose-600'}`}>{t('requiredSafetyDesc')}</p>
                      </div>
                    </div>
                  )}

                  {/* 1. ACCOUNT & PROFILE */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.User size={13} className={isHC ? 'text-slate-950 font-bold' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionAccountProfile')}</span>
                    </div>

                    <div className="space-y-2.5">
                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelFullName')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.User size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="text"
                            value={userProfile.name}
                            onChange={e => updateProfileField('name', e.target.value)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder="John Doe"
                          />
                        </div>
                      </div>

                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelUserAge')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.Calendar size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="number"
                            value={userProfile.age || ''}
                            onChange={e => updateProfileField('age', parseInt(e.target.value) || 0)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder="28"
                          />
                        </div>
                      </div>

                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelYourPhone')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.Smartphone size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="text"
                            value={userProfile.phone}
                            onChange={e => updateProfileField('phone', e.target.value)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder="Your phone number"
                          />
                        </div>
                      </div>

                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelYourEmail')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.Mail size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="email"
                            value={userProfile.email}
                            onChange={e => updateProfileField('email', e.target.value)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder="Email address"
                          />
                        </div>
                      </div>

                      <button
                        onClick={() => {
                          setCurrentScreen('auth');
                        }}
                        className={`w-full mt-2 flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold transition active:scale-95 ${
                          isHC 
                            ? 'bg-white border-2 border-rose-700 text-rose-700 hover:bg-rose-50 font-black' 
                            : 'border border-rose-200 text-rose-600 bg-rose-50 hover:bg-rose-100'
                        }`}
                      >
                        <Icons.LogOut size={14} />
                        <span>{t('btnSignOut')}</span>
                      </button>
                    </div>
                  </div>

                  {/* 2. ALERT PREFERENCES */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Sliders size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionAlertPrefs')}</span>
                    </div>

                    <div className="space-y-3">
                      {/* Output styles selection */}
                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelAlertFormats')}</span>
                        <div className="grid grid-cols-3 gap-1.5">
                          {[
                            { key: 'text', labelKey: 'btnTextFormat' },
                            { key: 'icon', labelKey: 'btnIconsFormat' },
                            { key: 'color', labelKey: 'btnColorsFormat' }
                          ].map(item => {
                            const active = userProfile.outputPreferences.includes(item.key as any);
                            return (
                              <button
                                key={item.key}
                                type="button"
                                onClick={() => handleTogglePref(item.key as any)}
                                className={`py-1.5 rounded-xl text-[10px] font-bold border transition active:scale-95 ${
                                  isHC
                                    ? active
                                      ? 'bg-slate-950 text-white border-2 border-slate-950 font-extrabold'
                                      : 'bg-white text-slate-950 border-2 border-slate-950 font-extrabold hover:bg-slate-100'
                                    : active
                                      ? 'bg-indigo-600 text-white border-indigo-600'
                                      : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
                                }`}
                              >
                                {t(item.labelKey)}
                              </button>
                            );
                          })}
                        </div>
                      </div>

                      {/* Vibration Types Guide link */}
                      <button
                        onClick={() => setCurrentScreen('haptic_guide')}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-indigo-50 border border-indigo-100 text-indigo-700 hover:bg-indigo-100'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.Vibrate size={15} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                          <span className="text-xs font-bold">{t('btnVibrationGuide')}</span>
                        </div>
                        <Icons.ChevronRight size={14} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      </button>
                    </div>
                  </div>

                  {/* 3. EMERGENCY */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Siren size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionEmergencyContacts')}</span>
                    </div>

                    <div className="space-y-2.5">
                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelContactName')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.UserCheck size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="text"
                            value={userProfile.emergencyContactName || ''}
                            onChange={e => updateProfileField('emergencyContactName', e.target.value)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder={t('placeholderContactName')}
                            required
                          />
                        </div>
                      </div>

                      <div className="flex flex-col gap-1">
                        <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelContactPhone')}</span>
                        <div className={`flex items-center gap-2 rounded-xl px-2.5 py-1.5 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border border-slate-200 text-slate-800'}`}>
                          <Icons.Phone size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <input
                            type="text"
                            value={userProfile.emergencyContactPhone || ''}
                            onChange={e => updateProfileField('emergencyContactPhone', e.target.value)}
                            className={`bg-transparent text-xs w-full focus:outline-none ${isHC ? 'text-slate-950 font-bold placeholder-slate-700' : 'text-slate-800'}`}
                            placeholder={t('placeholderContactPhone')}
                            required
                          />
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* 4. SAVED LOCATIONS */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center justify-between mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <div className="flex items-center gap-1.5">
                        <Icons.MapPin size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                        <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionSavedLocations')}</span>
                      </div>
                      {!isAddingLocation && !editingLocationId && (
                        <button
                          type="button"
                          onClick={() => {
                            setLocFormName('');
                            setLocFormAddress('');
                            setIsAddingLocation(true);
                          }}
                          className={`text-[10px] font-bold flex items-center gap-1 px-2 py-0.5 rounded-lg transition active:scale-95 cursor-pointer ${
                            isHC
                              ? 'bg-slate-950 text-white hover:bg-black font-extrabold'
                              : 'bg-indigo-50 text-indigo-600 hover:bg-indigo-100'
                          }`}
                        >
                          <Icons.Plus size={11} />
                          <span>{t('btnAddLocation')}</span>
                        </button>
                      )}
                    </div>

                    <p className={`text-[11px] mb-3 leading-tight ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('savedLocationsDesc')}
                    </p>

                    {/* Add / Edit Location Form */}
                    {(isAddingLocation || editingLocationId) && (
                      <div className={`p-3 rounded-xl mb-3 border ${
                        isHC ? 'bg-slate-50 border-2 border-slate-950 text-slate-950' : 'bg-slate-50 border-slate-200'
                      }`}>
                        <div className="flex items-center justify-between mb-2">
                          <span className={`text-xs font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-700'}`}>
                            {editingLocationId ? t('btnEditLocation') : t('btnAddNewLocation')}
                          </span>
                          <button
                            type="button"
                            onClick={() => {
                              setIsAddingLocation(false);
                              setEditingLocationId(null);
                              setLocFormName('');
                              setLocFormAddress('');
                            }}
                            className="text-slate-400 hover:text-slate-600 p-0.5"
                          >
                            <Icons.X size={14} />
                          </button>
                        </div>

                        {/* Quick suggestions */}
                        <div className="mb-2.5">
                          <span className={`text-[9px] font-bold uppercase tracking-wider block mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                            {t('quickSuggestions')}
                          </span>
                          <div className="flex flex-wrap gap-1">
                            {[
                              { label: t('suggestionHome'), val: 'Home', icon: Icons.Home },
                              { label: t('suggestionSchoolCollege'), val: 'School / College', icon: Icons.GraduationCap },
                              { label: t('suggestionOffice'), val: 'Office', icon: Icons.Briefcase },
                              { label: t('suggestionGym'), val: 'Gym', icon: Icons.Dumbbell },
                            ].map(s => {
                              const SuggestionIcon = s.icon;
                              return (
                                <button
                                  key={s.val}
                                  type="button"
                                  onClick={() => setLocFormName(s.label)}
                                  className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold transition active:scale-95 cursor-pointer ${
                                    locFormName === s.label
                                      ? isHC ? 'bg-slate-950 text-white' : 'bg-indigo-600 text-white'
                                      : isHC ? 'bg-white border border-slate-950 text-slate-950 hover:bg-slate-100' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-100'
                                  }`}
                                >
                                  <SuggestionIcon size={11} className="shrink-0" />
                                  <span>{s.label}</span>
                                </button>
                              );
                            })}
                          </div>
                        </div>

                        <div className="space-y-2">
                          <div>
                            <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                              {t('labelLocationName')}
                            </label>
                            <input
                              type="text"
                              value={locFormName}
                              onChange={e => setLocFormName(e.target.value)}
                              placeholder={t('placeholderLocationName')}
                              className={`w-full px-2.5 py-1.5 text-xs rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                            />
                          </div>

                          <div>
                            <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>
                              {t('labelLocationAddress')}
                            </label>
                            <input
                              type="text"
                              value={locFormAddress}
                              onChange={e => setLocFormAddress(e.target.value)}
                              placeholder={t('placeholderLocationAddress')}
                              className={`w-full px-2.5 py-1.5 text-xs rounded-xl focus:border-indigo-500 focus:outline-none ${inputClass}`}
                            />
                          </div>

                          <div className="flex gap-2 pt-1">
                            <button
                              type="button"
                              onClick={() => {
                                if (!locFormName.trim() || !locFormAddress.trim()) {
                                  alert("Please enter both a Location Name and an Address.");
                                  return;
                                }
                                if (editingLocationId) {
                                  handleUpdateLocation(editingLocationId, locFormName, locFormAddress);
                                } else {
                                  handleAddLocation(locFormName, locFormAddress);
                                  setIsAddingLocation(false);
                                  setLocFormName('');
                                  setLocFormAddress('');
                                }
                              }}
                              disabled={!locFormName.trim() || !locFormAddress.trim()}
                              className={`flex-1 py-1.5 rounded-xl text-xs font-bold transition active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed ${
                                isHC
                                  ? 'bg-slate-950 text-white border-2 border-slate-950 font-extrabold'
                                  : 'bg-indigo-600 text-white hover:bg-indigo-700'
                              }`}
                            >
                              {editingLocationId ? t('btnUpdateLocation') : t('btnSaveLocation')}
                            </button>
                            <button
                              type="button"
                              onClick={() => {
                                setIsAddingLocation(false);
                                setEditingLocationId(null);
                                setLocFormName('');
                                setLocFormAddress('');
                              }}
                              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition active:scale-95 ${
                                isHC
                                  ? 'bg-white border-2 border-slate-950 text-slate-950 hover:bg-slate-100 font-extrabold'
                                  : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-100'
                              }`}
                            >
                              {t('btnCancel')}
                            </button>
                          </div>
                        </div>
                      </div>
                    )}

                    {/* Saved Locations List */}
                    <div className="space-y-2">
                      {userProfile.savedLocations && userProfile.savedLocations.length > 0 ? (
                        userProfile.savedLocations.map(loc => (
                          <div
                            key={loc.id}
                            className={`p-2.5 rounded-xl border flex items-center justify-between text-left transition ${
                              isHC
                                ? 'bg-white border-2 border-slate-950 text-slate-950'
                                : 'bg-slate-50 border-slate-200/80 text-slate-800 hover:border-slate-300'
                            }`}
                          >
                            <div className="flex items-start gap-2.5 min-w-0 flex-1 pr-2">
                              <div className={`p-1.5 rounded-lg shrink-0 ${isHC ? 'bg-slate-950 text-white' : 'bg-indigo-100 text-indigo-700'}`}>
                                <Icons.MapPin size={14} />
                              </div>
                              <div className="min-w-0">
                                <div className="text-xs font-bold truncate">{loc.name}</div>
                                <div className={`text-[11px] truncate leading-tight ${isHC ? 'text-slate-900 font-bold' : 'text-slate-500'}`}>
                                  {loc.address}
                                </div>
                              </div>
                            </div>
                            <div className="flex items-center gap-1 shrink-0">
                              <button
                                type="button"
                                onClick={() => {
                                  setEditingLocationId(loc.id);
                                  setLocFormName(loc.name);
                                  setLocFormAddress(loc.address);
                                  setIsAddingLocation(false);
                                }}
                                className={`p-1.5 rounded-lg transition active:scale-95 cursor-pointer ${
                                  isHC
                                    ? 'text-slate-950 hover:bg-slate-200 font-bold'
                                    : 'text-slate-500 hover:text-indigo-600 hover:bg-indigo-50'
                                }`}
                                title="Edit Location"
                              >
                                <Icons.Edit2 size={13} />
                              </button>
                              <button
                                type="button"
                                onClick={() => handleDeleteLocation(loc.id)}
                                className={`p-1.5 rounded-lg transition active:scale-95 cursor-pointer ${
                                  isHC
                                    ? 'text-slate-950 hover:bg-rose-100 hover:text-rose-700 font-bold'
                                    : 'text-slate-400 hover:text-rose-600 hover:bg-rose-50'
                                }`}
                                title="Delete Location"
                              >
                                <Icons.Trash2 size={13} />
                              </button>
                            </div>
                          </div>
                        ))
                      ) : (
                        !isAddingLocation && (
                          <div className={`p-4 rounded-xl border border-dashed text-center ${
                            isHC ? 'border-slate-950 text-slate-950 bg-slate-50' : 'border-slate-200 text-slate-400 bg-slate-50/50'
                          }`}>
                            <Icons.MapPin size={20} className={`mx-auto mb-1 opacity-40 ${isHC ? 'text-slate-950' : 'text-indigo-600'}`} />
                            <div className="text-xs font-medium">{t('noSavedLocations')}</div>
                            <button
                              type="button"
                              onClick={() => {
                                setLocFormName('');
                                setLocFormAddress('');
                                setIsAddingLocation(true);
                              }}
                              className={`mt-2 text-xs font-bold px-3 py-1 rounded-lg transition active:scale-95 inline-flex items-center gap-1 ${
                                isHC
                                  ? 'bg-slate-950 text-white border-2 border-slate-950 font-extrabold'
                                  : 'bg-indigo-600 text-white hover:bg-indigo-700'
                              }`}
                            >
                              <Icons.Plus size={12} />
                              <span>{t('btnAddLocation')}</span>
                            </button>
                          </div>
                        )
                      )}
                    </div>
                  </div>

                  {/* 5. DETECTION BEHAVIOR */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Compass size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionDetectionBehavior')}</span>
                    </div>

                    <div className="space-y-3">
                      {/* Indoor/Outdoor toggle */}
                      <div className="flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <Icons.Trees size={15} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                          <span className={`text-[11px] ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelOutdoorOverride')}</span>
                        </div>
                        <Switch
                          checked={mode === 'outdoor'}
                          onChange={() => {
                            const newMode = mode === 'indoor' ? 'outdoor' : 'indoor';
                            setMode(newMode);
                            setLastDetectedSound(null);
                          }}
                        />
                      </div>

                      {/* GPS Auto Detect (TODO Placeholder) */}
                      <div className="flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <Icons.MapPin size={15} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                          <span className={`text-[11px] flex items-center gap-1 ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>
                            <span>{t('labelGpsAuto')}</span>
                            <span className={`text-[8px] font-bold px-1 rounded border ${isHC ? 'bg-slate-950 text-white border-slate-950' : 'bg-slate-100 text-slate-500 border-slate-200'}`}>TODO</span>
                          </span>
                        </div>
                        <Switch
                          checked={!!userProfile.gpsAutoDetect}
                          onChange={() => {
                            updateProfileField('gpsAutoDetect', !userProfile.gpsAutoDetect);
                          }}
                        />
                      </div>

                      {/* Mic Access Status */}
                      <div className={`flex items-center justify-between pt-1 border-t ${isHC ? 'border-slate-950 border-t-2' : 'border-slate-100'}`}>
                        <div className="flex items-center gap-2">
                          <Icons.Mic size={15} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                          <div className="text-left">
                            <span className={`text-[11px] block ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelMicSampling')}</span>
                            <span className={`text-[9px] font-bold ${
                              userProfile.micAccess 
                                ? isHC ? 'text-green-800 font-extrabold' : 'text-green-600' 
                                : isHC ? 'text-rose-800 font-extrabold' : 'text-rose-500'
                            }`}>
                              {userProfile.micAccess ? t('statusAccessGranted') : t('statusAccessDenied')}
                            </span>
                          </div>
                        </div>
                        {!userProfile.micAccess ? (
                          <button
                            onClick={() => {
                              updateProfileField('micAccess', true);
                              alert("System Microphone access has been re-requested and approved!");
                            }}
                            className={`text-[9px] font-bold px-2 py-1 rounded-lg transition active:scale-95 ${
                              isHC 
                                ? 'bg-slate-950 text-white border-2 border-slate-950 font-extrabold' 
                                : 'bg-indigo-600 text-white hover:bg-indigo-700'
                            }`}
                          >
                            {t('btnReRequest')}
                          </button>
                        ) : (
                          <div className={`px-1.5 py-0.5 rounded-md border flex items-center gap-0.5 ${
                            isHC 
                              ? 'text-green-800 bg-white border-2 border-green-800 font-extrabold' 
                              : 'text-green-600 bg-green-50 border-green-100'
                          }`}>
                            <Icons.Check size={10} className="stroke-[3]" />
                            <span className="text-[8px] font-bold">{t('statusActive')}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* 6. ACCESSIBILITY */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Eye size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionAccessibility')}</span>
                    </div>

                    <div className="space-y-3">
                      {/* Language selection dropdown */}
                      <div className="flex flex-col gap-1">
                        <div className="flex items-center gap-2 mb-1">
                          <Icons.Languages size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelAppLanguage')}</span>
                        </div>
                        <select
                          value={userProfile.language || 'English'}
                          onChange={e => {
                            updateProfileField('language', e.target.value);
                            alert(`Language switched to: ${e.target.value}`);
                          }}
                          className={`text-xs px-2 py-1.5 rounded-xl focus:border-indigo-500 focus:outline-none font-medium w-full ${
                            isHC 
                              ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold' 
                              : 'bg-slate-50 border border-slate-200 text-slate-800'
                          }`}
                        >
                          <option value="English">English</option>
                          <option value="Hindi">Hindi (हिंदी)</option>
                          <option value="Kannada">Kannada (ಕನ್ನಡ)</option>
                        </select>
                      </div>

                      {/* Font size dropdown */}
                      <div className="flex flex-col gap-1">
                        <div className="flex items-center gap-2 mb-1">
                          <Icons.Type size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <span className={`text-[9px] font-bold uppercase tracking-wider ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-400'}`}>{t('labelFontScale')}</span>
                        </div>
                        <select
                          value={userProfile.textSize || 'medium'}
                          onChange={e => {
                            updateProfileField('textSize', e.target.value);
                          }}
                          className={`text-xs px-2 py-1.5 rounded-xl focus:border-indigo-500 focus:outline-none font-medium w-full ${
                            isHC 
                              ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold' 
                              : 'bg-slate-50 border border-slate-200 text-slate-800'
                          }`}
                        >
                          <option value="small">{t('optionSmall')}</option>
                          <option value="medium">{t('optionMedium')}</option>
                          <option value="large">{t('optionLarge')}</option>
                        </select>
                      </div>

                      {/* High-contrast mode toggle */}
                      <div className={`flex items-center justify-between text-xs pt-1 border-t ${isHC ? 'border-slate-950 border-t-2' : 'border-slate-100'}`}>
                        <div className="flex items-center gap-2">
                          <Icons.Eye size={15} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                          <span className={`text-[11px] ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelHighContrastColors')}</span>
                        </div>
                        <Switch
                          checked={!!userProfile.highContrast}
                          onChange={() => updateProfileField('highContrast', !userProfile.highContrast)}
                        />
                      </div>
                    </div>
                  </div>

                  {/* 7. ABOUT */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Info size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionAboutApp')}</span>
                    </div>

                    <div className="space-y-2 text-xs">
                      <button
                        onClick={() => alert("Terms & Conditions Agreement:\n\nBy using SoundSee, you agree to allow local acoustic pattern classification for ambient awareness support. No sound streams are transmitted to remote servers. All computation remains strictly on-device.")}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left border ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-slate-50 border border-slate-200 hover:bg-slate-100 text-slate-700'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.FileText size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-500'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-600'}`}>{t('btnTermsConditions')}</span>
                        </div>
                        <Icons.ChevronRight size={13} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                      </button>

                      <button
                        onClick={() => alert("Privacy Policy Agreement:\n\nSoundSee is built on-device offline first. We collect zero tracking data, identity records, or remote sound telemetry. You retain full control over your stored history and emergency profiles.")}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left border ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-slate-50 border border-slate-200 hover:bg-slate-100 text-slate-700'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.ShieldCheck size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-500'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-600'}`}>{t('btnPrivacyPolicy')}</span>
                        </div>
                        <Icons.ChevronRight size={13} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                      </button>

                      {/* 1. Rate the App (Native review popup simulator, no DB/network calls) */}
                      <button
                        onClick={() => setShowRateModal(true)}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left border ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-amber-50/60 border border-amber-200 hover:bg-amber-100/70 text-amber-900'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.Star size={14} className={isHC ? 'text-slate-950 fill-slate-950' : 'text-amber-500 fill-amber-500'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-amber-900'}`}>{t('btnRateApp')}</span>
                        </div>
                        <Icons.ChevronRight size={13} className={isHC ? 'text-slate-950' : 'text-amber-400'} />
                      </button>

                      {/* 2. Send Feedback (Local device storage only, no DB/network calls) */}
                      <button
                        onClick={() => setShowFeedbackModal(true)}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left border ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-slate-50 border border-slate-200 hover:bg-slate-100 text-slate-700'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.MessageSquarePlus size={14} className={isHC ? 'text-slate-950 font-bold' : 'text-indigo-600'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-700'}`}>{t('btnSendFeedback')}</span>
                        </div>
                        <Icons.ChevronRight size={13} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                      </button>

                      <div className={`flex justify-between items-center p-2 rounded-xl border ${
                        isHC 
                          ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold' 
                          : 'bg-slate-50 border border-slate-200 text-slate-600'
                      }`}>
                        <div className="flex items-center gap-2">
                          <Icons.Tag size={14} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-600'}`}>{t('labelReleaseVersion')}</span>
                        </div>
                        <span className={`text-[10px] font-mono font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-400'}`}>v1.2.4-build.102</span>
                      </div>
                    </div>
                  </div>

                </div>
              </div>
            )}

            {/* SCREEN 9.5: SUB-SCREEN FOR HAPTIC GUIDE */}
            {currentScreen === 'haptic_guide' && (
              <div className="flex flex-col animate-fadeIn h-full overflow-hidden">
                <div className={`px-4 py-3 border-b flex items-center gap-2 shrink-0 ${
                  isHC ? 'border-slate-950 bg-white text-slate-950 border-b-2' : 'border-slate-100 bg-white text-slate-800'
                }`}>
                  <button
                    onClick={() => setCurrentScreen('vibration')}
                    className={`p-1.5 rounded-full transition cursor-pointer active:scale-95 ${isHC ? 'hover:bg-slate-200 text-slate-950' : 'hover:bg-slate-100 text-slate-600'}`}
                  >
                    <Icons.ArrowLeft size={16} />
                  </button>
                  <div className="text-left">
                    <h2 className={`font-display text-sm font-bold ${isHC ? 'text-slate-950 font-extrabold' : ''}`}>{t('hapticGuideTitle')}</h2>
                    <p className={`text-[10px] font-bold ${isHC ? 'text-slate-950' : 'text-slate-500'}`}>{t('hapticGuideDesc')}</p>
                  </div>
                </div>

                <div className="flex-1 space-y-3.5 overflow-y-auto no-scrollbar p-4 max-h-[460px] pb-24">
                  {/* High Intensity (Critical) */}
                  <button
                    onClick={() => onTriggerHapticVibration('critical')}
                    className={`${cardClass} p-3.5 rounded-2xl text-left w-full transition-all duration-200 hover:scale-[1.01] hover:bg-slate-50/50 active:scale-[0.99] cursor-pointer focus:outline-none focus:ring-2 focus:ring-red-500`}
                  >
                    <div className="flex items-center gap-2 mb-1.5 text-red-600 font-bold text-xs">
                      <Icons.Flame size={14} className={isHC ? 'text-slate-950' : 'text-red-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : ''}>{t('criticalThreatsTitle')}</span>
                    </div>
                    <p className={`text-[11px] leading-tight mb-2 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('criticalThreatsDesc')}
                    </p>
                    <div className={`text-[10px] font-bold flex items-center gap-1 ${isHC ? 'text-slate-950' : 'text-red-600'}`}>
                      <span>{t('tapToFeelPattern')}</span>
                      <Icons.Vibrate size={12} className="animate-pulse" />
                    </div>
                  </button>

                  {/* High Priority Alerts */}
                  <button
                    onClick={() => onTriggerHapticVibration('high')}
                    className={`${cardClass} p-3.5 rounded-2xl text-left w-full transition-all duration-200 hover:scale-[1.01] hover:bg-slate-50/50 active:scale-[0.99] cursor-pointer focus:outline-none focus:ring-2 focus:ring-orange-500`}
                  >
                    <div className="flex items-center gap-2 mb-1.5 text-orange-600 font-bold text-xs">
                      <Icons.AlertTriangle size={14} className={isHC ? 'text-slate-950' : 'text-orange-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : ''}>{t('highAlertsTitle')}</span>
                    </div>
                    <p className={`text-[11px] leading-tight mb-2 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('highAlertsDesc')}
                    </p>
                    <div className={`text-[10px] font-bold flex items-center gap-1 ${isHC ? 'text-slate-950' : 'text-orange-600'}`}>
                      <span>{t('tapToFeelPattern')}</span>
                      <Icons.Vibrate size={12} className="animate-pulse" />
                    </div>
                  </button>

                  {/* Medium Priority Alerts */}
                  <button
                    onClick={() => onTriggerHapticVibration('medium')}
                    className={`${cardClass} p-3.5 rounded-2xl text-left w-full transition-all duration-200 hover:scale-[1.01] hover:bg-slate-50/50 active:scale-[0.99] cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500`}
                  >
                    <div className="flex items-center gap-2 mb-1.5 text-blue-600 font-bold text-xs">
                      <Icons.AlertCircle size={14} className={isHC ? 'text-slate-950' : 'text-blue-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : ''}>{t('mediumAlertsTitle')}</span>
                    </div>
                    <p className={`text-[11px] leading-tight mb-2 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('mediumAlertsDesc')}
                    </p>
                    <div className={`text-[10px] font-bold flex items-center gap-1 ${isHC ? 'text-slate-950' : 'text-blue-600'}`}>
                      <span>{t('tapToFeelPattern')}</span>
                      <Icons.Vibrate size={12} className="animate-pulse" />
                    </div>
                  </button>

                  {/* Low Intensity (Ambient) */}
                  <button
                    onClick={() => onTriggerHapticVibration('low')}
                    className={`${cardClass} p-3.5 rounded-2xl text-left w-full transition-all duration-200 hover:scale-[1.01] hover:bg-slate-50/50 active:scale-[0.99] cursor-pointer focus:outline-none focus:ring-2 focus:ring-green-500`}
                  >
                    <div className="flex items-center gap-2 mb-1.5 text-green-600 font-bold text-xs">
                      <Icons.Activity size={14} className={isHC ? 'text-slate-950' : 'text-green-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : ''}>{t('ambientSoundsTitle')}</span>
                    </div>
                    <p className={`text-[11px] leading-tight mb-2 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('ambientSoundsDesc')}
                    </p>
                    <div className={`text-[10px] font-bold flex items-center gap-1 ${isHC ? 'text-slate-950' : 'text-green-600'}`}>
                      <span>{t('tapToFeelPattern')}</span>
                      <Icons.Vibrate size={12} className="animate-pulse" />
                    </div>
                  </button>

                  {/* Interactive Sound Trigger Dropdown for simulation testing */}
                  <div className={`p-3.5 rounded-2xl text-left border ${
                    isHC ? 'bg-white border-2 border-slate-950 text-slate-950' : 'bg-slate-100/85 border-slate-200/60'
                  }`}>
                    <div className="text-[10px] font-bold uppercase mb-2 flex items-center gap-1">
                      <Icons.Volume2 size={12} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : 'text-slate-500'}>{t('triggerSoundSimTitle')}</span>
                    </div>
                    <p className={`text-[10px] mb-2.5 ${isHC ? 'text-slate-900 font-bold' : 'text-slate-400'}`}>
                      {t('triggerSoundSimDesc')}
                    </p>
                    <div className="flex flex-col gap-2">
                      <div className="w-full min-w-0">
                        <select
                          value={selectedSimSoundId}
                          onChange={e => setSelectedSimSoundId(e.target.value)}
                          className={`w-full min-w-0 text-[11px] px-2.5 py-2 rounded-xl focus:border-indigo-500 focus:outline-none font-medium truncate ${inputClass}`}
                        >
                          {SOUND_TAXONOMY.map(s => (
                            <option key={s.id} value={s.id}>
                              {getSoundName(s)} ({getPriorityWord(s.severity)})
                            </option>
                          ))}
                        </select>
                      </div>
                      <button
                        onClick={() => {
                          const sound = SOUND_TAXONOMY.find(s => s.id === selectedSimSoundId);
                          if (sound) onTriggerSound(sound);
                        }}
                        className={`w-full font-bold text-[11px] px-3.5 py-2 rounded-xl transition active:scale-95 shadow-sm shrink-0 flex items-center justify-center gap-1.5 cursor-pointer ${
                          isHC 
                            ? 'bg-slate-950 text-white border-2 border-slate-950 hover:bg-black font-black' 
                            : 'bg-indigo-600 text-white hover:bg-indigo-700'
                        }`}
                      >
                        <Icons.Volume2 size={12} />
                        <span>{t('btnTrigger')}</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Device Navigation bar/buttons at bottom */}
          {currentScreen !== 'splash' && currentScreen !== 'auth' && (
            <div className={`px-5 pt-2 pb-0 flex justify-around items-center border-t backdrop-blur z-30 text-[10px] font-bold ${
              isHC 
                ? 'border-slate-950 border-t-2 bg-white text-slate-950 font-black' 
                : 'border-slate-100 bg-white/95 text-slate-400'
            }`}>
              <button
                onClick={() => setCurrentScreen('home')}
                className={`flex flex-col items-center gap-0.5 py-1 ${
                  currentScreen === 'home' 
                    ? isHC 
                      ? 'text-slate-950 font-black underline underline-offset-4 decoration-2' 
                      : 'text-indigo-600' 
                    : isHC 
                    ? 'text-slate-900 font-bold' 
                    : 'hover:text-slate-700'
                }`}
              >
                <Icons.Home size={18} />
                <span>{t('navHome')}</span>
              </button>
              <button
                onClick={() => setCurrentScreen('history')}
                className={`flex flex-col items-center gap-0.5 py-1 ${
                  currentScreen === 'history' 
                    ? isHC 
                      ? 'text-slate-950 font-black underline underline-offset-4 decoration-2' 
                      : 'text-indigo-600' 
                    : isHC 
                    ? 'text-slate-900 font-bold' 
                    : 'hover:text-slate-700'
                }`}
              >
                <Icons.History size={18} />
                <span>{t('navHistory')}</span>
              </button>
              <button
                onClick={() => setCurrentScreen('vibration')}
                className={`flex flex-col items-center gap-0.5 py-1 ${
                  currentScreen === 'vibration' 
                    ? isHC 
                      ? 'text-slate-950 font-black underline underline-offset-4 decoration-2' 
                      : 'text-indigo-600' 
                    : isHC 
                    ? 'text-slate-900 font-bold' 
                    : 'hover:text-slate-700'
                }`}
              >
                <Icons.Settings size={18} />
                <span>{t('navSettings')}</span>
              </button>
            </div>
          )}

          {/* Feedback Toast Notification */}
          {feedbackToast && (
            <div className="absolute top-12 left-4 right-4 z-50 animate-bounce">
              <div className={`p-2.5 rounded-xl shadow-lg border flex items-center gap-2 text-xs font-bold ${
                isHC
                  ? 'bg-slate-950 text-white border-2 border-white'
                  : 'bg-emerald-600 text-white border-emerald-500 shadow-emerald-600/30'
              }`}>
                <Icons.CheckCircle2 size={16} className="shrink-0 text-emerald-300" />
                <span className="flex-1 leading-tight">{feedbackToast}</span>
              </div>
            </div>
          )}

          {/* 1. RATE THE APP MODAL (Native OS review popup simulator - Play Core / SKStoreReviewController simulation) */}
          {showRateModal && (
            <div className="absolute inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4 animate-fadeIn">
              <div className={`w-full max-w-[280px] p-4 rounded-3xl border text-center shadow-2xl ${
                isHC
                  ? 'bg-white border-3 border-slate-950 text-slate-950'
                  : 'bg-white border-slate-200 text-slate-800'
              }`}>
                {/* App icon badge */}
                <div className="w-12 h-12 rounded-2xl bg-indigo-600 mx-auto flex items-center justify-center text-white shadow-md mb-2.5">
                  <Icons.Radio size={22} className="text-white" />
                </div>
                
                <h3 className={`font-display text-sm font-bold mb-1 ${isHC ? 'text-slate-950 font-black' : 'text-slate-800'}`}>
                  {t('rateModalTitle')}
                </h3>
                <p className={`text-[11px] leading-tight mb-3 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                  {t('rateModalDesc')}
                </p>

                {/* 5-star rating selector */}
                <div className="flex justify-center gap-1.5 mb-4">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      type="button"
                      onClick={() => setRatingStars(star)}
                      className="p-1 transition-transform active:scale-125 focus:outline-none"
                    >
                      <Icons.Star
                        size={22}
                        className={
                          star <= ratingStars
                            ? isHC ? 'text-slate-950 fill-slate-950' : 'text-amber-400 fill-amber-400'
                            : isHC ? 'text-slate-300' : 'text-slate-200'
                        }
                      />
                    </button>
                  ))}
                </div>

                <div className="flex flex-col gap-1.5">
                  <button
                    type="button"
                    onClick={() => {
                      setShowRateModal(false);
                      setFeedbackToast(t('feedbackSuccessToast') || 'Review submitted. Thank you!');
                      setTimeout(() => setFeedbackToast(null), 3000);
                    }}
                    className={`w-full py-2 rounded-xl text-xs font-bold transition active:scale-95 ${
                      isHC
                        ? 'bg-slate-950 text-white border-2 border-slate-950 font-black'
                        : 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-sm'
                    }`}
                  >
                    {t('btnSubmitRating')}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowRateModal(false)}
                    className={`w-full py-1.5 rounded-xl text-xs font-bold transition active:scale-95 ${
                      isHC
                        ? 'bg-white text-slate-950 hover:bg-slate-100 font-bold'
                        : 'bg-transparent text-slate-500 hover:bg-slate-100'
                    }`}
                  >
                    {t('btnNotNow')}
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* 2. SEND FEEDBACK MODAL (Local device storage only - 0 DB/network calls) */}
          {showFeedbackModal && (
            <div className="absolute inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-3 animate-fadeIn">
              <div className={`w-full max-w-[290px] p-4 rounded-3xl border text-left shadow-2xl ${
                isHC
                  ? 'bg-white border-3 border-slate-950 text-slate-950'
                  : 'bg-white border-slate-200 text-slate-800'
              }`}>
                <div className="flex items-center justify-between mb-1 pb-1.5 border-b border-slate-100">
                  <div className="flex items-center gap-1.5">
                    <Icons.MessageSquarePlus size={15} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                    <span className={`text-xs font-bold ${isHC ? 'text-slate-950 font-black' : 'text-slate-800'}`}>
                      {t('feedbackModalTitle')}
                    </span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setShowFeedbackModal(false)}
                    className="p-1 rounded-lg text-slate-400 hover:text-slate-600 transition"
                  >
                    <Icons.X size={14} />
                  </button>
                </div>

                <p className={`text-[10px] mb-2.5 leading-tight ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                  {t('feedbackModalDesc')}
                </p>

                {/* Category selection */}
                <div className="mb-2">
                  <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-black' : 'text-slate-400'}`}>
                    {t('labelFeedbackCategory')}
                  </label>
                  <div className="flex flex-wrap gap-1">
                    {['General', 'Feature Request', 'Bug Report', 'Sound Accuracy'].map((cat) => (
                      <button
                        key={cat}
                        type="button"
                        onClick={() => setFeedbackCategory(cat)}
                        className={`px-2 py-0.5 rounded-lg text-[10px] font-bold transition active:scale-95 ${
                          feedbackCategory === cat
                            ? isHC ? 'bg-slate-950 text-white' : 'bg-indigo-600 text-white'
                            : isHC ? 'bg-white border border-slate-950 text-slate-950' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Star rating */}
                <div className="mb-2">
                  <label className={`block text-[9px] font-bold uppercase tracking-wider mb-0.5 ${isHC ? 'text-slate-950 font-black' : 'text-slate-400'}`}>
                    Rating
                  </label>
                  <div className="flex gap-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        key={star}
                        type="button"
                        onClick={() => setFeedbackRating(star)}
                        className="p-0.5 transition active:scale-110"
                      >
                        <Icons.Star
                          size={15}
                          className={
                            star <= feedbackRating
                              ? isHC ? 'text-slate-950 fill-slate-950' : 'text-amber-400 fill-amber-400'
                              : isHC ? 'text-slate-300' : 'text-slate-200'
                          }
                        />
                      </button>
                    ))}
                  </div>
                </div>

                {/* Feedback message textarea */}
                <div className="mb-3">
                  <label className={`block text-[9px] font-bold uppercase tracking-wider mb-1 ${isHC ? 'text-slate-950 font-black' : 'text-slate-400'}`}>
                    {t('labelFeedbackMessage')}
                  </label>
                  <textarea
                    value={feedbackMessage}
                    onChange={(e) => setFeedbackMessage(e.target.value)}
                    placeholder={t('placeholderFeedbackMessage')}
                    rows={3}
                    className={`w-full px-2.5 py-1.5 text-xs rounded-xl focus:border-indigo-500 focus:outline-none resize-none ${
                      isHC
                        ? 'bg-white border-2 border-slate-950 text-slate-950 placeholder-slate-500 font-bold'
                        : 'bg-slate-50 border border-slate-200 text-slate-800 placeholder-slate-400'
                    }`}
                  />
                </div>

                {/* Actions */}
                <div className="flex gap-1.5">
                  <button
                    type="button"
                    onClick={handleSaveFeedback}
                    disabled={!feedbackMessage.trim()}
                    className={`flex-1 py-1.5 rounded-xl text-xs font-bold transition active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed ${
                      isHC
                        ? 'bg-slate-950 text-white border-2 border-slate-950 font-black'
                        : 'bg-indigo-600 text-white hover:bg-indigo-700'
                    }`}
                  >
                    {t('btnSubmitFeedback')}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowFeedbackModal(false)}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold transition active:scale-95 ${
                      isHC
                        ? 'bg-white border border-slate-950 text-slate-950'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    {t('btnCancel')}
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Virtual home button handle */}
          <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-32 h-1 bg-slate-300 rounded-full"></div>
        </div>
      </div>

      {/* Visual representation of structural haptic vibration */}
      {isVibrating && (
        <div className="mt-4 flex flex-col items-center bg-indigo-50 border border-indigo-100 rounded-2xl px-4 py-2 text-indigo-900 animate-pulse text-xs max-w-[340px]">
          <div className="flex items-center gap-1.5 font-bold">
            <Icons.Vibrate className="animate-spin" size={14} />
            <span>{t('hapticEngineEngaged')} {vibrationPattern}</span>
          </div>
          {/* Progress bar visualizer for haptics */}
          <div className="w-48 h-1 bg-indigo-200 rounded-full mt-1.5 overflow-hidden">
            <div
              className="h-full bg-indigo-600 transition-all duration-100"
              style={{ width: `${vibrationProgress}%` }}
            ></div>
          </div>
        </div>
      )}
    </div>
  );
};
