import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/credit_transaction.dart';

class FireCreditTransactionReadService {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'credit_transactions';

  /// Get transaction history for a specific credit account (User's debt)
  Future<List<CreditTransaction>> getTransactionsByCreditId(
    String creditId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collectionName)
              .where('creditId', isEqualTo: creditId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => CreditTransaction.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions by creditId: $e');
      return [];
    }
  }

  /// Get all credit transactions for a specific shop
  Future<List<CreditTransaction>> getTransactionsByShopId(String shopId) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collectionName)
              .where('shopId', isEqualTo: shopId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => CreditTransaction.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions by shopId: $e');
      return [];
    }
  }
}
