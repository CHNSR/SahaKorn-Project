import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/credit_transaction.dart';

class FireCreditTransactionWriteService {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'credit_transactions';
  final String _creditCollectionName = 'credit';

  Future<String?> createTransaction({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    required CreditTransactionType type,
    String? note,
  }) async {
    final transactionRef = _firestore.collection(_collectionName).doc();
    final creditRef = _firestore
        .collection(_creditCollectionName)
        .doc(creditId);

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Get current credit data
        final creditDoc = await transaction.get(creditRef);
        if (!creditDoc.exists) {
          throw Exception('Credit account does not exist');
        }

        final currentCreditUsed =
            (creditDoc.data()?['creditUsed'] ??
                    creditDoc.data()?['amount'] ??
                    0.0)
                .toDouble();

        // 2. Calculate new credit used
        double newCreditUsed;
        if (type == CreditTransactionType.purchase) {
          final creditLimit =
              (creditDoc.data()?['creditLimit'] ?? 0.0).toDouble();
          if (currentCreditUsed + amount > creditLimit) {
            throw Exception(
              'Credit limit exceeded. Limit: $creditLimit, Used: $currentCreditUsed, Checkout: $amount',
            );
          }
          newCreditUsed = currentCreditUsed + amount;
        } else if (type == CreditTransactionType.repayment) {
          newCreditUsed = currentCreditUsed - amount;
          if (newCreditUsed < 0) newCreditUsed = 0;
        } else {
          // Adjustment logic
          newCreditUsed = currentCreditUsed + amount;
        }

        // 3. Create Transaction Record
        final newTransaction = CreditTransaction(
          id: transactionRef.id,
          creditId: creditId,
          userId: userId,
          shopId: shopId,
          amount: amount,
          type: type,
          remainingDebt: newCreditUsed,
          note: note,
          createdAt: DateTime.now(),
        );

        transaction.set(transactionRef, newTransaction.toMap());

        // 4. Update Credit Document
        transaction.update(creditRef, {
          'creditUsed': newCreditUsed,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return null; // Success
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }
}
