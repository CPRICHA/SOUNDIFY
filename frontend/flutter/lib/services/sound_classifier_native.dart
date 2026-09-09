import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/sound_taxonomy.dart';
import '../models/models.dart';
import 'sound_classifier_stub.dart';

class TFLiteSoundClassificationService
    implements SoundClassificationService {
  final AudioRecorder _recorder = AudioRecorder();

  Interpreter? _yamnet;
  Interpreter? _classifier;

  Timer? _timer;
  bool _isListening = false;
  bool _processing = false;

  // ----------------------------------------------------------
  // Prediction confirmation
  // ----------------------------------------------------------
  //
  // We do NOT immediately display every model prediction.
  //
  // Three consecutive predictions are collected.
  //
  // Example:
  //
  //   Dog Bark
  //   Doorbell
  //   Dog Bark
  //
  // → Dog Bark is confirmed because it appears 2/3 times.
  //
  // If there is no majority:
  //
  //   Dog Bark
  //   Doorbell
  //   Siren
  //
  // → No sound is displayed.
  //
  static const int _requiredPredictions = 3;
  static const int _requiredMajority = 2;

  final List<SoundLabel> _predictionBuffer = [];

  // ----------------------------------------------------------
  // Silence detection
  // ----------------------------------------------------------

  static const double _silenceRmsThreshold = 0.01;

  @override
  Future<void> initializeModel() async {
    // --------------------------------------------------------
    // Load YAMNet
    // --------------------------------------------------------

    _yamnet = await Interpreter.fromAsset(
      'assets/models/yamnet_embeddings.tflite',
    );

    // --------------------------------------------------------
    // Load AIISH V6 classifier
    // --------------------------------------------------------

    _classifier = await Interpreter.fromAsset(
      'assets/models/AIISH_v6.tflite',
    );

    print('AIISH V6 offline models loaded successfully');
  }

  @override
  Future<void> startListening(
    Function(SoundLabel? detectedSound, double confidence)
        onSoundDetected,
  ) async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission denied');
    }

    if (_yamnet == null || _classifier == null) {
      await initializeModel();
    }

    _isListening = true;

    // Start with a clean prediction buffer.
    _predictionBuffer.clear();

    // Run first recording immediately.
    await _captureAndClassify(onSoundDetected);

    // Continue checking every 4 seconds.
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) async {
        if (_isListening && !_processing) {
          await _captureAndClassify(onSoundDetected);
        }
      },
    );
  }

  Future<void> _captureAndClassify(
    Function(SoundLabel? detectedSound, double confidence)
        onSoundDetected,
  ) async {
    if (_processing) return;

    _processing = true;

    String? recordedPath;

    try {
      // ------------------------------------------------------
      // 1. Record 3 seconds of audio
      // ------------------------------------------------------

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

      await Future.delayed(
        const Duration(seconds: 3),
      );

      recordedPath = await _recorder.stop();

      if (recordedPath == null) {
        return;
      }

      // ------------------------------------------------------
      // 2. Read WAV as Float32 waveform
      // ------------------------------------------------------

      final waveform = await _readWavAsFloat32(
        recordedPath,
      );

      if (waveform.length != 48000) {
        print(
          'Unexpected audio length: ${waveform.length}',
        );
        return;
      }

      // ------------------------------------------------------
      // 3. Check for silence BEFORE running YAMNet
      // ------------------------------------------------------

      final rms = _calculateRms(waveform);

      print(
        'Audio RMS: ${rms.toStringAsFixed(6)}',
      );

      if (rms < _silenceRmsThreshold) {
        print(
          'AIISH V6 offline: silence detected',
        );

        // Clear any previous predictions.
        _predictionBuffer.clear();

        // Silence means there is nothing to display.
        onSoundDetected(null, 0.0);

        return;
      }

      // ------------------------------------------------------
      // 4. Run YAMNet
      // ------------------------------------------------------

      final yamnetOutput = List.generate(
        6,
        (_) => List<double>.filled(1024, 0.0),
      );

      _yamnet!.run(
        waveform,
        yamnetOutput,
      );

      // ------------------------------------------------------
      // 5. Mean-pool YAMNet embeddings
      // ------------------------------------------------------

      final meanEmbedding = List<double>.filled(
        1024,
        0.0,
      );

      for (var frame = 0; frame < 6; frame++) {
        for (var i = 0; i < 1024; i++) {
          meanEmbedding[i] +=
              yamnetOutput[frame][i] / 6.0;
        }
      }

      // ------------------------------------------------------
      // 6. Run AIISH V6 classifier
      // ------------------------------------------------------

      final classifierInput = [
        meanEmbedding,
      ];

      final classifierOutput = [
        List<double>.filled(
          26,
          0.0,
        ),
      ];

      _classifier!.run(
        classifierInput,
        classifierOutput,
      );

      final probabilities = classifierOutput[0];

      // ------------------------------------------------------
      // 7. Find highest-probability class
      // ------------------------------------------------------

      var bestIndex = 0;

      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] >
            probabilities[bestIndex]) {
          bestIndex = i;
        }
      }

      final confidence = probabilities[bestIndex];

      // ------------------------------------------------------
      // 8. AIISH V6 class mapping
      // ------------------------------------------------------

      const modelClasses = [
        'Air Conditioner',          // 0
        'Alarm',                    // 1
        'Approaching Vehicles',     // 2
        'Baby Crying',              // 3
        'Cat Meowing',              // 4
        'Children Playing',         // 5
        'Construction Sound',       // 6
        'Cow Mooing',               // 7
        'Dog Bark',                 // 8
        'Door Knock',               // 9
        'Doorbell',                 // 10
        'Engine Idling',            // 11
        'Firecrackers',             // 12
        'Glass Breaking',           // 13
        'Gun Shot',                 // 14
        'Microwave Oven Beep',      // 15
        'Mixer Grinder',             // 16
        'Pressure Cooker Whistle',  // 17
        'Siren',                    // 18
        'Street Music',              // 19
        'Temple Bell',               // 20
        'Train Horn',                // 21
        'Utensils',                  // 22
        'Vehicle Horn',              // 23
        'Water Running',             // 24
        'No Sound',                  // 25
      ];

      final predictedClass =
          modelClasses[bestIndex];

      // ------------------------------------------------------
      // 9. Handle "No Sound"
      // ------------------------------------------------------

      if (predictedClass == 'No Sound') {
        print(
          'AIISH V6 offline: model predicted No Sound',
        );

        // Any No Sound prediction breaks the current
        // confirmation sequence.
        _predictionBuffer.clear();

        onSoundDetected(null, 0.0);

        return;
      }

      // ------------------------------------------------------
      // 10. Map model classes to application sound IDs
      // ------------------------------------------------------

      const modelOutputToSoundId =
          <String, String>{
        'Air Conditioner':
            'air_conditioner',

        'Alarm':
            'alarm_fire_smoke',

        'Approaching Vehicles':
            'approaching_vehicles',

        'Baby Crying':
            'baby_crying',

        'Cat Meowing':
            'cat_meow',

        'Children Playing':
            'children_playing',

        'Construction Sound':
            'construction_sounds',

        'Cow Mooing':
            'cow_mooing',

        'Dog Bark':
            'dog_bark',

        'Door Knock':
            'door_knock',

        'Doorbell':
            'doorbell',

        'Engine Idling':
            'engine_idling',

        'Firecrackers':
            'fire_crackers',

        'Glass Breaking':
            'glass_breaking',

        'Gun Shot':
            'blasts',

        'Microwave Oven Beep':
            'microwave_beep',

        'Mixer Grinder':
            'mixer_grinder',

        'Pressure Cooker Whistle':
            'pressure_cooker',

        'Siren':
            'siren_emergency',

        'Street Music':
            'street_music',

        'Temple Bell':
            'temple_bell',

        'Train Horn':
            'train_horn',

        'Utensils':
            'utensils',

        'Vehicle Horn':
            'vehicle_horn',

        'Water Running':
            'water_running',
      };

      final soundId =
          modelOutputToSoundId[predictedClass];

      SoundLabel? matchedSound;

      if (soundId != null) {
        for (final sound in soundTaxonomy) {
          if (sound.id == soundId) {
            matchedSound = sound;
            break;
          }
        }
      }

      // ------------------------------------------------------
      // 11. Log raw prediction
      // ------------------------------------------------------

      print(
        'AIISH V6 offline prediction: '
        '$predictedClass '
        '(${(confidence * 100).toStringAsFixed(1)}%)',
      );

      if (matchedSound == null) {
        return;
      }

      // ------------------------------------------------------
      // 12. Add prediction to confirmation buffer
      // ------------------------------------------------------

      _predictionBuffer.add(matchedSound);

      print(
        'Prediction buffer: '
        '${_predictionBuffer.map((s) => s.name).join(', ')}',
      );

      // ------------------------------------------------------
      // 13. Wait until we have 3 predictions
      // ------------------------------------------------------

      if (_predictionBuffer.length <
          _requiredPredictions) {
        print(
          'Waiting for more predictions '
          '(${_predictionBuffer.length}/$_requiredPredictions)',
        );

        return;
      }

      // ------------------------------------------------------
      // 14. Find majority sound
      // ------------------------------------------------------

      final counts =
          <String, int>{};

      final soundById =
          <String, SoundLabel>{};

      for (final sound in _predictionBuffer) {
        counts[sound.id] =
            (counts[sound.id] ?? 0) + 1;

        soundById[sound.id] = sound;
      }

      String? majoritySoundId;
      var highestCount = 0;

      for (final entry in counts.entries) {
        if (entry.value > highestCount) {
          highestCount = entry.value;
          majoritySoundId = entry.key;
        }
      }

      final confirmedSound =
          majoritySoundId != null
              ? soundById[majoritySoundId]
              : null;

      // ------------------------------------------------------
      // 15. Clear buffer after evaluation
      // ------------------------------------------------------

      _predictionBuffer.clear();

      // ------------------------------------------------------
      // 16. Only display if 2/3 agree
      // ------------------------------------------------------

      if (confirmedSound == null ||
          highestCount < _requiredMajority) {
        print(
          'No majority detected. '
          'No sound displayed.',
        );

        return;
      }

      print(
        'CONFIRMED SOUND: '
        '${confirmedSound.name} '
        '($highestCount/$_requiredPredictions)',
      );

      // ------------------------------------------------------
      // 17. Send ONLY confirmed sound to the application
      // ------------------------------------------------------

      onSoundDetected(
        confirmedSound,
        confidence,
      );
    } catch (e) {
      print(
        'AIISH V6 offline inference error: $e',
      );
    } finally {
      // ------------------------------------------------------
      // Delete temporary recording
      // ------------------------------------------------------

      if (recordedPath != null) {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }

      _processing = false;
    }
  }

  // ----------------------------------------------------------
  // RMS calculation
  // ----------------------------------------------------------

  double _calculateRms(
    List<double> waveform,
  ) {
    if (waveform.isEmpty) {
      return 0.0;
    }

    double sumSquares = 0.0;

    for (final sample in waveform) {
      sumSquares += sample * sample;
    }

    return sqrt(
      sumSquares / waveform.length,
    );
  }

  // ----------------------------------------------------------
  // WAV → Float32 waveform
  // ----------------------------------------------------------

  Future<List<double>> _readWavAsFloat32(
    String path,
  ) async {
    final bytes = await File(path).readAsBytes();

    if (bytes.length < 44) {
      throw Exception('Invalid WAV file');
    }

    int? dataOffset;
    int? dataLength;

    var offset = 12;

    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(
        bytes.sublist(
          offset,
          offset + 4,
        ),
      );

      final chunkLength =
          bytes.buffer.asByteData().getUint32(
                offset + 4,
                Endian.little,
              );

      if (chunkId == 'data') {
        dataOffset = offset + 8;
        dataLength = chunkLength;
        break;
      }

      offset +=
          8 +
          chunkLength +
          (chunkLength.isOdd ? 1 : 0);
    }

    if (dataOffset == null ||
        dataLength == null) {
      throw Exception(
        'WAV data chunk not found',
      );
    }

    final availableLength =
        dataLength >
                bytes.length - dataOffset
            ? bytes.length - dataOffset
            : dataLength;

    final sampleCount =
        availableLength ~/ 2;

    final waveform =
        List<double>.filled(
      48000,
      0.0,
    );

    final byteData =
        bytes.buffer.asByteData(
      bytes.offsetInBytes,
      bytes.length,
    );

    final usableSamples =
        sampleCount > 48000
            ? 48000
            : sampleCount;

    for (var i = 0;
        i < usableSamples;
        i++) {
      final sample =
          byteData.getInt16(
        dataOffset + (i * 2),
        Endian.little,
      );

      waveform[i] =
          sample / 32768.0;
    }

    return waveform;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;

    _timer?.cancel();
    _timer = null;

    // Clear unfinished predictions.
    _predictionBuffer.clear();

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }
}