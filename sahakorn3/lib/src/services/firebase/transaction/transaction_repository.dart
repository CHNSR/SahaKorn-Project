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

  // --- Write Operations ---
  Future<String?> create(AppTransaction tx) =>
      _writeService.createTransaction(tx: tx);
  Future<String?> update(String docId, Map<String, dynamic> data) =>
      _writeService.updateTransaction(docId: docId, data: data);
  Future<String?> delete(String docId) =>
      _writeService.deleteTransaction(docId);
}
