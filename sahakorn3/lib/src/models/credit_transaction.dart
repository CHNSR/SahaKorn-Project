import 'package:cloud_firestore/cloud_firestore.dart';

enum CreditTransactionType {
  purchase,
  repayment,
  adjustment,
  grant_limit; // New type

  String get name => toString().split('.').last;

  static CreditTransactionType fromString(String status) {
    return CreditTransactionType.values.firstWhere(
      (e) => e.name == status,
      orElse: () => CreditTransactionType.purchase,
    );
  }
}

class CreditTransaction {
  final String id;
  final String creditId; // References the Credit document
  final String userId; // Explicit User ID
  final String shopId;
  final double amount;
  final CreditTransactionType type;
  final double remainingDebt; // Snapshot of debt after this transaction
  final String? note;
  final DateTime? createdAt;

  CreditTransaction({
    required this.id,
    required this.creditId,
    required this.userId,
    required this.shopId,
    required this.amount,
    required this.type,
    required this.remainingDebt,
    this.note,
    this.createdAt,
  });

  factory CreditTransaction.fromMap(String id, Map<String, dynamic> map) {
    return CreditTransaction(
      id: id,
      creditId: map['creditId'] ?? '',
      userId: map['userId'] ?? '',
      shopId: map['shopId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: CreditTransactionType.fromString(map['type'] ?? 'purchase'),
      remainingDebt: (map['remainingDebt'] ?? 0.0).toDouble(),
      note: map['note'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'userId': userId,
      'shopId': shopId,
      'amount': amount,
      'type': type.name,
      'remainingDebt': remainingDebt,
      'note': note,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
