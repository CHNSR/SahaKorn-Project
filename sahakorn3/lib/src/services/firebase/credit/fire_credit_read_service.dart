import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/credit.dart';

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
        // Note: Can't easily OR queries in Firestore without multiple queries.
        // For sum aggregation, this is tricky.
        // We will assume data migration or just query the primary field for now.
        // Or if we really need both, we do two aggregations.
        // Let's stick to the corrected field 'shopId' for future correctness.
        // User agreed to fix so we prioritize 'shopId'.
        // We can add a check for 'shopid' if 'shopId' yields 0 maybe?
        // For simplicity and performance, query 'shopId'.
        query = query.where('shopId', isEqualTo: shopId);
      }

      if (status != null && status.isNotEmpty) {
        query = query.where('loanStatus', isEqualTo: status);
      }

      final snapshot = await query.aggregate(sum('creditUsed')).get();
      return snapshot.getSum('creditUsed');
    } catch (e) {
      print('Error summing loan amounts: $e');
      return 0.0;
    }
  }

  // get credits by shopId
  Future<List<Credit>> getCreditsByShop(String shopId) async {
    try {
      final collection = _firestore.collection(_collectionName);
      final snapshot =
          await collection.where('shopId', isEqualTo: shopId).get();

      // Fallback for old data with 'shopid'
      final oldSnapshot =
          await collection.where('shopid', isEqualTo: shopId).get();

      final Set<String> docIds = {};
      final List<Credit> credits = [];

      // Add new schema docs
      for (var doc in snapshot.docs) {
        if (docIds.add(doc.id)) {
          credits.add(Credit.fromMap(doc.id, doc.data()));
        }
      }

      // Add old schema docs if not already added
      for (var doc in oldSnapshot.docs) {
        if (docIds.add(doc.id)) {
          credits.add(Credit.fromMap(doc.id, doc.data()));
        }
      }

      return credits;
    } catch (e) {
      print('Error fetching credits: $e');
      return [];
    }
  }
}
