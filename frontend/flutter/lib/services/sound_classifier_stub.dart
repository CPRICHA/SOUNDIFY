import '../models/models.dart';

abstract class SoundClassificationService {
  Future<void> initializeModel();

  Future<void> startListening(
    Function(SoundLabel detectedSound, double confidence) onSoundDetected,
  );

  Future<void> stopListening();
}
