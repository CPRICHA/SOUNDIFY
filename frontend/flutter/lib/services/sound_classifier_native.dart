import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/sound_taxonomy.dart';
import '../models/models.dart';
import 'sound_classifier_stub.dart';

class TFLiteSoundClassificationService implements SoundClassificationService {
  final AudioRecorder _recorder = AudioRecorder();

  Interpreter? _yamnet;
  Interpreter? _classifier;

  Timer? _timer;
  bool _isListening = false;
  bool _processing = false;

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
        onSoundDetected(matchedSound, confidence);
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

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }
}
