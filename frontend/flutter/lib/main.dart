import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service, channels, and intent listeners before app launches
  await NotificationService.instance.initialize(navKey: SensoryReachApp.navigatorKey);
  
  runApp(const SensoryReachApp());
}

