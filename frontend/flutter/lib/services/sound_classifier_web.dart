import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import '../data/sound_taxonomy.dart';
import '../models/models.dart';
import 'sound_classifier_stub.dart';

class TFLiteSoundClassificationService implements SoundClassificationService {
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _timer;
  bool _isListening = false;
  bool _processing = false;

  static const String _backendUrl = 'http://127.0.0.1:8000/api/v1/classify';

  @override
  Future<void> initializeModel() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/health'));

    if (response.statusCode != 200) {
      throw Exception('AIISH backend is not ready');
    }

    print('WEB: AIISH backend connected');
  }

  @override
  Future<void> startListening(
    Function(SoundLabel detectedSound, double confidence) onSoundDetected,
  ) async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission denied');
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

    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      final chunks = <int>[];
      final subscription = stream.listen(chunks.addAll);

      await Future.delayed(const Duration(seconds: 3));

      await _recorder.stop();
      await subscription.cancel();

      if (chunks.isEmpty) {
        print('WEB: No microphone audio captured');
        return;
      }

      final request = http.MultipartRequest('POST', Uri.parse(_backendUrl));

      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          chunks,
          filename: 'recording.wav',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        print(
          'WEB: Backend error ${response.statusCode}: '
          '${response.body}',
        );
        return;
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      final predictedClass = result['predicted_class'] as String;
      final confidence = (result['confidence'] as num).toDouble();

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

      if (soundId == null) {
        print('WEB: Unknown model class: $predictedClass');
        return;
      }

      SoundLabel? matchedSound;

      for (final sound in soundTaxonomy) {
        if (sound.id == soundId) {
          matchedSound = sound;
          break;
        }
      }

      print(
        'WEB AIISH PREDICTION: $predictedClass '
        '(${(confidence * 100).toStringAsFixed(1)}%)',
      );

      if (matchedSound != null) {
        onSoundDetected(matchedSound, confidence);
      }
    } catch (e) {
      print('WEB AIISH ERROR: $e');
    } finally {
      _processing = false;
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;

    _timer?.cancel();
    _timer = null;

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }
}
