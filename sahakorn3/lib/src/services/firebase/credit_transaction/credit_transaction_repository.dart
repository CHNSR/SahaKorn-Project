import 'package:sahakorn3/src/models/credit_transaction.dart';
import 'credit_transaction_write_service.dart';
import 'fire_credit_transaction_read_service.dart';

class CreditTransactionRepository {
  final _readService = FireCreditTransactionReadService();
  final _writeService = FireCreditTransactionWriteService();

  // --- Read Methods ---

  Future<List<CreditTransaction>> getTransactionsByCreditId(String creditId) =>
      _readService.getTransactionsByCreditId(creditId);

  Future<List<CreditTransaction>> getTransactionsByShopId(String shopId) =>
      _readService.getTransactionsByShopId(shopId);

  // --- Write Methods ---

  /// Create a transaction and update credit balance atomically
  /// Create a purchase (loan) transaction
  Future<String?> createPurchase({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
  }) => _writeService.createCreditPurchase(
    creditId: creditId,
    userId: userId,
    shopId: shopId,
    amount: amount,
    note: note,
  );

  /// Grant credit limit (increase limit, no debt change)
  Future<String?> grantCreditLimit({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
  }) => _writeService.grantCreditLimit(
    creditId: creditId,
    userId: userId,
    shopId: shopId,
    amount: amount,
    note: note,
  );

  /// Create a repayment transaction
  Future<String?> createRepayment({
    required String creditId,
    required String userId,
    required String shopId,
    required double amount,
    String? note,
    String paymentMethod = 'Cash',
  }) => _writeService.createRepayment(
    creditId: creditId,
    userId: userId,
    shopId: shopId,
    amount: amount,
    note: note,
    paymentMethod: paymentMethod,
  );
}
