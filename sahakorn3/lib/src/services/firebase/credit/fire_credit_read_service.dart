import 'package:cloud_firestore/cloud_firestore.dart';

class FireCreditReadService {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'credit';

  // count total loan
  Future<int?> countTotalLoan() async {
    try {
      final collection = _firestore.collection(_collectionName);
      final snapshot = await collection.count().get();
      return snapshot.count;
    } catch (e) {
      print('Error counting loans: $e');
      return 0;
    }
  }

  // count total amount loan
  Future<double?> countTotalAmountLoan({String? shopId, String? status}) async {
    try {
      final collection = _firestore.collection(_collectionName);
      Query query = collection;

      if (shopId != null && shopId.isNotEmpty) {
        query = query.where('shopId', isEqualTo: shopId);
      }

      if (status != null && status.isNotEmpty) {
        query = query.where('loanStatus', isEqualTo: status);
      }

      final snapshot = await query.aggregate(sum('amount')).get();
      return snapshot.getSum('amount');
    } catch (e) {
      print('Error summing loan amounts: $e');
      return 0.0;
    }
  }
}
