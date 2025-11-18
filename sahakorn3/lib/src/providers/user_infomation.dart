import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  Map<String, dynamic>? _profile;
  bool _loading = false;

  UserInformationProvider() {
    // Listen auth changes and load/clear profile accordingly
    _auth.authStateChanges().listen((user) {
      _firebaseUser = user;
      if (user != null) {
        loadProfile(user.uid).then((_) => _debugPrintUser());
      } else {
        clear();
        debugPrint('UserInformationProvider: user signed out');
      }
    });
  }

  // getters
  User? get firebaseUser => _firebaseUser;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _loading;
  String? get uid => _firebaseUser?.uid;
  String? get email => _firebaseUser?.email;
  String? get displayName => _profile?['name'] ?? _firebaseUser?.displayName;
  String? get phone => _profile?['phone'];
  String? get role => _profile?['user_level'];

  // Load profile from Firestore (users collection)
  Future<String?> loadProfile(String uid) async {
    try {
      _setLoading(true);
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _profile = doc.data();
      } else {
        _profile = null;
      }
      notifyListeners();
      _debugPrintUser();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Failed to load profile';
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update profile in Firestore and local state
  Future<String?> updateProfile(Map<String, dynamic> data) async {
    final uidLocal = uid;
    if (uidLocal == null) return 'No authenticated user';
    try {
      _setLoading(true);
      await _firestore.collection('users').doc(uidLocal).set(data, SetOptions(merge: true));
      // refresh local copy
      _profile = {...?_profile, ...data};
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Failed to update profile';
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Clear local state (called on sign-out)
  void clear() {
    _firebaseUser = null;
    _profile = null;
    notifyListeners();
    debugPrint('UserInformationProvider: cleared user/profile');
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // Debug helper: prints current auth and profile info
  void _debugPrintUser() {
    debugPrint('UserInformationProvider: uid=${_firebaseUser?.uid ?? "null"}, email=${_firebaseUser?.email ?? "null"}');
    debugPrint('UserInformationProvider: profile=${_profile ?? "null"}');
  }
}