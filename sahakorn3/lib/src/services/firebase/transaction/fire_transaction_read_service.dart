import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class FireTransactionReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  Future<AppTransaction?> fetchById(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (!doc.exists) return null;
    return AppTransaction.fromMap(doc.id, doc.data());
  }

  Future<List<AppTransaction>> fetchByUser(String userId, {int limit = 50}) async {
    final snap = await _firestore
        .collection(collectionName)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => AppTransaction.fromMap(d.id, d.data())).toList();
  }

  Future<int?> countByUser(String userId) async {
    try {
      final agg = await _firestore
          .collection(collectionName)
          .where('user_id', isEqualTo: userId)
          .count()
          .get();
      return agg.count;
    } catch (_) {
      final snap = await _firestore
          .collection(collectionName)
          .where('user_id', isEqualTo: userId)
          .get();
      return snap.docs.length;
    }
  }

  Stream<List<AppTransaction>> watchByUser(String userId) {
    return _firestore
        .collection(collectionName)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppTransaction.fromMap(d.id, d.data())).toList());
  }

  Future<List<AppTransaction>> fetchAll({int limit = 100}) async {
    final snap = await _firestore.collection(collectionName).orderBy('created_at', descending: true).limit(limit).get();
    return snap.docs.map((d) => AppTransaction.fromMap(d.id, d.data())).toList();
  }
}