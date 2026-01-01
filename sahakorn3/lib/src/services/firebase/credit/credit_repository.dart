import 'fire_credit_read_service.dart';
import 'fire_credit_write_service.dart';

class CreditRepository {
  final FireCreditReadService _readService = FireCreditReadService();
  final FireCreditWriteService _writeService = FireCreditWriteService();

  // --- Read Methods ---

  /// Count total number of loans in the system
  Future<int?> countTotalLoan() => _readService.countTotalLoan();

  /// Calculate total amount of all loans
  Future<double?> countTotalAmountLoan({String? shopId, String? status}) =>
      _readService.countTotalAmountLoan(shopId: shopId, status: status);

  // --- Write Methods ---

  /// Create a new credit record
  Future<String?> createCredit({
    required String userId,
    required String shopId,
    required double amount,
    required double interest,
    required int loanTerm,
    required String loanStatus,
  }) {
    return _writeService.createCredit(
      userId: userId,
      shopId: shopId,
      amount: amount,
      interest: interest,
      loanTerm: loanTerm,
      loanStatus: loanStatus,
    );
  }

  /// Update an existing credit record
  Future<String?> updateCredit({
    required String userId,
    required String shopId,
    required double amount,
    required double interest,
    required int loanTerm,
    required String loanStatus,
  }) {
    return _writeService.updateCredit(
      userId: userId,
      shopId: shopId,
      amount: amount,
      interest: interest,
      loanTerm: loanTerm,
      loanStatus: loanStatus,
    );
  }

  /// Delete a credit record
  Future<String?> deleteCredit({required String userId}) {
    return _writeService.deleteCredit(userId: userId);
  }
}
