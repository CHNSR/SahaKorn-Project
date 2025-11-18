import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/user.dart';

class FireUserReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> fetchUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data());
  }

  Stream<AppUser?> watchUserById(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromMap(snap.id, snap.data());
    });
  }

  Future<List<AppUser>> fetchAllUsers({int limit = 50}) async {
    final snap = await _firestore.collection('users').limit(limit).get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }
}