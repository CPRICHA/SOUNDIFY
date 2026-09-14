import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';

/// The single source of truth for Firebase Authentication and cloud profiles.
abstract class AuthService {
  Future<UserProfile?> signUp({
    required String name,
    required int age,
    required String phone,
    required String email,
    required String password,
  });

  Future<UserProfile?> signIn({
    required String email,
    required String password,
  });

  Future<void> updateProfile(UserProfile profile);
  Future<void> signOut();
  Future<UserProfile?> loadCurrentUserProfile();
  UserProfile? get currentUser;
  Stream<UserProfile?> get authStateChanges;
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  UserProfile? _currentUser;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Stream<UserProfile?> get authStateChanges =>
      _auth.authStateChanges().asyncMap(
        (user) async {
          if (user == null) {
            _currentUser = null;
            return null;
          }
          return await loadCurrentUserProfile();
        },
      );

  @override
  Future<UserProfile?> signUp({
    required String name,
    required int age,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      print('[SOUNDIFY AUTH] SIGNUP AUTH START');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase did not return a user after signup.');
      }

      final uid = user.uid;
      print('[SOUNDIFY AUTH] SIGNUP AUTH SUCCESS');
      print('[SOUNDIFY AUTH] UID: $uid');
      print('[SOUNDIFY AUTH] FIRESTORE WRITE START');
      try {
        await _firestore.collection('users').doc(uid).set({
          'name': name.trim(),
          'age': age,
          'phone': phone.trim(),
          'email': user.email ?? email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('[SOUNDIFY AUTH] FIRESTORE WRITE SUCCESS');

        final snapshot = await _firestore.collection('users').doc(uid).get();
        print('[SOUNDIFY AUTH] FIRESTORE VERIFY EXISTS: ${snapshot.exists}');
        if (!snapshot.exists) {
          throw Exception('Your account profile could not be verified.');
        }
        return _profileFromDocument(user, snapshot.data()!);
      } on FirebaseException catch (e) {
        print('[SOUNDIFY AUTH] FIREBASE ERROR CODE: ${e.code}');
        print('[SOUNDIFY AUTH] FIREBASE ERROR MESSAGE: ${e.message}');
        throw Exception(
          'Your account was created, but your profile could not be saved: '
          '${_friendlyFirestoreError(e)}',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('[SOUNDIFY AUTH] FIREBASE ERROR CODE: ${e.code}');
      print('[SOUNDIFY AUTH] FIREBASE ERROR MESSAGE: ${e.message}');
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('[SOUNDIFY AUTH] LOGIN AUTH START');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase did not return a user after login.');
      }
      print('[SOUNDIFY AUTH] LOGIN AUTH SUCCESS');
      print('[SOUNDIFY AUTH] UID: ${user.uid}');
      return await loadCurrentUserProfile();
    } on FirebaseAuthException catch (e) {
      print('[SOUNDIFY AUTH] LOGIN ERROR CODE: ${e.code}');
      print('[SOUNDIFY AUTH] LOGIN ERROR MESSAGE: ${e.message}');
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<UserProfile?> loadCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      print('[SOUNDIFY AUTH] PROFILE READ START');
      print('[SOUNDIFY AUTH] PROFILE PATH: users/${user.uid}');
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!snapshot.exists || snapshot.data() == null) {
        print('[SOUNDIFY AUTH] PROFILE READ SUCCESS');
        print('[SOUNDIFY AUTH] PROFILE EXISTS: false');
        print('[SOUNDIFY AUTH] PROFILE UID: ${user.uid}');
        throw Exception('Your account profile could not be found.');
      }
      print('[SOUNDIFY AUTH] PROFILE DATA: ${snapshot.data()}');
      final profile = _profileFromDocument(user, snapshot.data()!);
      _currentUser = profile;
      print('[SOUNDIFY AUTH] PROFILE READ SUCCESS');
      print('[SOUNDIFY AUTH] PROFILE EXISTS: true');
      return profile;
    } on FirebaseException catch (e) {
      print('[SOUNDIFY AUTH] PROFILE READ ERROR CODE: ${e.code}');
      print('[SOUNDIFY AUTH] PROFILE READ ERROR MESSAGE: ${e.message}');
      throw Exception(_friendlyFirestoreError(e));
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to save your profile.');
    }
    await _firestore.collection('users').doc(user.uid).set({
      'name': profile.name,
      'age': profile.age,
      'phone': profile.phone,
      'email': user.email ?? profile.email.trim(),
    }, SetOptions(merge: true));
    _currentUser = profile;
  }

  @override
  Future<void> signOut() async {
    print('[SOUNDIFY AUTH] LOGOUT START');
    _currentUser = null;
    await _auth.signOut();
    print('[SOUNDIFY AUTH] FIREBASE SIGNOUT SUCCESS');
    print('[SOUNDIFY AUTH] CLOUD PROFILE PRESERVED');
  }

  UserProfile _profileFromDocument(User user, Map<String, dynamic> data) {
    return UserProfile(
      id: user.uid,
      name: data['name'] as String? ?? user.displayName ?? 'User',
      age: (data['age'] as num?)?.toInt() ?? 0,
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? user.email ?? '',
      micAccess: true,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      outputPreferences: const ['text', 'icon', 'color'],
    );
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _friendlyFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Your account is not allowed to access its profile.';
      case 'unavailable':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Your profile could not be saved or loaded. Please try again.';
    }
  }
}
