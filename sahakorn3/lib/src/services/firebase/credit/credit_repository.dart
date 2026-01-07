import 'package:sahakorn3/src/models/credit.dart';
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

  /// Get all credits for a shop
  Future<List<Credit>> getCreditsByShop(String shopId) =>
      _readService.getCreditsByShop(shopId);

  /// Get credit by ID
  Future<Credit?> getCreditById(String creditId) =>
      _readService.getCreditById(creditId);

  // --- Write Methods ---

  /// Create a new credit record
  Future<String?> createCredit({
    required String userId,
    required String shopId,
    required double creditLimit,
    required double creditUsed,
    required double interest,
    required int loanTerm,
    required String loanStatus,
    String? userName,
    String? gender,
    int? age,
    String? phoneNumber,
    String? address,
  }) {
    return _writeService.createCredit(
      userId: userId,
      shopId: shopId,
      creditLimit: creditLimit,
      creditUsed: creditUsed,
      interest: interest,
      loanTerm: loanTerm,
      loanStatus: loanStatus,
      userName: userName,
      gender: gender,
      age: age,
      phoneNumber: phoneNumber,
      address: address,
    );
  }

  /// Update an existing credit record
  Future<String?> updateCredit({
    required String userId,
    required String shopId,
    required double creditLimit,
    required double creditUsed, // Renamed from amount
    required double interest,
    required int loanTerm,
    required String loanStatus,
  }) {
    return _writeService.updateCredit(
      userId: userId,
      shopId: shopId,
      creditLimit: creditLimit,
      creditUsed: creditUsed, // Renamed from amount
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
