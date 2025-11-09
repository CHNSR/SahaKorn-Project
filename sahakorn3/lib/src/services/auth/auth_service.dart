import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String surname,
    String phone,
  ) async {
    // 1. Create user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? newUser = userCredential.user;

    if (newUser != null) {
      // 2. Save additional user data to Firestore
      await _firestore.collection('users').doc(newUser.uid).set({
        'userID': newUser.uid,
        'email': email,
        'name': name,
        'surname': surname,
        'phone': phone,
        'user_level': 'customer', // Set a default user level
      });

      // 3. Save session info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', newUser.uid);
      await prefs.setString('user_role', 'customer');
    }
  }
}