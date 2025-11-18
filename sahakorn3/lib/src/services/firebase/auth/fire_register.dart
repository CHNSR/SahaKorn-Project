import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseRegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a new user and saves their details to Firestore.
  ///
  /// Returns `null` on success.
  /// Returns an error message `String` on failure.
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String phone,
  }) async {
    try {
      // 1) create auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? newUser = userCredential.user;
      if (newUser == null) {
        return 'Registration failed: no user returned from Firebase Auth.';
      }

      // 2) write profile doc to Firestore
      await _firestore.collection('users').doc(newUser.uid).set({
        'userID': newUser.uid,
        'email': email,
        'name': name,
        'surname': surname,
        'phone': phone,
        'user_level': 'customer',
        'created_at': Timestamp.now(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      // Friendly messages for common auth errors
      if (e.code == 'weak-password') return 'The password provided is too weak.';
      if (e.code == 'email-already-in-use') return 'An account already exists for that email.';
      return e.message ?? 'Authentication error: ${e.code}';
    } on FirebaseException catch (e) {
      // Firestore / native Firebase errors
      // Log for debugging
      debugPrint('FirebaseException during register: ${e.code} ${e.message}');
      return e.message ?? 'A Firebase error occurred: ${e.code}';
    } catch (e, st) {
      // Unexpected
      debugPrint('Unexpected register error: $e\n$st');
      return 'An unexpected error occurred. ${e.toString()}';
    }
  }
}