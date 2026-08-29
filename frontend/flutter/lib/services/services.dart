import 'dart:async';
import 'dart:typed_data';
//import 'dart:math';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'sound_classifier_stub.dart';

/// -------------------------------------------------------------
/// AUTH SERVICE INTERFACE & FIREBASE IMPLEMENTATION
/// -------------------------------------------------------------
abstract class AuthService {
  Future<UserProfile?> signIn(String email, String password);
  Future<UserProfile?> signUp(UserProfile profile, String password);
  Future<void> signOut();
  UserProfile? get currentUser;
  Stream<UserProfile?> get authStateChanges;
}

class FirebaseAuthService implements AuthService {
  UserProfile? _currentUser;
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Stream<UserProfile?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        _currentUser = null;
        _controller.add(null);
        return null;
      }

      final mapped = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'User',
        age: 0,
        phone: '',
        email: user.email ?? '',
        micAccess: true,
        termsAccepted: true,
        privacyPolicyAccepted: true,
        outputPreferences: const ['text', 'icon', 'color'],
      );

      _currentUser = mapped;
      _controller.add(mapped);
      return mapped;
    });
  }

  String _friendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<UserProfile?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return null;
      }

      final profile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'User',
        age: 0,
        phone: '',
        email: user.email ?? email.trim(),
        micAccess: true,
        termsAccepted: true,
        privacyPolicyAccepted: true,
        outputPreferences: const ['text', 'icon', 'color'],
      );

      _currentUser = profile;
      _controller.add(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  @override
  Future<UserProfile?> signUp(UserProfile profile, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: profile.email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return null;
      }

      final authenticatedProfile = UserProfile(
        id: user.uid,
        name: profile.name,
        age: profile.age,
        phone: profile.phone,
        email: user.email ?? profile.email,
        micAccess: profile.micAccess,
        termsAccepted: profile.termsAccepted,
        privacyPolicyAccepted: profile.privacyPolicyAccepted,
        outputPreferences: profile.outputPreferences,
        emergencyContactName: profile.emergencyContactName,
        emergencyContactPhone: profile.emergencyContactPhone,
        muteLowAlerts: profile.muteLowAlerts,
        muteMediumAlerts: profile.muteMediumAlerts,
        gpsAutoDetect: profile.gpsAutoDetect,
        savedLocations: profile.savedLocations,
        language: profile.language,
        textSize: profile.textSize,
        highContrast: profile.highContrast,
      );

      _currentUser = authenticatedProfile;
      _controller.add(authenticatedProfile);
      return authenticatedProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
    await FirebaseAuth.instance.signOut();
  }
}

/// -------------------------------------------------------------
/// SOUND CLASSIFICATION SERVICE INTERFACE & ON-DEVICE TFLITE SEAM
abstract class SoundClassificationService {
  Future<void> initializeModel();
  Future<void> startListening(
    Function(SoundLabel detectedSound, double confidence) onSoundDetected,
  );
  Future<void> stopListening();
}

class TFLiteSoundClassificationService implements SoundClassificationService {
  final AudioRecorder _recorder = AudioRecorder();

  Interpreter? _yamnet;
  Interpreter? _classifier;

  Timer? _timer;
  bool _isListening = false;
  bool _processing = false;

  /// Minimal offline alert guard to avoid repeated notifications for the same sound.
  double _confidenceThreshold = 0.75;
  Duration _cooldown = const Duration(seconds: 8);
  DateTime? _lastAlertAt;
  String? _lastAlertSoundId;

  @override
  Future<void> initializeModel() async {
    _yamnet = await Interpreter.fromAsset(
      'assets/models/yamnet_embeddings.tflite',
    );

    _classifier = await Interpreter.fromAsset(
      'assets/models/AIISH_v2.tflite',
    );

    print('AIISH offline models loaded successfully');
  }

  @override
  Future<void> startListening(
    Function(SoundLabel detectedSound, double confidence) onSoundDetected,
  ) async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission denied');
    }

    if (_yamnet == null || _classifier == null) {
      await initializeModel();
    }

    _isListening = true;

    await _captureAndClassify(onSoundDetected);

    _timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_isListening && !_processing) {
        await _captureAndClassify(onSoundDetected);
      }
    });
  }

  Future<void> _captureAndClassify(
    Function(SoundLabel detectedSound, double confidence) onSoundDetected,
  ) async {
    if (_processing) return;
    _processing = true;

    String? recordedPath;

    try {
      final tempDirectory = await getTemporaryDirectory();

      final path =
          '${tempDirectory.path}/aiish_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      await Future.delayed(const Duration(seconds: 3));

      recordedPath = await _recorder.stop();
      if (recordedPath == null) return;

      final waveform = await _readWavAsFloat32(recordedPath);

      if (waveform.length != 48000) {
        print('Unexpected audio length: ${waveform.length}');
        return;
      }

      final yamnetOutput = List.generate(
        6,
        (_) => List<double>.filled(1024, 0.0),
      );

      _yamnet!.run(waveform, yamnetOutput);

      final meanEmbedding = List<double>.filled(1024, 0.0);

      for (var frame = 0; frame < 6; frame++) {
        for (var i = 0; i < 1024; i++) {
          meanEmbedding[i] += yamnetOutput[frame][i] / 6.0;
        }
      }

      final classifierInput = [meanEmbedding];
      final classifierOutput = [
        List<double>.filled(25, 0.0),
      ];

      _classifier!.run(classifierInput, classifierOutput);

      final probabilities = classifierOutput[0];

      var bestIndex = 0;
      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > probabilities[bestIndex]) {
          bestIndex = i;
        }
      }

      final confidence = probabilities[bestIndex];

      const modelClasses = [
        'Air Conditioner',
        'Alarm',
        'Approaching Vehicles',
        'Baby Crying',
        'Cat Meowing',
        'Children Playing',
        'Construction Sound',
        'Cow Mooing',
        'Dog Bark',
        'Door Knock',
        'Doorbell',
        'Engine Idling',
        'Firecrackers',
        'Glass Breaking',
        'Gun Shot',
        'Microwave Oven Beep',
        'Mixer Grinder',
        'Pressure Cooker Whistle',
        'Siren',
        'Street Music',
        'Temple Bell',
        'Train Horn',
        'Utensils',
        'Vehicle Horn',
        'Water Running',
      ];

      final predictedClass = modelClasses[bestIndex];

      const modelOutputToSoundId = <String, String>{
        'Air Conditioner': 'air_conditioner',
        'Alarm': 'alarm_fire_smoke',
        'Approaching Vehicles': 'approaching_vehicles',
        'Baby Crying': 'baby_crying',
        'Cat Meowing': 'cat_meow',
        'Children Playing': 'children_playing',
        'Construction Sound': 'construction_sounds',
        'Cow Mooing': 'cow_mooing',
        'Dog Bark': 'dog_bark',
        'Door Knock': 'door_knock',
        'Doorbell': 'doorbell',
        'Engine Idling': 'engine_idling',
        'Firecrackers': 'fire_crackers',
        'Glass Breaking': 'glass_breaking',
        'Gun Shot': 'blasts',
        'Microwave Oven Beep': 'microwave_beep',
        'Mixer Grinder': 'mixer_grinder',
        'Pressure Cooker Whistle': 'pressure_cooker',
        'Siren': 'siren_emergency',
        'Street Music': 'street_music',
        'Temple Bell': 'temple_bell',
        'Train Horn': 'train_horn',
        'Utensils': 'utensils',
        'Vehicle Horn': 'vehicle_horn',
        'Water Running': 'water_running',
      };

      final soundId = modelOutputToSoundId[predictedClass];

      SoundLabel? matchedSound;

      if (soundId != null) {
        for (final sound in soundTaxonomy) {
          if (sound.id == soundId) {
            matchedSound = sound;
            break;
          }
        }
      }

      print(
        'AIISH offline prediction: $predictedClass '
        '(${(confidence * 100).toStringAsFixed(1)}%)',
      );

      if (matchedSound != null) {
        final now = DateTime.now();
        final shouldTrigger = confidence >= _confidenceThreshold &&
            ( _lastAlertSoundId != matchedSound.id ||
              _lastAlertAt == null ||
              now.difference(_lastAlertAt!) >= _cooldown );

        if (shouldTrigger) {
          _lastAlertAt = now;
          _lastAlertSoundId = matchedSound.id;
          onSoundDetected(matchedSound, confidence);
        }
      }
    } catch (e) {
      print('AIISH offline inference error: $e');
    } finally {
      if (recordedPath != null) {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }

      _processing = false;
    }
  }

  Future<List<double>> _readWavAsFloat32(String path) async {
    final bytes = await File(path).readAsBytes();

    if (bytes.length < 44) {
      throw Exception('Invalid WAV file');
    }

    int? dataOffset;
    int? dataLength;

    var offset = 12;

    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(
        bytes.sublist(offset, offset + 4),
      );

      final chunkLength =
          bytes.buffer.asByteData().getUint32(offset + 4, Endian.little);

      if (chunkId == 'data') {
        dataOffset = offset + 8;
        dataLength = chunkLength;
        break;
      }

      offset += 8 + chunkLength + (chunkLength.isOdd ? 1 : 0);
    }

    if (dataOffset == null || dataLength == null) {
      throw Exception('WAV data chunk not found');
    }

    final availableLength =
        dataLength > bytes.length - dataOffset
            ? bytes.length - dataOffset
            : dataLength;

    final sampleCount = availableLength ~/ 2;
    final waveform = List<double>.filled(48000, 0.0);

    final byteData = bytes.buffer.asByteData(
      bytes.offsetInBytes,
      bytes.length,
    );

    final usableSamples = sampleCount > 48000 ? 48000 : sampleCount;

    for (var i = 0; i < usableSamples; i++) {
      final sample =
          byteData.getInt16(dataOffset + (i * 2), Endian.little);

      waveform[i] = sample / 32768.0;
    }

    return waveform;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _timer?.cancel();
    _timer = null;
    _lastAlertAt = null;
    _lastAlertSoundId = null;

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }
}
/// HISTORY & CLOUD SYNC SERVICE
/// -------------------------------------------------------------
abstract class HistorySyncService {
  Future<List<SoundEvent>> getLocalHistory();
  Future<void> logEvent(SoundEvent event);
  Future<void> syncWithCloud();
}

class HiveHistorySyncService implements HistorySyncService {
  final List<SoundEvent> _inMemoryEvents = [];

  @override
  Future<List<SoundEvent>> getLocalHistory() async {
    // In production, load from Hive Box:
    // var box = await Hive.openBox<SoundEvent>('sound_events');
    // return box.values.toList().reversed.toList();
    return List.from(_inMemoryEvents.reversed);
  }

  @override
  Future<void> logEvent(SoundEvent event) async {
    _inMemoryEvents.add(event);
    
    // In production, save to local Hive DB:
    // var box = Hive.box<SoundEvent>('sound_events');
    // await box.add(event);
    
    // Sync with backend API in background if online
    await syncWithCloud();
  }

  @override
  Future<void> syncWithCloud() async {
    // TODO: Implement background synchronization endpoint POST /sound-events
    // Web service calls to upload offline-cached logs
  }
}

/// -------------------------------------------------------------
/// EMERGENCY SERVICE
/// -------------------------------------------------------------
abstract class EmergencyService {
  Future<bool> triggerEmergencyAlert(String userId, String message, String actionType);
}

class MockEmergencyService implements EmergencyService {
  @override
  Future<bool> triggerEmergencyAlert(String userId, String message, String actionType) async {
    // TODO: Connect this to Twilio API or Firebase Cloud Function to dispatch SMS or automated phone call.
    // Example: http.post(Uri.parse('$backendUrl/emergency/contact'), body: {...});
    await Future.delayed(const Duration(milliseconds: 1000));
    print("EMERGENCY STUB TRIGGERED: User $userId dispatched '$actionType' action: '$message'");
    return true;
  }
}
