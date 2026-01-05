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
  Future<String?> createTransaction({
    required String creditId,
    required String userId, // Added userId
    required String shopId,
    required double amount,
    required CreditTransactionType type,
    String? note,
  }) => _writeService.createTransaction(
    creditId: creditId,
    userId: userId,
    shopId: shopId,
    amount: amount,
    type: type,
    note: note,
  );
}
