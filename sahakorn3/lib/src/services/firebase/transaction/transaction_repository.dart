import 'fire_transaction_read_service.dart';
import 'fire_transaction_write_service.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class TransactionRepository {
  final FireTransactionReadService readService;
  final FireTransactionWriteService writeService;

  TransactionRepository({
    FireTransactionReadService? readService,
    FireTransactionWriteService? writeService,
  }) : readService = readService ?? FireTransactionReadService(),
       writeService = writeService ?? FireTransactionWriteService();

  // Read facade
  Future<AppTransaction?> getById(String id) => readService.fetchById(id);
  Future<List<AppTransaction>> getByUser(String userId, {int limit = 50}) =>
      readService.fetchByUser(userId, limit: limit);
  Future<int?> countByUser(String userId) => readService.countByUser(userId);
  Stream<List<AppTransaction>> watchByUser(String userId) =>
      readService.watchByUser(userId);
  Future<List<AppTransaction>> listAll({int limit = 100}) =>
      readService.fetchAll(limit: limit);

  // Stats
  Future<Map<String, double>> calculateStats({String? userId}) =>
      readService.calculateStats(userId: userId);

  // Write facade (return null on success, or String error)
  Future<String?> create(AppTransaction tx) =>
      writeService.createTransaction(tx: tx);
  Future<String?> update(String docId, Map<String, dynamic> data) =>
      writeService.updateTransaction(docId: docId, data: data);
  Future<String?> delete(String docId) => writeService.deleteTransaction(docId);
}
