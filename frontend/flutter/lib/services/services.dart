import 'dart:async';
import 'dart:typed_data';
//import 'dart:math';
import '../models/models.dart';
import '../data/sound_taxonomy.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'sound_classifier_stub.dart';

/// -------------------------------------------------------------
/// AUTH SERVICE INTERFACE & FIREBASE IMPLEMENTATION
/// -------------------------------------------------------------
abstract class AuthService {
  Future<UserProfile?> signIn(String email, String password);
  Future<UserProfile?> signUp(UserProfile profile, String password);
  Future<void> signOut();
  UserProfile? get currentUser;
  Stream<UserProfile?> get authStateChanges;
}

class FirebaseAuthService implements AuthService {
  UserProfile? _currentUser;
  final _controller = StreamController<UserProfile?>.broadcast();

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Stream<UserProfile?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        _currentUser = null;
        _controller.add(null);
        return null;
      }

      final mapped = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'User',
        age: 0,
        phone: '',
        email: user.email ?? '',
        micAccess: true,
        termsAccepted: true,
        privacyPolicyAccepted: true,
        outputPreferences: const ['text', 'icon', 'color'],
      );

      _currentUser = mapped;
      _controller.add(mapped);
      return mapped;
    });
  }

  String _friendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<UserProfile?> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return null;
      }

      final profile = UserProfile(
        id: user.uid,
        name: user.displayName ?? 'User',
        age: 0,
        phone: '',
        email: user.email ?? email.trim(),
        micAccess: true,
        termsAccepted: true,
        privacyPolicyAccepted: true,
        outputPreferences: const ['text', 'icon', 'color'],
      );

      _currentUser = profile;
      _controller.add(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  @override
  Future<UserProfile?> signUp(UserProfile profile, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: profile.email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return null;
      }

      final authenticatedProfile = UserProfile(
        id: user.uid,
        name: profile.name,
        age: profile.age,
        phone: profile.phone,
        email: user.email ?? profile.email,
        micAccess: profile.micAccess,
        termsAccepted: profile.termsAccepted,
        privacyPolicyAccepted: profile.privacyPolicyAccepted,
        outputPreferences: profile.outputPreferences,
        emergencyContactName: profile.emergencyContactName,
        emergencyContactPhone: profile.emergencyContactPhone,
        muteLowAlerts: profile.muteLowAlerts,
        muteMediumAlerts: profile.muteMediumAlerts,
        gpsAutoDetect: profile.gpsAutoDetect,
        savedLocations: profile.savedLocations,
        language: profile.language,
        textSize: profile.textSize,
        highContrast: profile.highContrast,
      );

      _currentUser = authenticatedProfile;
      _controller.add(authenticatedProfile);
      return authenticatedProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
    await FirebaseAuth.instance.signOut();
  }
}

/// -------------------------------------------------------------
/// HISTORY & CLOUD SYNC SERVICE
/// -------------------------------------------------------------
abstract class HistorySyncService {
  Future<List<SoundEvent>> getLocalHistory();
  Future<void> logEvent(SoundEvent event);
  Future<void> syncWithCloud();
}

class HiveHistorySyncService implements HistorySyncService {
  final List<SoundEvent> _inMemoryEvents = [];

  @override
  Future<List<SoundEvent>> getLocalHistory() async {
    // In production, load from Hive Box:
    // var box = await Hive.openBox<SoundEvent>('sound_events');
    // return box.values.toList().reversed.toList();
    return List.from(_inMemoryEvents.reversed);
  }

  @override
  Future<void> logEvent(SoundEvent event) async {
    _inMemoryEvents.add(event);

    // In production, save to local Hive DB:
    // var box = Hive.box<SoundEvent>('sound_events');
    // await box.add(event);

    // Sync with backend API in background if online
    await syncWithCloud();
  }

  @override
  Future<void> syncWithCloud() async {
    // TODO: Implement background synchronization endpoint POST /sound-events
    // Web service calls to upload offline-cached logs
  }
}

/// -------------------------------------------------------------
/// EMERGENCY SERVICE
/// -------------------------------------------------------------
abstract class EmergencyService {
  Future<bool> triggerEmergencyAlert(
      String userId, String message, String actionType);
}

class MockEmergencyService implements EmergencyService {
  @override
  Future<bool> triggerEmergencyAlert(
      String userId, String message, String actionType) async {
    // TODO: Connect this to Twilio API or Firebase Cloud Function to dispatch SMS or automated phone call.
    // Example: http.post(Uri.parse('$backendUrl/emergency/contact'), body: {...});
    await Future.delayed(const Duration(milliseconds: 1000));
    print(
        "EMERGENCY STUB TRIGGERED: User $userId dispatched '$actionType' action: '$message'");
    return true;
  }
}
