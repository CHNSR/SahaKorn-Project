import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/transaction.dart';

class FireTransactionReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  Future<AppTransaction?> fetchById(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (!doc.exists) return null;
    return AppTransaction.fromMap(doc.id, doc.data());
  }

  //shop id for shop owner, user id for customer
  Future<List<AppTransaction>> fetchByUser(
    String customerId, {
    String? shopId,
    int limit = 50,
  }) async {
    Query query = _firestore.collection(collectionName);

    if (shopId != null && shopId.isNotEmpty) {
      query = query.where('shop_id', isEqualTo: shopId);
    } else {
      query = query.where('user_id', isEqualTo: customerId);
    }

    final snap =
        await query.orderBy('created_at', descending: true).limit(limit).get();

    return snap.docs
        .map(
          (d) => AppTransaction.fromMap(d.id, d.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<AppTransaction>> fetchForAnalytics({
    String? userId,
    String? shopId,
    int limit = 1000,
  }) async {
    Query query = _firestore.collection(collectionName);

    if (shopId != null && shopId.isNotEmpty) {
      query = query.where('shop_id', isEqualTo: shopId);
    } else if (userId != null && userId.isNotEmpty) {
      query = query.where('user_id', isEqualTo: userId);
    }

    final snap =
        await query.orderBy('created_at', descending: true).limit(limit).get();

    return snap.docs
        .map(
          (d) => AppTransaction.fromMap(d.id, d.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<int?> countByUser(String userId) async {
    try {
      final agg =
          await _firestore
              .collection(collectionName)
              .where('user_id', isEqualTo: userId)
              .count()
              .get();
      return agg.count;
    } catch (_) {
      final snap =
          await _firestore
              .collection(collectionName)
              .where('user_id', isEqualTo: userId)
              .get();
      return snap.docs.length;
    }
  }

  Stream<List<AppTransaction>> watchByUser(String userId) {
    return _firestore
        .collection(collectionName)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((d) => AppTransaction.fromMap(d.id, d.data()))
                  .toList(),
        );
  }

  Future<List<AppTransaction>> fetchAll({int limit = 100}) async {
    final snap =
        await _firestore
            .collection(collectionName)
            .orderBy('created_at', descending: true)
            .limit(limit)
            .get();
    return snap.docs
        .map((d) => AppTransaction.fromMap(d.id, d.data()))
        .toList();
  }

  /// Calculates total balance and today's sales.
  /// Returns a Map with keys: 'totalBalance', 'todaySales'.
  Future<Map<String, double>> calculateStats({
    String? userId,
    String? shopId,
  }) async {
    // 1. Query relevant transactions
    // Note: For large datasets, client-side aggregation is expensive.
    // Ideally, maintain running totals in a separate 'stats' document using Cloud Functions.
    // For now, we fetch all (or a reasonable limit) to calculate.
    Query query = _firestore.collection(collectionName);

    if (shopId != null && shopId.isNotEmpty) {
      query = query.where('shop_id', isEqualTo: shopId);
    } else if (userId != null) {
      query = query.where('user_id', isEqualTo: userId);
    }

    // Optimization: Only fetch fields needed (amount, type, date) if possible,
    // but Firestore client SDK doesn't support projection easily.
    final snap = await query.get();

    double totalBalance = 0.0;
    double todaySales = 0.0;
    final now = DateTime.now();

    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final method = data['payment_method'] as String? ?? '';

      // Handle amount from dynamic types
      double amount = 0.0;
      if (data['total_amount'] is num) {
        amount = (data['total_amount'] as num).toDouble();
      } else if (data['total_amount'] is String) {
        amount = double.tryParse(data['total_amount']) ?? 0.0;
      }

      // Logic:
      // Positive: Income, Payment, Cash, Credit
      // Negative: Expense, Loan
      bool isPositive = [
        'Income',
        'Payment',
        'Cash',
        'Credit',
      ].contains(method);
      bool isNegative = ['Expense', 'Loan'].contains(method);

      if (isPositive) {
        totalBalance += amount;

        // Check for today's sales (Income/Cash/Credit/Payment)
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
