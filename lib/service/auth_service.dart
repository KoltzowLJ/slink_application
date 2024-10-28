// lib/service/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
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

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'name': email.split('@')[0],
          'isAdmin': false, // Always false for new registrations
          'loyaltyPoints': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Add this method to check if user document exists
  Future<bool> checkUserDocumentExists(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user document: $e');
      return false;
    }
  }

  // Add this method to ensure user document exists
  Future<void> ensureUserDocument(User user) async {
    try {
      final exists = await checkUserDocumentExists(user.uid);
      if (!exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.email?.split('@')[0] ?? 'User',
          'isAdmin': false,
          'loyaltyPoints': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error ensuring user document: $e');
    }
  }

  // Create user document in Firestore
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

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        final user = _auth.currentUser;
        if (user != null) {
          // Create default user document
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': user.email ?? '',
            'name': user.email?.split('@')[0] ?? 'User',
            'isAdmin': false,
            'loyaltyPoints': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
          // Fetch the new document
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

  // Stream user data
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred while sending password reset email';
    }
  }

  // Add method to check if user is admin
  Future<bool> isUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
}
