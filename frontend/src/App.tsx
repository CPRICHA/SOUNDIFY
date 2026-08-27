<<<<<<< HEAD
import React, {
  useState,
  useEffect,
  useRef,
  useCallback,
} from 'react';

import { DeviceSimulator } from './components/DeviceSimulator';

import {
  SoundLabel,
  SoundEvent,
  UserProfile,
  SeverityType,
  ClassifyPrediction,
} from './types';

import {
  classifyAudio,
  DETECTION_CONFIDENCE_THRESHOLD,
  DETECTION_COOLDOWN_MS,
} from './services/detectClient';

import { mapModelClassToSoundLabel } from './data/modelLabelMap';

import { getSoundPriority } from './data/priorityMatrix';

import {
  startMicCapture,
  MicCaptureHandle,
  MicCaptureStatus,
  MIC_CHUNK_DURATION_SEC,
} from './services/micCapture';

export default function App() {
  // ============================================================
  // GLOBAL USER STATE
  // ============================================================

  const [userProfile, setUserProfile] =
    useState<UserProfile>({
      id: 'usr_123',
      name: 'John Doe',
      age: 28,
      phone: '+15551234567',
      email: 'deekshakuselan23@gmail.com',
      micAccess: true,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      outputPreferences: [
        'text',
        'icon',
        'color',
      ],
      emergencyContactName: '',
      emergencyContactPhone: '',
      muteLowAlerts: false,
      gpsAutoDetect: false,
      language: 'English',
      textSize: 'medium',
      highContrast: false,
    });

  const [currentScreen, setCurrentScreen] =
    useState<string>('splash');

  const [lastDetectedSound, setLastDetectedSound] =
    useState<SoundLabel | null>(null);

  const [showTextAlert, setShowTextAlert] =
    useState<boolean>(false);
=======
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
    savedLocations: [
      { id: 'loc_home', name: 'Home', address: '124 Maple Street, Apt 3B', createdAt: Date.now() - 100000 },
      { id: 'loc_work', name: 'Office', address: '742 Evergreen Tech Park, Tower B', createdAt: Date.now() - 50000 }
    ],
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
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4

  const [showIconAlert, setShowIconAlert] =
    useState<boolean>(false);

<<<<<<< HEAD
  // ============================================================
  // LISTENING + ENVIRONMENT
  // ============================================================

  const [isListening, setIsListening] =
    useState<boolean>(false);

  const [mode, setMode] =
    useState<'indoor' | 'outdoor'>('indoor');

  // ============================================================
  // HISTORY
  // ============================================================

  const [historyList, setHistoryList] =
    useState<SoundEvent[]>([]);

  // ============================================================
  // HAPTIC SIMULATION
  // ============================================================

  const [isVibrating, setIsVibrating] =
    useState<boolean>(false);

  const [vibrationPattern, setVibrationPattern] =
    useState<string>('');

  const [vibrationProgress, setVibrationProgress] =
    useState<number>(0);

  // ============================================================
  // TWILIO EMERGENCY LOGGING
  // ============================================================

  const [twilioLogs, setTwilioLogs] = useState<
    Array<{
      id: string;
      message: string;
      recipient: string;
      timestamp: string;
      actionType: string;
    }>
  >([]);

  // ============================================================
  // STAGE 2 WAV TEST PANEL
  // ============================================================

  const [mlWavFile, setMlWavFile] =
    useState<File | null>(null);

  const [mlPrediction, setMlPrediction] =
    useState<ClassifyPrediction | null>(null);

  const [mlError, setMlError] =
    useState<string | null>(null);

  const [mlBusy, setMlBusy] =
    useState(false);

  const [mlMappedLabel, setMlMappedLabel] =
    useState<SoundLabel | null>(null);

  // ============================================================
  // STAGE 3 LIVE MIC
  // ============================================================

  const [micStatus, setMicStatus] =
    useState<MicCaptureStatus>('idle');

  const [micStatusDetail, setMicStatusDetail] =
    useState<string>('');

  const [livePrediction, setLivePrediction] =
    useState<ClassifyPrediction | null>(null);

  const micHandleRef =
    useRef<MicCaptureHandle | null>(null);

  const cooldownUntilRef =
    useRef<Record<string, number>>({});

  // ============================================================
  // ACTIVE SOUND / STABILITY
  // ============================================================

  const activeSoundRef =
    useRef<SoundLabel | null>(null);

  const ALERT_SWITCH_CONFIDENCE = 0.60;

  const consecutiveFailRef =
    useRef(0);

  const isListeningRef =
    useRef(isListening);

  const userProfileRef =
    useRef(userProfile);

  const modeRef =
    useRef(mode);

  isListeningRef.current =
    isListening;

  userProfileRef.current =
    userProfile;

  modeRef.current =
    mode;

  // ============================================================
  // INITIAL SERVER STATE
  // ============================================================

=======
  // Load initial states from server on mount
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
  useEffect(() => {
    fetchProfile();
    fetchHistory();
  }, []);

  const fetchProfile = async () => {
    try {
      const res = await fetch(
        '/api/users/usr_123/profile'
      );

      if (res.ok) {
        const data =
          await res.json();

        setUserProfile(data);
      }
    } catch (e) {
<<<<<<< HEAD
      console.error(
        'Error fetching profile',
        e
      );
=======
      console.error("Error fetching profile", e);
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    }
  };

  const fetchHistory = async () => {
    try {
      const res = await fetch(
        '/api/sound-events/usr_123'
      );

      if (res.ok) {
        const data =
          await res.json();

        setHistoryList(data);
      }
    } catch (e) {
<<<<<<< HEAD
      console.error(
        'Error fetching event logs',
        e
      );
=======
      console.error("Error fetching event logs", e);
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    }
  };

  // ============================================================
  // SYNC PROFILE
  // ============================================================

  useEffect(() => {
    if (userProfile.id) {
<<<<<<< HEAD
      fetch(
        `/api/users/${userProfile.id}/profile`,
        {
          method: 'PUT',
          headers: {
            'Content-Type':
              'application/json',
          },
          body: JSON.stringify(
            userProfile
          ),
        }
      ).catch((e) =>
        console.error(
          'Error syncing profile update',
          e
        )
      );
    }
  }, [userProfile]);

  // ============================================================
  // UPDATE DISPLAYED SOUND WHEN MODE CHANGES
  //
  // Example:
  //
  // Engine Idling
  // Indoor  → low
  // Outdoor → medium
  //
  // ============================================================

  useEffect(() => {
    if (!lastDetectedSound) {
      return;
    }

    const contextualPriority =
      getSoundPriority(
        lastDetectedSound,
        mode
      );

    if (
      lastDetectedSound.severity !==
      contextualPriority
    ) {
      setLastDetectedSound(
        (previous) => {
          if (!previous) {
            return null;
          }

          return {
            ...previous,
            severity:
              contextualPriority,
          };
        }
      );
    }

    if (
      activeSoundRef.current
    ) {
      activeSoundRef.current = {
        ...activeSoundRef.current,
        severity:
          contextualPriority,
      };
    }
  }, [mode]);

  // ============================================================
  // HAPTIC VIBRATION
  //
  // critical  = Critical 🔴
  // attention = High    🟠
  // medium    = Medium  🟡
  // low       = Low     🟢
  // ============================================================

  const triggerHapticVibration = (
    severity: SeverityType
  ) => {
=======
      fetch(`/api/users/${userProfile.id}/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userProfile)
      }).catch(e => console.error("Error syncing profile update", e));
    }
  }, [userProfile]);

  // Triggers haptic simulation on desktop and invokes Web Vibration API on phone/mobile screens
  const triggerHapticVibration = (severity: SeverityType) => {
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    setIsVibrating(true);

    let patternText = '';
    let duration = 0;
    let webPattern: number[] = [];

<<<<<<< HEAD
    if (
      severity === 'critical'
    ) {
      patternText =
        'Critical (Strong Continuous Pulse)';

      duration = 1500;

      webPattern = [
        250,
        50,
        250,
        50,
        250,
        50,
        250,
        50,
        250,
      ];
    } else if (
      severity === 'attention'
    ) {
      patternText =
        'High (Strong Double-beat)';

=======
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
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
      duration = 1000;

      webPattern = [
        200,
        100,
        200,
      ];
    } else if (
      severity === 'medium'
    ) {
      patternText =
        'Medium (Moderate Double-beat)';

      duration = 800;

      webPattern = [
        100,
        100,
        100,
        200,
        100,
      ];
    } else {
      patternText =
        'Low (Single Tap)';

      duration = 400;

      webPattern = [50];
    }

    setVibrationPattern(
      patternText
    );

    setVibrationProgress(100);

<<<<<<< HEAD
    if (
      'vibrate' in navigator
    ) {
=======
    // Call native Web Vibration API
    if ('vibrate' in navigator) {
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
      try {
        navigator.vibrate(
          webPattern
        );
      } catch (e) {
<<<<<<< HEAD
        console.warn(
          'Navigator vibration blocked inside frame permissions.'
        );
      }
    }

    const step =
      100 /
      (duration / 50);

    const interval =
      setInterval(() => {
        setVibrationProgress(
          (prev) => {
            if (prev <= 0) {
              clearInterval(
                interval
              );

              setIsVibrating(
                false
              );

              return 0;
            }

            return prev - step;
          }
        );
      }, 50);
  };

  // ============================================================
  // SHARED ALERT PATH
  //
  // This is the most important change.
  //
  // The model/taxonomy gives us the sound.
  // The priority matrix gives us the priority
  // based on Indoor/Outdoor mode.
  // ============================================================

  const handleSoundTrigger =
    useCallback(
      async (
        sound: SoundLabel
      ) => {
        if (
          !isListeningRef.current
        ) {
          return;
=======
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
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
        }

<<<<<<< HEAD
        const profile =
          userProfileRef.current;

        const currentMode =
          modeRef.current;

        // ------------------------------------------------------
        // Calculate contextual priority
        // ------------------------------------------------------

        const contextualPriority =
          getSoundPriority(
            sound,
            currentMode
          );

        // ------------------------------------------------------
        // Create a contextual copy.
        //
        // We DON'T modify the taxonomy itself.
        // Only this active alert receives the contextual
        // severity.
        // ------------------------------------------------------

        const contextualSound:
          SoundLabel = {
            ...sound,
            severity:
              contextualPriority,
          };

        // ------------------------------------------------------
        // Mute low alerts if enabled
        // ------------------------------------------------------

        const isMuted =
          contextualPriority ===
            'low' &&
          profile.muteLowAlerts;

        // ------------------------------------------------------
        // Update active sound
        // ------------------------------------------------------

        setLastDetectedSound(
          contextualSound
        );

        activeSoundRef.current =
          contextualSound;

        // ------------------------------------------------------
        // Visual + haptic alert
        // ------------------------------------------------------

        if (!isMuted) {
          setShowTextAlert(
            true
          );

          setShowIconAlert(
            true
          );

          triggerHapticVibration(
            contextualPriority
          );
        } else {
          setShowTextAlert(
            false
          );

          setShowIconAlert(
            false
          );
        }

        // ------------------------------------------------------
        // Log contextual priority
        // ------------------------------------------------------

        try {
          const res =
            await fetch(
              '/api/sound-events',
              {
                method: 'POST',
                headers: {
                  'Content-Type':
                    'application/json',
                },
                body: JSON.stringify({
                  user_id:
                    profile.id ||
                    'usr_123',

                  label:
                    sound.name,

                  severity:
                    contextualPriority,

                  mode:
                    currentMode,

                  timestamp:
                    new Date().toISOString(),
                }),
              }
            );

          if (res.ok) {
            fetchHistory();
          }
        } catch (e) {
          console.error(
            'Error logging sound event',
            e
          );
        }
      },
      []
    );

  // ============================================================
  // EMERGENCY
  // ============================================================

  const handleTriggerEmergency =
    async (
      actionType: string,
      message: string
    ) => {
      try {
        const res =
          await fetch(
            '/api/emergency/contact',
            {
              method: 'POST',
              headers: {
                'Content-Type':
                  'application/json',
              },
              body: JSON.stringify({
                user_id:
                  userProfile.id ||
                  'usr_123',

                message:
                  message,

                action_type:
                  actionType,
              }),
            }
          );

        if (res.ok) {
          const data =
            await res.json();

          const newLog = {
            id: `log_${Math.random()
              .toString(36)
              .substring(2, 8)}`,

            message:
              data.dispatch_message,

            recipient:
              data.recipient,

            timestamp:
              new Date().toLocaleTimeString(),

            actionType:
              data.action_type,
          };

          setTwilioLogs(
            (prev) => [
              newLog,
              ...prev,
            ]
          );
        }
      } catch (e) {
        console.error(
          'Error triggering emergency helper',
          e
        );
      }
    };

  // ============================================================
  // LIVE PREDICTION
  // ============================================================

  const processLivePrediction =
    useCallback(
      async (
        prediction: ClassifyPrediction
      ) => {
        // Always show latest raw ML prediction
        setLivePrediction(
          prediction
        );

        // ------------------------------------------------------
        // 1. Confidence threshold
        // ------------------------------------------------------

        if (
          prediction.confidence <
          DETECTION_CONFIDENCE_THRESHOLD
        ) {
          console.log(
            `[detect] low confidence class=${prediction.predicted_class} confidence=${prediction.confidence.toFixed(
              2
            )}`
          );

          return;
        }

        // ------------------------------------------------------
        // 2. Model class → frontend taxonomy
        // ------------------------------------------------------

        const mapped =
          mapModelClassToSoundLabel(
            prediction.predicted_class
          );

        if (!mapped) {
          console.log(
            `[detect] unmapped model label: ${prediction.predicted_class}`
          );

          return;
        }

        // ------------------------------------------------------
        // 3. Stability / hysteresis
        // ------------------------------------------------------

        const currentSound =
          activeSoundRef.current;

        if (
          currentSound &&
          currentSound.id !==
            mapped.id
        ) {
          if (
            prediction.confidence <
            ALERT_SWITCH_CONFIDENCE
          ) {
            console.log(
              `[detect] keeping current=${currentSound.id}; ` +
                `candidate=${mapped.id}; ` +
                `confidence=${prediction.confidence.toFixed(
                  2
                )}`
            );

            return;
          }

          console.log(
            `[detect] strong new prediction: ` +
              `${mapped.id} ${prediction.confidence.toFixed(
                2
              )}`
          );
        }

        // ------------------------------------------------------
        // 4. Cooldown
        // ------------------------------------------------------

        const now =
          Date.now();

        const until =
          cooldownUntilRef.current[
            mapped.id
          ] ?? 0;

        if (now < until) {
          console.log(
            `[detect] cooldown skip class=${prediction.predicted_class} id=${mapped.id}`
          );

          return;
        }

        // ------------------------------------------------------
        // 5. Remember active sound
        // ------------------------------------------------------

        activeSoundRef.current =
          mapped;

        cooldownUntilRef.current[
          mapped.id
        ] =
          now +
          DETECTION_COOLDOWN_MS;

        console.log(
          `[detect] alert class=${prediction.predicted_class} → ${mapped.id}`
        );

        // ------------------------------------------------------
        // 6. Shared alert path calculates Indoor/Outdoor
        // priority.
        // ------------------------------------------------------

        await handleSoundTrigger(
          mapped
        );
      },
      [handleSoundTrigger]
    );

  // ============================================================
  // START / STOP MICROPHONE
  // ============================================================

  useEffect(() => {
    let cancelled = false;

    const stopMic = () => {
      if (
        micHandleRef.current
      ) {
        micHandleRef.current.stop();

        micHandleRef.current =
          null;
      }
    };

    if (!isListening) {
      stopMic();

      setMicStatus(
        'idle'
      );

      setMicStatusDetail(
        ''
      );

      consecutiveFailRef.current =
        0;

      activeSoundRef.current =
        null;

      return;
    }

    (async () => {
      try {
        const handle =
          await startMicCapture(
            {
              chunkDurationSec:
                MIC_CHUNK_DURATION_SEC,

              onStatus: (
                status,
                detail
              ) => {
                if (
                  cancelled
                ) {
                  return;
                }

                setMicStatus(
                  status
                );

                setMicStatusDetail(
                  detail || ''
                );
              },

              onError: (
                error
              ) => {
                if (
                  cancelled
                ) {
                  return;
                }

                setMicStatusDetail(
                  error.message
                );
              },

              onChunk:
                async (
                  wavBlob
                ) => {
                  if (
                    cancelled ||
                    !isListeningRef.current
                  ) {
                    return;
                  }

                  try {
                    const prediction =
                      await classifyAudio(
                        wavBlob
                      );

                    consecutiveFailRef.current =
                      0;

                    if (
                      cancelled ||
                      !isListeningRef.current
                    ) {
                      return;
                    }

                    await processLivePrediction(
                      prediction
                    );
                  } catch (
                    err
                  ) {
                    consecutiveFailRef.current +=
                      1;

                    console.error(
                      '[detect] classification failed',
                      err
                    );

                    const message =
                      err instanceof
                      Error
                        ? err.message
                        : String(
                            err
                          );

                    setMicStatusDetail(
                      consecutiveFailRef.current >=
                        3
                        ? 'Detection unavailable'
                        : message
                    );

                    if (
                      consecutiveFailRef.current >=
                      3
                    ) {
                      console.error(
                        '[detect] stopping after repeated ML failures'
                      );

                      setMicStatus(
                        'error'
                      );

                      setIsListening(
                        false
                      );
                    }
                  }
                },
            }
          );

        if (cancelled) {
          handle.stop();
          return;
        }

        micHandleRef.current =
          handle;

        setUserProfile(
          (prev) =>
            prev.micAccess
              ? prev
              : {
                  ...prev,
                  micAccess:
                    true,
                }
        );
      } catch (
        err
      ) {
        if (cancelled) {
          return;
        }

        const message =
          err instanceof
          Error
            ? err.message
            : String(
                err
              );

        console.error(
          '[mic] failed to start',
          err
        );

        setMicStatus(
          'error'
        );

        setMicStatusDetail(
          message
        );

        setIsListening(
          false
        );

        setUserProfile(
          (prev) => ({
            ...prev,
            micAccess:
              false,
          })
        );
      }
    })();

    return () => {
      cancelled = true;
      stopMic();
    };
  }, [
    isListening,
    processLivePrediction,
  ]);

  // ============================================================
  // STAGE 2 WAV CLASSIFICATION
  // ============================================================

  const handleMlClassify =
    async () => {
      if (!mlWavFile) {
        setMlError(
          'Select a .wav file first.'
        );

        return;
      }

      setMlBusy(true);
      setMlError(null);
      setMlPrediction(null);
      setMlMappedLabel(null);

      try {
        const prediction =
          await classifyAudio(
            mlWavFile
          );

        setMlPrediction(
          prediction
        );

        const mapped =
          mapModelClassToSoundLabel(
            prediction.predicted_class
          );

        setMlMappedLabel(
          mapped
        );

        if (mapped) {
          // ----------------------------------------------------
          // Calculate contextual priority
          // ----------------------------------------------------

          const contextualPriority =
            getSoundPriority(
              mapped,
              modeRef.current
            );

          const contextualSound:
            SoundLabel = {
              ...mapped,
              severity:
                contextualPriority,
            };

          // ----------------------------------------------------
          // Stage 2 debug alert
          // ----------------------------------------------------

          if (
            !isListeningRef.current
          ) {
            setIsListening(
              true
            );

            setLastDetectedSound(
              contextualSound
            );

            activeSoundRef.current =
              contextualSound;

            setShowTextAlert(
              true
            );

            setShowIconAlert(
              true
            );

            triggerHapticVibration(
              contextualPriority
            );
          } else {
            await handleSoundTrigger(
              mapped
            );
          }

          console.log(
            '[stage2] mapped prediction → alert',
            mapped.id,
            'priority:',
            contextualPriority
          );
        } else {
          console.log(
            `[detect] unmapped model label: ${prediction.predicted_class}`
          );
        }
      } catch (
        err
      ) {
        const message =
          err instanceof
          Error
            ? err.message
            : String(
                err
              );

        console.error(
          '[stage2] classify failed',
          err
        );

        setMlError(
          message
        );
      } finally {
        setMlBusy(
          false
        );
      }
    };

  // ============================================================
  // LIVE STATUS
  // ============================================================

  const liveStatusLabel =
    (() => {
      if (
        micStatus ===
        'requesting'
      ) {
        return 'Microphone permission required';
      }

      if (
        micStatus ===
        'listening'
      ) {
        return 'Listening';
      }

      if (
        micStatus ===
        'analyzing'
      ) {
        return 'Analyzing';
      }

      if (
        micStatus ===
        'error'
      ) {
        return (
          micStatusDetail ||
          'Detection unavailable'
        );
      }

      if (!isListening) {
        return 'Not listening';
      }

      return (
        micStatusDetail ||
        'Idle'
      );
    })();

  // ============================================================
  // RENDER
  // ============================================================

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col md:flex-row items-center justify-center gap-6 p-4 md:p-8 select-none">

      {/* ======================================================
          SMARTPHONE DEVICE SIMULATOR
          ====================================================== */}

=======
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

      // Trigger Web Notification API if granted (for desktop / external browser window testing)
      if (typeof window !== 'undefined' && 'Notification' in window && Notification.permission === 'granted') {
        try {
          new Notification(`Sound Detected: ${sound.name}`, {
            body: `Priority: ${sound.severity.toUpperCase()} • Mode: ${mode.toUpperCase()} • Category: ${sound.category}`,
            icon: '/favicon.ico',
            tag: 'sound-alert',
          });
        } catch (e) {
          console.warn("Web notification trigger note:", e);
        }
      }
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
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
      <div className="shrink-0 flex flex-col items-center">
        <DeviceSimulator
          userProfile={
            userProfile
          }
          setUserProfile={
            setUserProfile
          }
          currentScreen={
            currentScreen
          }
          setCurrentScreen={
            setCurrentScreen
          }
          lastDetectedSound={
            lastDetectedSound
          }
          setLastDetectedSound={
            setLastDetectedSound
          }
          showTextAlert={
            showTextAlert
          }
          setShowTextAlert={
            setShowTextAlert
          }
          showIconAlert={
            showIconAlert
          }
          setShowIconAlert={
            setShowIconAlert
          }
          isListening={
            isListening
          }
          setIsListening={
            setIsListening
          }
          mode={mode}
          setMode={
            setMode
          }
          historyList={
            historyList
          }
          onTriggerEmergency={
            handleTriggerEmergency
          }
          isVibrating={
            isVibrating
          }
          vibrationPattern={
            vibrationPattern
          }
          vibrationProgress={
            vibrationProgress
          }
          onTriggerSound={
            handleSoundTrigger
          }
          onTriggerHapticVibration={
            triggerHapticVibration
          }
        />
      </div>
<<<<<<< HEAD

      {/* ======================================================
          STAGE 2 + STAGE 3 DEV PANEL
          ====================================================== */}

      <div className="w-full max-w-sm select-text rounded-lg border border-dashed border-slate-300 bg-white p-4 text-left text-xs text-slate-700 shadow-sm">

        <div className="mb-2 font-mono text-[10px] uppercase tracking-wide text-slate-400">
          Stage 3 · Live mic + Stage 2 WAV fallback
        </div>

        <div className="mb-3 rounded border border-slate-200 bg-slate-50 p-2 text-[11px]">

          <div className="font-semibold text-slate-800">
            Live mic:{' '}
            {liveStatusLabel}
          </div>

          <div className="mt-1 text-slate-500">
            Chunk{' '}
            {MIC_CHUNK_DURATION_SEC}
            s · threshold{' '}
            {
              DETECTION_CONFIDENCE_THRESHOLD
            }{' '}
            · cooldown{' '}
            {
              DETECTION_COOLDOWN_MS
            }
            ms
          </div>

          {livePrediction && (
            <div className="mt-1 font-mono text-[10px] text-slate-600">
              Last:{' '}
              {
                livePrediction.predicted_class
              }{' '}
              {(
                livePrediction.confidence *
                100
              ).toFixed(1)}
              % ·{' '}
              {Math.round(
                livePrediction.inference_ms
              )}
              ms
            </div>
          )}

          <p className="mt-2 text-[10px] leading-snug text-slate-500">
            Tap the phone mic to
            enable listening
            (requests permission).
            Stop listening to
            release the microphone.
          </p>
        </div>

        <p className="mb-3 text-[11px] leading-snug text-slate-500">
          WAV fallback: POST via{' '}
          <code className="text-slate-700">
            /api/detect/classify
          </code>
          . Simulator dropdown
          still works while
          listening.
        </p>

        <input
          type="file"
          accept=".wav,audio/wav"
          className="mb-2 block w-full text-[11px]"
          onChange={(e) => {
            setMlWavFile(
              e.target.files?.[0] ??
                null
            );

            setMlPrediction(
              null
            );

            setMlError(null);

            setMlMappedLabel(
              null
            );
          }}
        />

        <button
          type="button"
          disabled={
            mlBusy ||
            !mlWavFile
          }
          onClick={
            handleMlClassify
          }
          className="mb-3 w-full rounded bg-slate-800 px-3 py-2 text-[11px] font-semibold text-white disabled:cursor-not-allowed disabled:opacity-40"
        >
          {mlBusy
            ? 'Classifying…'
            : 'Classify WAV via ML'}
        </button>

        {mlError && (
          <div className="mb-2 rounded border border-red-200 bg-red-50 p-2 text-[11px] text-red-700">
            {mlError}
          </div>
        )}

        {mlPrediction && (
          <div className="space-y-1 rounded border border-slate-200 bg-slate-50 p-2 font-mono text-[11px]">

            <div>
              Predicted sound:{' '}
              <span className="font-semibold text-slate-900">
                {
                  mlPrediction.predicted_class
                }
              </span>
            </div>

            <div>
              Confidence:{' '}
              <span className="font-semibold">
                {mlPrediction.confidence_percent.toFixed(
                  2
                )}
                %
              </span>
            </div>

            <div>
              Inference:{' '}
              <span className="font-semibold">
                {Math.round(
                  mlPrediction.inference_ms
                )}{' '}
                ms
              </span>
            </div>

            <div className="text-slate-500">
              Model:{' '}
              {
                mlPrediction.model_name
              }{' '}
              ·{' '}
              {mlPrediction.duration_s.toFixed(
                2
              )}
              s
            </div>

            <div className="pt-1 text-slate-500">
              Mapped alert:{' '}
              {mlMappedLabel
                ? `${mlMappedLabel.id} → visual alert fired`
                : 'none (unmapped class)'}
            </div>

          </div>
        )}

      </div>
=======
>>>>>>> 6221bdc23c1901c8da415908318ddc9f37a0c3c4
    </div>
  );
}