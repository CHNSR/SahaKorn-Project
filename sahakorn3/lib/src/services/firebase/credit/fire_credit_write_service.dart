import 'package:cloud_firestore/cloud_firestore.dart';

class FireCreditWriteService {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'credit';
  //create credit for new user
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
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      await docRef.set({
        'userId': userId,
        'shopId': shopId,
        'creditLimit': creditLimit,
        'creditUsed': creditUsed,
        'interest': interest,
        'createdAt': FieldValue.serverTimestamp(),
        'loanTerm': loanTerm,
        'loanStatus': loanStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userName,
        'gender': gender,
        'age': age,
        'phoneNumber': phoneNumber,
        'address': address,
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  //update credit
  Future<String?> updateCredit({
    required String userId,
    required String shopId,
    required double creditLimit,
    required double creditUsed, // Renamed from amount
    required double interest,
    required int loanTerm,
    required String loanStatus,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      await docRef.update({
        'shopId': shopId,
        'creditLimit': creditLimit,
        'creditUsed': creditUsed, // Renamed from amount
        'interest': interest,
        'createdAt': FieldValue.serverTimestamp(),
        'loanTerm': loanTerm,
        'loanStatus': loanStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }

  //delete credit
  Future<String?> deleteCredit({required String userId}) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(userId);
      await docRef.delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Firestore error: ${e.code}';
    } catch (e) {
      return e.toString();
    }
  }
}
