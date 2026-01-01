import 'package:sahakorn3/src/services/firebase/transaction/fire_transaction_write_service.dart';
import 'package:sahakorn3/src/services/firebase/transaction/shop/shop_transaction_read_service.dart';
import 'package:sahakorn3/src/services/firebase/transaction/customer/customer_transaction_read_service.dart';
import 'package:sahakorn3/src/services/firebase/transaction/fire_transaction_read_service.dart'; // Keep for specific mixed use if needed, or remove?
import 'package:sahakorn3/src/models/transaction.dart';

class TransactionRepository {
  // We keep the old readService for backward compatibility if any legacy calls exist,
  // but ideally we switch to specific ones.
  // final FireTransactionReadService readService;

  final ShopTransactionReadService _shopRead;
  final CustomerTransactionReadService _customerRead;
  final FireTransactionWriteService _writeService;
  final FireTransactionReadService _oldReadService; // Temporary fallback

  TransactionRepository({
    ShopTransactionReadService? shopRead,
    CustomerTransactionReadService? customerRead,
    FireTransactionWriteService? writeService,
    FireTransactionReadService? oldReadService,
  }) : _shopRead = shopRead ?? ShopTransactionReadService(),
       _customerRead = customerRead ?? CustomerTransactionReadService(),
       _writeService = writeService ?? FireTransactionWriteService(),
       _oldReadService = oldReadService ?? FireTransactionReadService();

  // --- SHOP Queries ---
  Future<Map<String, double>> calculateStats({String? userId, String? shopId}) {
    if (shopId != null) {
      return _shopRead.calculateStats(shopId);
    }
    // Fallback to old behavior for userId-only calls (if any)
    return _oldReadService.calculateStats(userId: userId);
  }

  Future<List<AppTransaction>> fetchForAnalytics(
    String userId, {
    String? shopId,
  }) {
    if (shopId != null) {
      return _shopRead.fetchByShopId(shopId, limit: 1000);
    }
    return _customerRead.fetchByUserId(userId, limit: 1000);
  }

  Future<List<AppTransaction>> getByUser(
    String userId, {
    String? shopId,
    int limit = 50,
  }) {
    if (shopId != null) {
      return _shopRead.fetchByShopId(shopId, limit: limit);
    }
    return _customerRead.fetchByUserId(userId, limit: limit);
  }

  // --- Facade Wrappers (Routing) ---

  Future<AppTransaction?> getById(String id) => _oldReadService.fetchById(id);

  // Deprecated/Unused in new flow?
  Future<int?> countByUser(String userId) =>
      _oldReadService.countByUser(userId);

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
