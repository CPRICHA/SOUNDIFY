import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sound_accessibility_app/services/feedback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

    test('does not write when there is no authenticated user', () async {
      final service = FeedbackService(firestore: FirebaseFirestore.instance);

      expect(
        () => service.submitFeedback(rating: 5, feedback: 'Very useful app'),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('not authenticated'),
          ),
        ),
      );
    }, skip: 'Requires Firebase platform plugin or emulator.');

    test('rejects ratings outside the supported range', () async {
      final service = FeedbackService(firestore: FirebaseFirestore.instance);

      expect(
        () => service.submitFeedback(rating: 6, feedback: 'Invalid rating'),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('1 to 5'),
          ),
        ),
      );
    }, skip: 'Requires Firebase platform plugin or emulator.');

}
