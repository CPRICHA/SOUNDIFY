import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final FeedbackService instance = FeedbackService();

  final FirebaseFirestore _firestore;

  Future<void> submitFeedback({
    required int rating,
    required String feedback,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    if (rating < 1 || rating > 5) {
      throw Exception('Please select a rating from 1 to 5.');
    }

    await _firestore.collection('feedbacks').add({
      'uid': user.uid,
      'rating': rating,
      'feedback': feedback.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retained for startup compatibility; feedback is no longer queued locally.
  Future<int> syncPendingFeedback() async {
    return 0;
  }
}
