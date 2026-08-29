import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/feedback_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (_) {
    if (kDebugMode) {
      print('Firebase config not available on this platform yet; running in offline-safe mode.');
    }
  }

  // Initialize notification service, channels, and intent listeners before app launches
  await NotificationService.instance.initialize(navKey: SensoryReachApp.navigatorKey);

  unawaited(FeedbackService.instance.syncPendingFeedback());
  Timer.periodic(const Duration(minutes: 2), (_) async {
    await FeedbackService.instance.syncPendingFeedback();
  });

  runApp(const SensoryReachApp());
}

