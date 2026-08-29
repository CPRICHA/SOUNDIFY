import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sound_accessibility_app/services/feedback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyC4cMj6pZZqb4ERyrZj6e6Nomyl0JcbfG8',
        appId: '1:360494384501:android:1a7c8847e0a8ac6b4d7f6d',
        messagingSenderId: '360494384501',
        projectId: 'aiish-ea208',
        storageBucket: 'aiish-ea208.firebasestorage.app',
        authDomain: 'aiish-ea208.firebaseapp.com',
      ),
    );
  });

  test('Feedback payload includes the sound context and id', () {
    final payload = FeedbackService.buildFeedbackPayload(
      rating: 5,
      feedbackText: 'Excellent detection',
      userId: 'user_123',
      soundType: 'Doorbell',
      detectedConfidence: 0.91,
      modelVersion: 'AIISH_v2',
      platform: 'android',
    );

    expect(payload['rating'], 5);
    expect(payload['feedbackText'], 'Excellent detection');
    expect(payload['userId'], 'user_123');
    expect(payload['soundType'], 'Doorbell');
    expect(payload['detectedConfidence'], 0.91);
    expect(payload['modelVersion'], 'AIISH_v2');
    expect(payload['platform'], 'android');
    expect(payload['id'], isNotEmpty);
  });

  test('Offline queue stores feedback for later sync', () async {
    final service = FeedbackService(
      connectivityChecker: () async => false,
      submitToFirestore: (_) async {},
      syncQueuedFeedback: (_) async {},
    );

    final result = await service.submitFeedback(
      rating: 4,
      feedbackText: 'Good but a bit delayed',
      category: 'General',
      userId: 'user_456',
      soundType: 'Siren',
      detectedConfidence: 0.82,
      modelVersion: 'AIISH_v2',
    );

    expect(result.status, FeedbackSubmissionStatus.queued);
    expect(result.message,
        "Feedback saved and will sync when you're online.");

    final queue = await service.pendingFeedbackQueue;
    expect(queue, isNotEmpty);
    expect(queue.first['feedbackText'], 'Good but a bit delayed');
  });

  test('Duplicate submissions are rejected before queueing', () async {
    final service = FeedbackService(
      connectivityChecker: () async => false,
      submitToFirestore: (_) async {},
      syncQueuedFeedback: (_) async {},
    );

    final first = await service.submitFeedback(
      rating: 5,
      feedbackText: 'Very helpful',
      category: 'General',
      userId: 'user_123',
      modelVersion: 'AIISH_v2',
    );

    final second = await service.submitFeedback(
      rating: 5,
      feedbackText: 'Very helpful',
      category: 'General',
      userId: 'user_123',
      modelVersion: 'AIISH_v2',
    );

    expect(first.status, FeedbackSubmissionStatus.queued);
    expect(second.status, FeedbackSubmissionStatus.duplicate);
    expect((await service.pendingFeedbackQueue).length, 1);
  });

  test('Sync removes queued items once online', () async {
    final submittedPayloads = <Map<String, dynamic>>[];
    final service = FeedbackService(
      connectivityChecker: () async => true,
      submitToFirestore: (_) async {},
      syncQueuedFeedback: (payload) async {
        submittedPayloads.add(payload);
      },
    );

    await service.submitFeedback(
      rating: 3,
      feedbackText: 'Okay overall',
      category: 'General',
      userId: 'user_456',
      soundType: 'Doorbell',
      detectedConfidence: 0.7,
      modelVersion: 'AIISH_v2',
    );

    final synced = await service.syncPendingFeedback();

    expect(synced, 1);
    expect(submittedPayloads, isNotEmpty);
    expect((await service.pendingFeedbackQueue).length, 0);
  });
}
