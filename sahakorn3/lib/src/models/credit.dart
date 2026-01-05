import 'package:cloud_firestore/cloud_firestore.dart';

class Credit {
  final String id;
  final String shopId;
  final double creditLimit; // Total Credit
  final double creditUsed; // Credit Use
  final double interest;
  final int loanTerm;
  final String loanStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName;

  Credit({
    required this.id,
    required this.shopId,
    required this.creditLimit,
    required this.creditUsed,
    required this.interest,
    required this.loanTerm,
    required this.loanStatus,
    this.createdAt,
    this.updatedAt,
    this.userName,
  });

  factory Credit.fromMap(String id, Map<String, dynamic> map) {
    return Credit(
      id: id,
      shopId: map['shopId'] ?? map['shopid'] ?? '',
      creditLimit: (map['creditLimit'] ?? 0.0).toDouble(),
      // Fallback to 'amount' for backward compatibility
      creditUsed: (map['creditUsed'] ?? map['amount'] ?? 0.0).toDouble(),
      interest: (map['interest'] ?? 0.0).toDouble(),
      loanTerm: map['loanTerm'] ?? 0,
      loanStatus: map['loanStatus'] ?? 'Unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      userName: map['userName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'interest': interest,
      'loanTerm': loanTerm,
      'loanStatus': loanStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
