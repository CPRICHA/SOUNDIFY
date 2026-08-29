import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FeedbackSubmissionStatus { submitted, queued, duplicate }

class FeedbackSubmissionResult {
  final FeedbackSubmissionStatus status;
  final String message;

  const FeedbackSubmissionResult({
    required this.status,
    required this.message,
  });
}

class FeedbackService {
  FeedbackService({
    FirebaseFirestore? firestore,
    Future<bool> Function()? connectivityChecker,
    Future<void> Function(Map<String, dynamic> payload)? submitToFirestore,
    Future<void> Function(Map<String, dynamic> payload)? syncQueuedFeedback,
  })  : _firestore = firestore ?? _safeFirestoreInstance(),
        _connectivityChecker = connectivityChecker ?? _defaultConnectivityChecker,
        _submitToFirestoreOverride = submitToFirestore ??
            ((payload) => _defaultSubmitToFirestore(
                  firestore ?? _safeFirestoreInstance(),
                  payload,
                )),
        _syncQueuedFeedbackOverride = syncQueuedFeedback ??
            ((payload) => _defaultSyncQueuedFeedback(
                  firestore ?? _safeFirestoreInstance(),
                  payload,
                ));

  static const String _pendingQueueKey = 'aiish_pending_feedback_queue';
  static final FeedbackService instance = FeedbackService();

  static FirebaseFirestore? _safeFirestoreInstance() {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  final FirebaseFirestore? _firestore;
  final Future<bool> Function() _connectivityChecker;
  final Future<void> Function(Map<String, dynamic> payload)
      _submitToFirestoreOverride;
  final Future<void> Function(Map<String, dynamic> payload)
      _syncQueuedFeedbackOverride;

  static Future<bool> _defaultConnectivityChecker() async {
    try {
      final addresses = await InternetAddress.lookup('firebase.google.com');
      return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  static Future<void> _defaultSubmitToFirestore(
    FirebaseFirestore? firestore,
    Map<String, dynamic> payload,
  ) async {
    if (firestore == null) {
      return;
    }

    final docId = payload['id'] as String? ?? _buildDocumentId(payload);
    await firestore.collection('feedback').doc(docId).set(
      payload,
      SetOptions(merge: true),
    );
  }

  static Future<void> _defaultSyncQueuedFeedback(
    FirebaseFirestore? firestore,
    Map<String, dynamic> payload,
  ) async {
    if (firestore == null) {
      return;
    }

    final docId = payload['id'] as String? ?? _buildDocumentId(payload);
    await firestore.collection('feedback').doc(docId).set(
      payload,
      SetOptions(merge: true),
    );
  }

  static String _buildDocumentId(Map<String, dynamic> payload) {
    final raw = [
      payload['rating'] ?? 0,
      (payload['feedbackText'] ?? '').trim(),
      payload['userId'] ?? 'guest',
      payload['category'] ?? 'General',
      payload['soundType'] ?? '',
      payload['detectedConfidence']?.toString() ?? '',
      payload['modelVersion'] ?? '',
    ].join('|');

    final digest = sha256.convert(utf8.encode(raw));
    return digest.toString();
  }

  static String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isMacOS) {
      return 'macos';
    }
    if (Platform.isWindows) {
      return 'windows';
    }
    if (Platform.isLinux) {
      return 'linux';
    }

    return Platform.operatingSystem;
  }

  static String? _resolveCurrentUserId() {
    try {
      if (!Firebase.apps.isNotEmpty) {
        return null;
      }
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> buildFeedbackPayload({
    required int rating,
    required String feedbackText,
    String? category,
    String? userId,
    String? soundType,
    double? detectedConfidence,
    String? appVersion,
    String? modelVersion,
    String? platform,
    DateTime? timestamp,
  }) {
    final normalizedText = feedbackText.trim();
    final effectiveTimestamp = (timestamp ?? DateTime.now()).toUtc();
    final payload = <String, dynamic>{
      'timestamp': effectiveTimestamp.toIso8601String(),
      'rating': rating,
      'feedbackText': normalizedText,
      'category': category ?? 'General',
      'userId': userId ?? _resolveCurrentUserId(),
      'soundType': soundType,
      'detectedConfidence': detectedConfidence,
      'appVersion': appVersion,
      'modelVersion': modelVersion ?? 'AIISH_v2',
      'platform': platform ?? _platformName(),
    };

    payload['id'] = _buildDocumentId(payload);
    return payload;
  }

  Future<List<Map<String, dynamic>>> get pendingFeedbackQueue async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_pendingQueueKey) ?? const <String>[];

    return items
        .map((entry) => jsonDecode(entry))
        .whereType<Map<String, dynamic>>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Future<void> _savePendingQueue(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = items
        .map((item) => jsonEncode(item))
        .toList(growable: false);
    await prefs.setStringList(_pendingQueueKey, serialized);
  }

  Future<bool> _hasQueuedDuplicate(String id) async {
    final queue = await pendingFeedbackQueue;
    return queue.any((item) => (item['id'] as String?) == id);
  }

  Future<FeedbackSubmissionResult> submitFeedback({
    required int rating,
    required String feedbackText,
    String? category,
    String? soundType,
    double? detectedConfidence,
    String? userId,
    String? appVersion,
    String? modelVersion,
    String? platform,
    DateTime? timestamp,
  }) async {
    final currentUserId = _resolveCurrentUserId();

    final payload = buildFeedbackPayload(
      rating: rating,
      feedbackText: feedbackText,
      category: category,
      userId: userId ?? currentUserId,
      soundType: soundType,
      detectedConfidence: detectedConfidence,
      appVersion: appVersion,
      modelVersion: modelVersion,
      platform: platform,
      timestamp: timestamp,
    );

    final docId = payload['id'] as String;
    final previousQueueDuplicate = await _hasQueuedDuplicate(docId);
    if (previousQueueDuplicate) {
      return const FeedbackSubmissionResult(
        status: FeedbackSubmissionStatus.duplicate,
        message: 'Feedback submitted',
      );
    }

    if (_firestore != null) {
      try {
        final firestoreSnapshot =
            await _firestore!.collection('feedback').doc(docId).get();
        if (firestoreSnapshot.exists) {
          return const FeedbackSubmissionResult(
            status: FeedbackSubmissionStatus.duplicate,
            message: 'Feedback submitted',
          );
        }
      } catch (_) {
        // Continue to online/offline queue flow if Firestore is unreachable.
      }
    }

    final isOnline = await _connectivityChecker();
    if (isOnline) {
      try {
        await _submitToFirestoreOverride(payload);
        return const FeedbackSubmissionResult(
          status: FeedbackSubmissionStatus.submitted,
          message: 'Feedback submitted',
        );
      } catch (_) {
        // Fall back to the offline queue if Firestore submission fails.
      }
    }

    final queue = await pendingFeedbackQueue;
    final updatedQueue = [...queue, payload];
    await _savePendingQueue(updatedQueue);
    return const FeedbackSubmissionResult(
      status: FeedbackSubmissionStatus.queued,
      message: "Feedback saved and will sync when you're online.",
    );
  }

  Future<int> syncPendingFeedback() async {
    final queue = await pendingFeedbackQueue;
    if (queue.isEmpty || _firestore == null) {
      return 0;
    }

    final isOnline = await _connectivityChecker();
    if (!isOnline) {
      return 0;
    }

    final remainingItems = <Map<String, dynamic>>[];
    for (final item in queue) {
      try {
        await _syncQueuedFeedbackOverride(item);
      } catch (_) {
        remainingItems.add(item);
      }
    }

    await _savePendingQueue(remainingItems);
    return queue.length - remainingItems.length;
  }
}
