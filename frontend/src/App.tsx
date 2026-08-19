import React, { useState, useEffect } from 'react';
import * as Icons from 'lucide-react';
import { DeviceSimulator } from './components/DeviceSimulator';
import { SoundLabel, SoundEvent, UserProfile, SeverityType } from './types';

export default function App() {
  // Global user state - synchronizes with local DB endpoints
  const [userProfile, setUserProfile] = useState<UserProfile>({
    id: 'usr_123',
    name: 'John Doe',
    age: 28,
    phone: '+15551234567',
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

  const [currentScreen, setCurrentScreen] = useState<string>('splash');
  const [lastDetectedSound, setLastDetectedSound] = useState<SoundLabel | null>(null);
  const [showTextAlert, setShowTextAlert] = useState<boolean>(false);
  const [showIconAlert, setShowIconAlert] = useState<boolean>(false);
  
  // Audio sampling and mode flags
  const [isListening, setIsListening] = useState<boolean>(true);
  const [mode, setMode] = useState<'indoor' | 'outdoor'>('indoor');
  
  // Log timelines & synced history
  const [historyList, setHistoryList] = useState<SoundEvent[]>([]);
  
  // Haptic simulation state
  const [isVibrating, setIsVibrating] = useState<boolean>(false);
  const [vibrationPattern, setVibrationPattern] = useState<string>('');
  const [vibrationProgress, setVibrationProgress] = useState<number>(0);

  // Twilio Emergency logging state
  const [twilioLogs, setTwilioLogs] = useState<Array<{
    id: string;
    message: string;
    recipient: string;
    timestamp: string;
    actionType: string;
  }>>([]);

  // Load initial states from server on mount
  useEffect(() => {
    fetchProfile();
    fetchHistory();
  }, []);

  const fetchProfile = async () => {
    try {
      const res = await fetch('/api/users/usr_123/profile');
      if (res.ok) {
        const data = await res.json();
        setUserProfile(data);
      }
    } catch (e) {
      console.error("Error fetching profile", e);
    }
  };

  const fetchHistory = async () => {
    try {
      const res = await fetch('/api/sound-events/usr_123');
      if (res.ok) {
        const data = await res.json();
        setHistoryList(data);
      }
    } catch (e) {
      console.error("Error fetching event logs", e);
    }
  };

  // Sync profile edits back to backend server
  useEffect(() => {
    if (userProfile.id) {
      fetch(`/api/users/${userProfile.id}/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userProfile)
      }).catch(e => console.error("Error syncing profile update", e));
    }
  }, [userProfile]);

  // Triggers haptic simulation on desktop and invokes Web Vibration API on phone/mobile screens
  const triggerHapticVibration = (severity: SeverityType) => {
    setIsVibrating(true);
    let patternText = '';
    let duration = 0;
    let webPattern: number[] = [];

    if (severity === 'critical') {
      patternText = 'Critical (Continuous pulse ⌂⌂⌂⌂⌂)';
      duration = 1500;
      webPattern = [250, 50, 250, 50, 250, 50, 250, 50, 250];
    } else if (severity === 'high') {
      patternText = 'High (Rapid triple-beat ⌴⌴⌴ ⌴⌴⌴)';
      duration = 1200;
      webPattern = [150, 75, 150, 75, 150, 200, 150, 75, 150];
    } else if (severity === 'medium') {
      patternText = 'Medium (Double-beat ⌴⌴ ⌴⌴)';
      duration = 1000;
      webPattern = [100, 100, 100, 200, 100, 100, 100];
    } else {
      patternText = 'Low (Single Tap . .)';
      duration = 400;
      webPattern = [50];
    }

    setVibrationPattern(patternText);
    setVibrationProgress(100);

    // Call native Web Vibration API
    if ('vibrate' in navigator) {
      try {
        navigator.vibrate(webPattern);
      } catch (e) {
        console.warn("Navigator vibration blocked inside frame permissions.");
      }
    }

    // Animate haptic progress visualizer
    const step = 100 / (duration / 50);
    const interval = setInterval(() => {
      setVibrationProgress(prev => {
        if (prev <= 0) {
          clearInterval(interval);
          setIsVibrating(false);
          return 0;
        }
        return prev - step;
      });
    }, 50);
  };

  // Sound detection trigger handler (Simulates Microphone sound-wave ingestion)
  const handleSoundTrigger = async (sound: SoundLabel) => {
    if (!isListening) return;

    const isMuted = sound.severity === 'low' && userProfile.muteLowAlerts;

    // Direct state response on smartphone simulator
    setLastDetectedSound(sound);
    if (!isMuted) {
      setShowTextAlert(true);
      setShowIconAlert(true);
      // Fire haptics
      triggerHapticVibration(sound.severity);
    } else {
      setShowTextAlert(false);
      setShowIconAlert(false);
    }

    // Sync incident with Node express database
    try {
      const res = await fetch('/api/sound-events', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: userProfile.id || "usr_123",
          label: sound.name,
          severity: sound.severity,
          mode: mode,
          timestamp: new Date().toISOString()
        })
      });

      if (res.ok) {
        fetchHistory(); // Reload history
      }
    } catch (e) {
      console.error("Error logging sound event", e);
    }
  };

  // Dispatch Twilio SMS alert simulation
  const handleTriggerEmergency = async (actionType: string, message: string) => {
    try {
      const res = await fetch('/api/emergency/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: userProfile.id || 'usr_123',
          message: message,
          action_type: actionType
        })
      });

      if (res.ok) {
        const data = await res.json();
        const newLog = {
          id: `log_${Math.random().toString(36).substring(2, 8)}`,
          message: data.dispatch_message,
          recipient: data.recipient,
          timestamp: new Date().toLocaleTimeString(),
          actionType: data.action_type
        };
        setTwilioLogs(prev => [newLog, ...prev]);
      }
    } catch (e) {
      console.error("Error triggering emergency helper", e);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 md:p-8 select-none">
      {/* Smartphone Device Simulator */}
      <div className="shrink-0 flex flex-col items-center">
        <DeviceSimulator
          userProfile={userProfile}
          setUserProfile={setUserProfile}
          currentScreen={currentScreen}
          setCurrentScreen={setCurrentScreen}
          lastDetectedSound={lastDetectedSound}
          setLastDetectedSound={setLastDetectedSound}
          showTextAlert={showTextAlert}
          setShowTextAlert={setShowTextAlert}
          showIconAlert={showIconAlert}
          setShowIconAlert={setShowIconAlert}
          isListening={isListening}
          setIsListening={setIsListening}
          mode={mode}
          setMode={setMode}
          historyList={historyList}
          onTriggerEmergency={handleTriggerEmergency}
          isVibrating={isVibrating}
          vibrationPattern={vibrationPattern}
          vibrationProgress={vibrationProgress}
          onTriggerSound={handleSoundTrigger}
          onTriggerHapticVibration={triggerHapticVibration}
        />
      </div>
    </div>
  );
}
