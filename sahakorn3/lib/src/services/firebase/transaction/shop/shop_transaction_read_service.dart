import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class ShopTransactionReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  Future<List<AppTransaction>> fetchByShopId(
    String shopId, {
    int limit = 50,
  }) async {
    if (shopId.isEmpty) return [];

    final snap =
        await _firestore
            .collection(collectionName)
            .where('shop_id', isEqualTo: shopId)
            .orderBy('created_at', descending: true)
            .limit(limit)
            .get();

    return snap.docs
        .map((d) => AppTransaction.fromMap(d.id, d.data()))
        .toList();
  }

  Future<Map<String, double>> calculateStats(String shopId) async {
    if (shopId.isEmpty) return {'totalBalance': 0.0, 'todaySales': 0.0};

    final snap =
        await _firestore
            .collection(collectionName)
            .where('shop_id', isEqualTo: shopId)
            .get();

    double totalBalance = 0.0;
    double todaySales = 0.0;
    final now = DateTime.now();

    for (var doc in snap.docs) {
      final data = doc.data();
      final method = data['payment_method'] as String? ?? '';

      double amount = 0.0;
      if (data['total_amount'] is num) {
        amount = (data['total_amount'] as num).toDouble();
      } else if (data['total_amount'] is String) {
        amount = double.tryParse(data['total_amount']) ?? 0.0;
      }

      bool isPositive = [
        'Income',
        'Payment',
        'Cash',
        'Credit',
      ].contains(method);
      bool isNegative = ['Expense', 'Loan'].contains(method);

      if (isPositive) {
        totalBalance += amount;
        final createdAt = _parseDate(data['created_at']);
        if (createdAt != null && _isSameDay(createdAt, now)) {
          todaySales += amount;
        }
      } else if (isNegative) {
        totalBalance -= amount;
      }
    }

    return {'totalBalance': totalBalance, 'todaySales': todaySales};
  }

  DateTime? _parseDate(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
