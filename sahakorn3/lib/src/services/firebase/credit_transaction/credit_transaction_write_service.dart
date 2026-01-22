import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/credit_transaction.dart';

class FireCreditTransactionWriteService {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'credit_transactions';
  final String _creditCollectionName = 'credit';

  // 1. Transaction specifically for giving credit (Loan/Purchase)
  Future<String?> createCreditPurchase({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
  }) async {
    final transactionRef = _firestore.collection(_collectionName).doc();
    final creditRef = _firestore
        .collection(_creditCollectionName)
        .doc(creditId);

    try {
      await _firestore.runTransaction((transaction) async {
        final creditDoc = await transaction.get(creditRef);
        if (!creditDoc.exists) throw Exception('Credit account not found');

        final currentCreditUsed =
            (creditDoc.data()?['creditUsed'] ?? 0.0).toDouble();
        final creditLimit =
            (creditDoc.data()?['creditLimit'] ?? 0.0).toDouble();

        // Logic change: If new usage exceeds limit, we auto-increase the limit
        // because we now allow creating customers with 0 limit.
        final newCreditUsed = currentCreditUsed + amount;
        double newCreditLimit = creditLimit;

        if (newCreditUsed > creditLimit) {
          newCreditLimit = newCreditUsed;
        }

        final newTransaction = CreditTransaction(
          id: transactionRef.id,
          creditId: creditId,
          userId: userId,
          shopId: shopId,
          amount: amount,
          type: CreditTransactionType.purchase,
          remainingDebt: newCreditUsed,
          note: note,
          createdAt: DateTime.now(),
        );

        transaction.set(transactionRef, newTransaction.toMap());
        transaction.update(creditRef, {
          'creditUsed': newCreditUsed,
          'creditLimit': newCreditLimit, // Auto-update limit
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 1.5 Transaction specifically for Granting Limit (Increase Limit, No Debt Change)
  Future<String?> grantCreditLimit({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
  }) async {
    final transactionRef = _firestore.collection(_collectionName).doc();
    final creditRef = _firestore
        .collection(_creditCollectionName)
        .doc(creditId);

    try {
      await _firestore.runTransaction((transaction) async {
        final creditDoc = await transaction.get(creditRef);
        if (!creditDoc.exists) throw Exception('Credit account not found');

        final currentCreditLimit =
            (creditDoc.data()?['creditLimit'] ?? 0.0).toDouble();

        // Increase Limit
        final newCreditLimit = currentCreditLimit + amount;

        final currentCreditUsed =
            (creditDoc.data()?['creditUsed'] ?? 0.0).toDouble();

        final newTransaction = CreditTransaction(
          id: transactionRef.id,
          creditId: creditId,
          userId: userId,
          shopId: shopId,
          amount: amount,
          type: CreditTransactionType.grant_limit,
          remainingDebt: currentCreditUsed, // Debt unchanged
          note: note,
          createdAt: DateTime.now(),
        );

        transaction.set(transactionRef, newTransaction.toMap());
        transaction.update(creditRef, {
          'creditLimit': newCreditLimit,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Transaction specifically for Repayment
  Future<String?> createRepayment({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
    String paymentMethod = 'Cash',
  }) async {
    final transactionRef = _firestore.collection(_collectionName).doc();
    final creditRef = _firestore
        .collection(_creditCollectionName)
        .doc(creditId);
    final appTransactionRef = _firestore.collection('transactions').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final creditDoc = await transaction.get(creditRef);
        if (!creditDoc.exists) throw Exception('Credit account not found');

        final currentCreditUsed =
            (creditDoc.data()?['creditUsed'] ?? 0.0).toDouble();

        // Calculate new debt
        double newCreditUsed = currentCreditUsed - amount;
        if (newCreditUsed < 0) newCreditUsed = 0; // Prevent negative debt

        // A. Credit Log
        final newCreditTx = CreditTransaction(
          id: transactionRef.id,
          creditId: creditId,
          userId: userId,
          shopId: shopId,
          amount: amount,
          type: CreditTransactionType.repayment,
          remainingDebt: newCreditUsed,
          note: note,
          createdAt: DateTime.now(),
        );

        transaction.set(transactionRef, newCreditTx.toMap());

        // B. Update Credit Balance
        transaction.update(creditRef, {
          'creditUsed': newCreditUsed,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // C. App Transaction Log (Global Transaction)
        final appTxMap = {
          'transaction_id': 'TX-${DateTime.now().millisecondsSinceEpoch}',
          'shop_id': shopId,
          'user_id': userId,
          'category': 'LOAN_REPAYMENT',
          'payment_method': paymentMethod,
          'total_amount': amount,
          'detail': note ?? 'Debt Repayment Transaction',
          'created_at': FieldValue.serverTimestamp(),
        };
        transaction.set(appTransactionRef, appTxMap);
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
