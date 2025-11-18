import 'package:cloud_firestore/cloud_firestore.dart';

class FireUserWriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or overwrite user document at users/{uid}
  /// Returns null on success, or error message on failure.
  Future<String?> createOrReplaceUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final payload = {
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(uid).set(payload);
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  /// Merge update to users/{uid}
  Future<String?> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          ...data,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }
}