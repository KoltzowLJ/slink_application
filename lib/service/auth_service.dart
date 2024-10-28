// lib/service/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// Service class for handling authentication and user-related operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication getters
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication methods
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign in';
    }
  }

  /// Register new user with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred while sending password reset email';
    }
  }

  // User document management
  /// Create new user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'isAdmin': false,
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw 'Failed to create user profile';
    }
  }

  /// Check if user document exists
  Future<bool> checkUserDocumentExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user document: $e');
      return false;
    }
  }

  /// Ensure user document exists, create if it doesn't
  Future<void> ensureUserDocument(User user) async {
    try {
      final exists = await checkUserDocumentExists(user.uid);
      if (!exists) {
        await _createUserDocument(user);
      }
    } catch (e) {
      print('Error ensuring user document: $e');
    }
  }

  // User data operations
  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        final user = _auth.currentUser;
        if (user != null) {
          await _createUserDocument(user);
          return getUserData(uid);
        }
        return null;
      }
      return UserModel.fromMap(doc.data() ?? {});
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Get real-time user data stream
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  /// Check if current user is admin
  Future<bool> isUserAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
