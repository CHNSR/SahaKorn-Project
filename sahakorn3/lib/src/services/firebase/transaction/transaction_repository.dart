import 'package:sahakorn3/src/services/firebase/transaction/fire_transaction_write_service.dart';

import 'package:sahakorn3/src/services/firebase/transaction/fire_transaction_read_service.dart'; // Keep for specific mixed use if needed, or remove?
import 'package:sahakorn3/src/models/transaction.dart';
import 'package:sahakorn3/src/models/transaction_query_type.dart';

class TransactionRepository {
  // We keep the old readService for backward compatibility if any legacy calls exist,
  // but ideally we switch to specific ones.
  // final FireTransactionReadService readService;

  final FireTransactionWriteService _writeService;
  final FireTransactionReadService _oldReadService; // Temporary fallback

  TransactionRepository({
    FireTransactionWriteService? writeService,
    FireTransactionReadService? oldReadService,
  }) : _writeService = writeService ?? FireTransactionWriteService(),
       _oldReadService = oldReadService ?? FireTransactionReadService();

  // --- SHOP Queries ---
  Future<Map<String, double>> calculateStats({String? userId, String? shopId}) {
    return _oldReadService.calculateStats(userId: userId, shopId: shopId);
  }

  Future<List<AppTransaction>> fetchForAnalytics(
    String userId, {
    String? shopId,
  }) {
    return _oldReadService.fetchForAnalytics(userId: userId, shopId: shopId);
  }

  Future<List<AppTransaction>> getByCatagoryOfUser({
    required TransactionQueryType catagory,
    required String playload,
    required int limit,
  }) {
    return _oldReadService.getByCategoryOfUser(
      category: catagory,
      key: playload,
      limit: limit,
    );
  }

  // --- Facade Wrappers (Routing) ---

  Future<AppTransaction?> getById(String id) => _oldReadService.fetchById(id);

  Stream<List<AppTransaction>> watchByUser(String userId) =>
      _oldReadService.watchByUser(userId);

  Future<List<AppTransaction>> listAll({int limit = 100}) =>
      _oldReadService.fetchAll(limit: limit);

  // --- Customer Queries ---
  Stream<List<AppTransaction>> watchTransactionsByCustomer(String customerId) {
    return _oldReadService.watchByCustomer(customerId);
  }

  Future<double> fetchTotalUnpaidByCustomer(String customerId) async {
    // Fetch all 'Unpaid' transactions for this customer
    // We'll rely on oldReadService having a way to query by (userId, paymentMethod='Credit')
    // For now, let's fetch all user transactions and filter in memory if needed
    // or add a specific query in oldReadService.
    // Assuming 'Credit' payment method implies debt.
    final txs = await _oldReadService.fetchAllByCustomer(customerId);
    // Filter for Credit AND (Unpaid status? - currently we don't have explicit status field in AppTransaction,
    // usually Credit means it is a loan. Logic might need adjustment if we track repayment status).
    // For now, assume ALL 'Credit' transactions are debts.
    // TODO: Filter by 'Status' if added later.
    final creditTxs = txs.where(
      (t) => t.paymentMethod == 'Credit',
    ); // && t.status != 'Paid'

    // Sum total
    double total = 0;
    for (var t in creditTxs) {
      total += t.totalAmount;
    }
    return total;
  }

  // --- Write Operations ---
  Future<String?> create(AppTransaction tx) =>
      _writeService.createTransaction(tx: tx);
  Future<String?> update(String docId, Map<String, dynamic> data) =>
      _writeService.updateTransaction(docId: docId, data: data);
  Future<String?> delete(String docId) =>
      _writeService.deleteTransaction(docId);
}
