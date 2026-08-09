import React, { useState, useEffect } from 'react';
import * as Icons from 'lucide-react';
import { SoundLabel, SoundEvent, UserProfile, SeverityType } from '../types';
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

// Dynamic Icon rendering helper
export const DynamicIcon = ({ name, className, size = 20 }: { name: string; className?: string; size?: number }) => {
  const IconComponent = (Icons as any)[name] || Icons.HelpCircle;
  return <IconComponent className={className} size={size} />;
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

  const isHC = !!userProfile.highContrast;

  // Theme styling helpers for High Contrast
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

  // Render Severity Icon shapes as requested:
  // red triangle = critical, orange tri = high (attention), green circle = low
  const renderSeverityShape = (severity: SeverityType, size = 24) => {
    if (severity === 'critical') {
      return (
        <div className="flex items-center justify-center text-red-600 bg-red-100 p-1.5 rounded-lg" title="Critical Alert">
          <Icons.AlertTriangle size={size} fill="currentColor" className="text-red-600" />
        </div>
      );
    } else if (severity === 'attention') {
      return (
        <div className="flex items-center justify-center text-amber-500 bg-amber-100 p-1.5 rounded-lg" title="Attention Alert">
          <Icons.AlertTriangle size={size} fill="currentColor" className="text-amber-500" />
        </div>
      );
    } else {
      return (
        <div className="flex items-center justify-center text-green-600 bg-green-100 p-1.5 rounded-lg" title="Low Severity Alert">
          <Icons.Circle size={size} fill="currentColor" className="text-green-600" />
        </div>
      );
    }
  };

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
                : lastDetectedSound.severity === 'attention'
                ? 'border-amber-400 shadow-[inset_0_0_20px_rgba(251,191,36,0.6)]'
                : 'border-green-400 shadow-[inset_0_0_15px_rgba(52,211,153,0.5)]'
            }`}
          />
        )}

        {/* Screen inner container */}
        <div className={`relative w-full h-full ${bgClass} ${textClass} rounded-[32px] overflow-hidden flex flex-col pt-8 pb-4 select-none font-sans transition-all duration-500 ${isVibrating ? 'animate-shake' : ''}`}>
          
          {/* Status bar */}
          <div className={`px-5 py-1.5 flex justify-between items-center text-[11px] border-b bg-slate-50/80 backdrop-blur z-30 ${isHC ? 'text-slate-950 border-slate-900 font-extrabold' : 'text-slate-600 border-slate-100 font-medium'}`}>
            <div className="flex items-center gap-1.5">
              <span>09:41 AM</span>
              {currentScreen !== 'splash' && currentScreen !== 'auth' && currentScreen !== 'onboarding' && currentScreen !== 'preference' && (
                <button
                  onClick={() => setIsAppBackgrounded(!isAppBackgrounded)}
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
            <div className="absolute top-12 left-3 right-3 z-50 flex flex-col gap-2 transition-all duration-300">
              <div className={`text-white p-2.5 rounded-2xl shadow-xl flex items-center justify-between border animate-slideDown ${
                lastDetectedSound.severity === 'critical'
                  ? 'bg-red-600 border-red-500 shadow-red-500/25'
                  : lastDetectedSound.severity === 'attention'
                  ? 'bg-amber-500 border-amber-400 shadow-amber-500/25'
                  : 'bg-green-600 border-green-500 shadow-green-500/25'
              }`}>
                {/* Empty spacer to balance the close button and keep the icon centered */}
                <div className="w-8" />
                <div className="p-2 bg-white/20 rounded-xl flex items-center justify-center">
                  <DynamicIcon name={lastDetectedSound.iconName} size={24} className="text-white" />
                </div>
                <button 
                  onClick={() => {
                    setLastDetectedSound(null);
                    setShowTextAlert(false);
                    setShowIconAlert(false);
                  }} 
                  className="text-white/80 hover:text-white p-1 hover:bg-white/10 rounded-full transition cursor-pointer active:scale-95"
                >
                  <Icons.X size={16} />
                </button>
              </div>
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
                    <div 
                      onClick={() => {
                        // Open app on notification click
                        setIsAppBackgrounded(false);
                      }}
                      className={`w-full bg-white/95 backdrop-blur-md text-slate-900 p-3.5 rounded-2xl shadow-2xl border-l-[6px] transition-all duration-300 hover:scale-[1.02] cursor-pointer animate-slideDown ${
                        lastDetectedSound.severity === 'critical'
                          ? 'border-red-600'
                          : lastDetectedSound.severity === 'attention'
                          ? 'border-amber-500'
                          : 'border-green-600'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1.5">
                        <div className="flex items-center gap-1.5">
                          <div className={`p-1 rounded-md text-white ${
                            lastDetectedSound.severity === 'critical'
                              ? 'bg-red-600'
                              : lastDetectedSound.severity === 'attention'
                              ? 'bg-amber-500'
                              : 'bg-green-600'
                          }`}>
                            <Icons.Ear size={12} />
                          </div>
                          <span className="text-[10px] font-black uppercase tracking-wider text-slate-500">{t('labelSoundseeUpper')}</span>
                        </div>
                        <span className="text-[9px] text-slate-400 font-medium">{t('timeNow')}</span>
                      </div>
                      
                      <div className="flex items-start gap-2.5">
                        <div className="shrink-0">
                          <div className={`p-2 rounded-xl text-white ${
                            lastDetectedSound.severity === 'critical'
                              ? 'bg-red-50 text-red-600'
                              : lastDetectedSound.severity === 'attention'
                              ? 'bg-amber-50 text-amber-500'
                              : 'bg-green-50 text-green-600'
                          }`}>
                            <DynamicIcon name={lastDetectedSound.iconName} size={18} />
                          </div>
                        </div>
                        <div className="flex-1 min-w-0 text-left">
                          <h4 className="font-bold text-xs text-slate-900 leading-snug">
                            {t('detectedLabel')}{lastDetectedSound.name}
                          </h4>
                          <p className="text-[10px] text-slate-500 leading-normal mt-0.5">
                            {lastDetectedSound.severity === 'critical' ? t('msgCriticalPriorityReg') :
                             lastDetectedSound.severity === 'attention' ? t('msgHighPriorityReg') :
                             t('msgLowPriorityReg')}
                          </p>
                        </div>
                        <div className="shrink-0 pt-0.5">
                          {renderSeverityShape(lastDetectedSound.severity, 10)}
                        </div>
                      </div>
                      
                      {/* Interactive Tap Hint */}
                      <div className="mt-2 pt-1.5 border-t border-slate-100 flex justify-between items-center text-[8px] font-bold text-slate-400 uppercase tracking-wider">
                        <span>{t('tapViewInApp')}</span>
                        <Icons.ChevronRight size={10} />
                      </div>
                    </div>
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
                  onClick={() => setCurrentScreen('home')}
                  disabled={userProfile.outputPreferences.length === 0}
                  className={`w-full font-semibold py-3.5 rounded-2xl transition active:scale-95 text-sm disabled:opacity-40 disabled:cursor-not-allowed ${
                    isHC 
                      ? 'bg-slate-950 text-white hover:bg-black border-2 border-slate-950 font-bold' 
                      : 'bg-indigo-600 text-white hover:bg-indigo-700 shadow-sm'
                  }`}
                >
                  {t('btnCompleteSetup')}
                </button>
              </div>
            )}

            {/* SCREEN 5: HOME SCREEN */}
            {currentScreen === 'home' && (
              <div className="flex flex-col p-5 animate-fadeIn">
                {/* Mode description header */}
                <div className={`flex items-center justify-between mb-4 p-2.5 rounded-2xl shrink-0 ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 font-bold' : 'bg-slate-100/50 border border-slate-100'}`}>
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
                              : lastDetectedSound.severity === 'attention'
                              ? 'border-amber-300 bg-amber-50/10'
                              : 'border-green-300 bg-green-50/10'
                            : isHC ? 'border-slate-950/45 bg-slate-100/10' : 'border-indigo-100'
                        }`}></div>
                        <div className={`absolute w-[150px] h-[150px] border-2 rounded-full animate-ping opacity-40 transition-all duration-300 ${
                          lastDetectedSound
                            ? lastDetectedSound.severity === 'critical'
                              ? 'border-red-200/50'
                              : lastDetectedSound.severity === 'attention'
                              ? 'border-amber-200/50'
                              : 'border-green-200/50'
                            : isHC ? 'border-slate-950/30' : 'border-indigo-100/50'
                        }`}></div>
                        
                        {/* Core Ambient Inner Ring */}
                        <div className={`absolute w-[110px] h-[110px] border-2 rounded-full shadow-inner z-0 transition-all duration-300 ${
                          lastDetectedSound
                            ? lastDetectedSound.severity === 'critical'
                              ? 'bg-red-50 border-red-100/80'
                              : lastDetectedSound.severity === 'attention'
                              ? 'bg-amber-50 border-amber-100/80'
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
                          ? lastDetectedSound.severity === 'critical'
                            ? isHC ? 'bg-red-800 text-white border-2 border-red-950' : 'bg-red-600 text-white hover:bg-red-700'
                            : lastDetectedSound.severity === 'attention'
                            ? isHC ? 'bg-amber-600 text-black border-2 border-amber-950 font-bold' : 'bg-amber-500 text-white hover:bg-amber-600'
                            : isHC ? 'bg-green-800 text-white border-2 border-green-950' : 'bg-green-600 text-white hover:bg-green-700'
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
                        lastDetectedSound 
                          ? 'opacity-100 scale-100 rotate-0' 
                          : 'opacity-0 scale-50 -rotate-90 pointer-events-none'
                      }`}>
                        {lastDetectedSound && (
                          <DynamicIcon name={lastDetectedSound.iconName} size={20} />
                        )}
                      </div>
                    </button>
                  </div>

                  <div className="text-center mt-2.5 z-10 flex flex-col items-center">
                    {lastDetectedSound ? (
                      <div className="animate-fadeIn flex flex-col items-center">
                        <p className={`text-[13px] font-black tracking-tight capitalize ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-900'}`}>
                          {lastDetectedSound.name}
                        </p>
                        <div className="flex items-center gap-1.5 mt-1">
                          {renderSeverityShape(lastDetectedSound.severity, 10)}
                          <span className={`text-[10px] font-bold uppercase tracking-wider ${
                            lastDetectedSound.severity === 'critical' 
                              ? isHC ? 'text-red-800 font-extrabold' : 'text-red-600' 
                              : lastDetectedSound.severity === 'attention' 
                              ? isHC ? 'text-amber-600 font-extrabold' : 'text-amber-500' 
                              : isHC ? 'text-green-800 font-extrabold' : 'text-green-600'
                          }`}>
                            {lastDetectedSound.severity === 'critical' 
                              ? t('criticalPriority') 
                              : lastDetectedSound.severity === 'attention' 
                              ? t('highPriority') 
                              : t('lowPriority')}
                          </span>
                        </div>
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
                            alert("⚠️ Safety Dispatch Required: Please configure your Emergency Contact details in Settings first.");
                            setCurrentScreen('vibration');
                          } else {
                            onTriggerEmergency(
                              'CALL_EMERGENCY', 
                              `Urgent sound registered: '${lastDetectedSound.name}'. Emergency dispatch invoked for contact: ${userProfile.emergencyContactName} (${userProfile.emergencyContactPhone}).`
                            );
                            alert(`Simulating Emergency Call to: ${userProfile.emergencyContactName} (${userProfile.emergencyContactPhone})`);
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
                          {s.name} ({s.severity})
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
                        let severityLabel = t('lowPriority');

                        if (evt.severity === 'critical') {
                          containerStyle = isHC
                            ? 'bg-white border-2 border-red-800 text-red-900 font-bold'
                            : 'bg-red-50/70 border-red-100 text-red-700';
                          severityLabel = t('criticalPriority');
                        } else if (evt.severity === 'attention') {
                          containerStyle = isHC
                            ? 'bg-white border-2 border-amber-600 text-amber-900 font-bold'
                            : 'bg-orange-50/50 border-orange-100 text-orange-700';
                          severityLabel = t('highPriority');
                        }

                        return (
                          <div 
                            key={idx} 
                            onClick={() => setCurrentScreen('history')}
                            className={`${containerStyle} border p-2.5 rounded-[16px] flex items-center gap-2.5 animate-fadeIn transition-all hover:shadow-sm text-left cursor-pointer hover:opacity-95`}
                          >
                            <div className="flex-shrink-0">
                              {renderSeverityShape(evt.severity, 11)}
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="flex justify-between items-center gap-1">
                                <p className={`font-bold text-[11px] truncate capitalize ${isHC ? 'text-slate-950' : 'text-slate-800'}`}>{evt.label}</p>
                                <span className={`text-[8px] shrink-0 font-medium ${isHC ? 'text-slate-950 font-bold' : 'text-slate-400'}`}>
                                  {new Date(evt.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </span>
                              </div>
                              <p className={`text-[9px] mt-0.5 truncate capitalize ${isHC ? 'text-slate-950 font-semibold' : 'text-slate-500'}`}>
                                {evt.mode === 'indoor' ? t('indoorMode') : t('outdoorMode')} • {severityLabel}
                              </p>
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
                      const match = SOUND_TAXONOMY.find(s => s.name === evt.label);
                      return (
                        <div key={idx} className={`p-3 rounded-2xl flex items-center justify-between gap-2.5 animate-fadeIn ${
                          isHC ? 'bg-white border-2 border-slate-950 shadow-none' : 'bg-white border border-slate-100/80 shadow-sm'
                        }`}>
                          <div className="flex items-center gap-3">
                            {renderSeverityShape(evt.severity, 16)}
                            <div className="text-left">
                              <div className={`font-bold text-xs ${isHC ? 'text-slate-950 font-extrabold' : 'text-slate-800'}`}>{evt.label}</div>
                              <div className={`text-[9px] font-semibold uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{match?.category || 'General'}</div>
                            </div>
                          </div>
                          <div className="text-right">
                            <div className={`text-[9px] font-semibold capitalize px-1.5 py-0.5 rounded-md inline-block mb-1 ${
                              isHC ? 'bg-slate-950 text-white border border-slate-950 font-bold' : 'bg-indigo-50 text-indigo-600'
                            }`}>{evt.mode === 'indoor' ? t('indoorMode') : t('outdoorMode')}</div>
                            <div className={`text-[8px] font-semibold ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>
                              {new Date(evt.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                            </div>
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

                      {/* Per-severity mutes */}
                      <div className={`space-y-2 pt-1 border-t ${isHC ? 'border-slate-950 border-t-2' : 'border-slate-100'}`}>
                        <div className="flex items-center justify-between text-xs">
                          <div className="flex items-center gap-2">
                            <Icons.VolumeX size={15} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                            <span className={`text-[11px] ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelMuteLow')}</span>
                          </div>
                          <Switch
                            checked={!!userProfile.muteLowAlerts}
                            onChange={() => updateProfileField('muteLowAlerts', !userProfile.muteLowAlerts)}
                          />
                        </div>

                        <div className={`flex items-center justify-between text-xs ${isHC ? 'opacity-100' : 'opacity-60'}`}>
                          <div className="flex items-center gap-2">
                            <Icons.Volume2 size={15} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                            <span className={`text-[11px] ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelMuteAttention')}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Icons.Lock size={10} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                            <Switch checked={false} onChange={() => {}} disabled={true} />
                          </div>
                        </div>

                        <div className={`flex items-center justify-between text-xs ${isHC ? 'opacity-100' : 'opacity-60'}`}>
                          <div className="flex items-center gap-2">
                            <Icons.ShieldAlert size={15} className={isHC ? 'text-slate-950 font-bold' : 'text-slate-400'} />
                            <span className={`text-[11px] ${isHC ? 'text-slate-950 font-black' : 'font-medium text-slate-700'}`}>{t('labelMuteCritical')}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Icons.Lock size={10} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
                            <Switch checked={false} onChange={() => {}} disabled={true} />
                          </div>
                        </div>
                      </div>
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

                  {/* 4. DETECTION BEHAVIOR */}
                  <div className={`p-3.5 rounded-2xl border text-left ${isHC ? 'bg-white border-2 border-slate-950 text-slate-950 shadow-none' : 'bg-white border-slate-100 text-slate-800 shadow-sm'}`}>
                    <div className={`flex items-center gap-1.5 mb-2.5 pb-1.5 border-b ${isHC ? 'border-slate-950 border-solid border-b-2' : 'border-dashed border-slate-200'}`}>
                      <Icons.Compass size={13} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                      <span className={`text-[10px] font-black uppercase tracking-wider ${isHC ? 'text-slate-950' : 'text-slate-400'}`}>{t('sectionDetectionBehavior')}</span>
                    </div>

                    <div className="space-y-3">
                      {/* Indoor/Outdoor toggle */}
                      <div className="flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <Icons.Home size={15} className={isHC ? 'text-slate-950' : 'text-slate-400'} />
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

                      {/* GPS Auto Detect */}
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
                            alert("GPS Auto-Detect toggle updated! Simulated geolocation hooks are set in background threads.");
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

                  {/* 5. ACCESSIBILITY */}
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

                  {/* 6. ABOUT */}
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

                      <button
                        onClick={() => alert("Help & Support:\n\nPlease contact us anytime at support@soundsee.org. Our accessibility support specialists will get back to you within 24 hours.")}
                        className={`w-full flex items-center justify-between p-2 rounded-xl transition active:scale-95 text-left border ${
                          isHC 
                            ? 'bg-white border-2 border-slate-950 text-slate-950 font-extrabold hover:bg-slate-100' 
                            : 'bg-indigo-50 border border-indigo-100 hover:bg-indigo-100 text-indigo-700'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          <Icons.HelpCircle size={14} className={isHC ? 'text-slate-950' : 'text-indigo-600'} />
                          <span className={`text-[11px] font-bold ${isHC ? 'text-slate-950 font-black' : ''}`}>{t('btnContactDeveloper')}</span>
                        </div>
                        <Icons.ChevronRight size={13} className={isHC ? 'text-slate-950 text-indigo-600' : ''} />
                      </button>
                    </div>
                  </div>

                </div>
              </div>
            )}

            {/* SCREEN 9.5: SUB-SCREEN FOR HAPTIC GUIDE */}
            {currentScreen === 'haptic_guide' && (
              <div className="flex flex-col p-5 animate-fadeIn h-full">
                <div className="flex items-center gap-2 mb-4">
                  <button
                    onClick={() => setCurrentScreen('vibration')}
                    className={`p-1.5 rounded-full transition ${isHC ? 'hover:bg-slate-200 text-slate-950' : 'hover:bg-slate-100 text-slate-600'}`}
                  >
                    <Icons.ArrowLeft size={16} />
                  </button>
                  <div className="text-left">
                    <h2 className={`font-display text-lg font-bold ${isHC ? 'text-slate-950 font-extrabold' : ''}`}>{t('hapticGuideTitle')}</h2>
                    <p className={`text-[10px] font-bold ${isHC ? 'text-slate-950' : 'text-slate-500'}`}>{t('hapticGuideDesc')}</p>
                  </div>
                </div>

                <div className="space-y-3.5 overflow-y-auto no-scrollbar max-h-[400px]">
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

                  {/* Medium Intensity (Attention) */}
                  <button
                    onClick={() => onTriggerHapticVibration('attention')}
                    className={`${cardClass} p-3.5 rounded-2xl text-left w-full transition-all duration-200 hover:scale-[1.01] hover:bg-slate-50/50 active:scale-[0.99] cursor-pointer focus:outline-none focus:ring-2 focus:ring-amber-500`}
                  >
                    <div className="flex items-center gap-2 mb-1.5 text-amber-600 font-bold text-xs">
                      <Icons.AlertTriangle size={14} className={isHC ? 'text-slate-950' : 'text-amber-600'} />
                      <span className={isHC ? 'text-slate-950 font-extrabold' : ''}>{t('attentionAlertsTitle')}</span>
                    </div>
                    <p className={`text-[11px] leading-tight mb-2 ${isHC ? 'text-slate-950 font-bold' : 'text-slate-500'}`}>
                      {t('attentionAlertsDesc')}
                    </p>
                    <div className={`text-[10px] font-bold flex items-center gap-1 ${isHC ? 'text-slate-950' : 'text-amber-600'}`}>
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
                    <div className="flex gap-2">
                      <select
                        value={selectedSimSoundId}
                        onChange={e => setSelectedSimSoundId(e.target.value)}
                        className={`flex-1 text-xs px-2 py-1.5 rounded-xl focus:border-indigo-500 focus:outline-none font-medium ${inputClass}`}
                      >
                        {SOUND_TAXONOMY.map(s => (
                          <option key={s.id} value={s.id}>
                            {s.name} ({s.severity})
                          </option>
                        ))}
                      </select>
                      <button
                        onClick={() => {
                          const sound = SOUND_TAXONOMY.find(s => s.id === selectedSimSoundId);
                          if (sound) onTriggerSound(sound);
                        }}
                        className={`font-bold text-[11px] px-3.5 py-1.5 rounded-xl transition active:scale-95 shadow-sm shrink-0 ${
                          isHC 
                            ? 'bg-slate-950 text-white border-2 border-slate-950 hover:bg-black font-black' 
                            : 'bg-indigo-600 text-white hover:bg-indigo-700'
                        }`}
                      >
                        {t('btnTrigger')}
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
