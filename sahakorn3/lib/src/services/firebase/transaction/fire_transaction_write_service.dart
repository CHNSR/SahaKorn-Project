import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class FireTransactionWriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  /// Create a new transaction document.
  /// Returns `null` on success, or an error message `String` on failure.
  Future<String?> createTransaction({required AppTransaction tx}) async {
    try {
      final payload = {
        'transaction_id': tx.transactionId,
        'shop_id': tx.shopId,
        'user_id': tx.userId,
        'product_id': tx.productId,
        'payment_method': tx.paymentMethod,
        'total_amount': tx.totalAmount,
        'detail': tx.detail,
        'created_at': FieldValue.serverTimestamp(),
      };
      await _firestore.collection(collectionName).add(payload);
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  /// Update (merge) fields on an existing transaction document.
  Future<String?> updateTransaction({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionName).doc(docId).set({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  /// Delete a transaction document.
  Future<String?> deleteTransaction(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }
}
