import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns null on success, or an error message string on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return 'Login failed.';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['user_level'] ?? 'customer';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.uid);
      await prefs.setString('user_role', role);
      await prefs.setBool('seen_intermediary', true);

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No user found for that email.';
      if (e.code == 'wrong-password') return 'Wrong password provided for that user.';
      return e.message ?? 'An unknown error occurred.';
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
}