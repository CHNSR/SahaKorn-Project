import 'package:cloud_firestore/cloud_firestore.dart';

class AppTransaction {
  final String? docId; // Firestore Document ID
  final String transactionId;
  final String userId;
  final String productId;
  final String paymentMethod;
  final double totalAmount;
  final String? detail;
  final DateTime? createdAt;
  final List<Map<String, dynamic>>? editHistory;

  AppTransaction({
    this.docId,
    required this.transactionId,
    required this.userId,
    required this.productId,
    required this.paymentMethod,
    required this.totalAmount,
    this.detail,
    this.createdAt,
    this.editHistory,
  });

  factory AppTransaction.fromMap(String id, Map<String, dynamic>? data) {
    data ??= {};
    final ts = data['created_at'];
    DateTime? created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is Map && ts['_seconds'] != null) {
      created = DateTime.fromMillisecondsSinceEpoch(
        (ts['_seconds'] as int) * 1000,
      );
    } else if (ts is int) {
      created = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }

    return AppTransaction(
      docId: id,
      transactionId: data['transaction_id'] as String? ?? id,
      userId: data['user_id'] as String? ?? '',
      productId: data['product_id'] as String? ?? '',
      paymentMethod: data['payment_method'] as String? ?? '',
      totalAmount:
          (data['total_amount'] is num)
              ? (data['total_amount'] as num).toDouble()
              : double.tryParse('${data['total_amount']}') ?? 0.0,
      detail: data['detail'] as String?,
      createdAt: created,
      editHistory:
          (data['edit_history'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'transaction_id': transactionId,
    'user_id': userId,
    'product_id': productId,
    'payment_method': paymentMethod,
    'total_amount': totalAmount,
    'detail': detail,
    'created_at':
        createdAt != null
            ? _timestampFromDate(createdAt!)
            : FieldValue.serverTimestamp(),
    'edit_history': editHistory,
  };

  // helper for serializing DateTime to a map-like timestamp if needed
  dynamic _timestampFromDate(DateTime d) =>
      Timestamp.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
}
