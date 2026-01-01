import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class CustomerTransactionReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  Future<List<AppTransaction>> fetchByUserId(
    String userId, {
    int limit = 50,
  }) async {
    if (userId.isEmpty) return [];

    final snap =
        await _firestore
            .collection(collectionName)
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .limit(limit)
            .get();

    return snap.docs
        .map((d) => AppTransaction.fromMap(d.id, d.data()))
        .toList();
  }
}
