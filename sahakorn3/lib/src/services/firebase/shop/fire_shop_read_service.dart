import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/shop.dart';

class FireShopReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Shop>> fetchShopsByOwner(String ownerId) async {
    final snap =
        await _firestore
            .collection('shops')
            .where('ownerId', isEqualTo: ownerId)
            .get();
    return snap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList();
  }

  Future<int?> countShopsByOwner(String ownerId) async {
    try {
      final agg =
          await _firestore
              .collection('shops')
              .where('ownerId', isEqualTo: ownerId)
              .count()
              .get();
      return agg.count;
    } catch (_) {
      final snap =
          await _firestore
              .collection('shops')
              .where('ownerId', isEqualTo: ownerId)
              .get();
      return snap.docs.length;
    }
  }

  Stream<List<Shop>> watchShopsByOwner(String ownerId) {
    return _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Shop?> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists && doc.data() != null) {
        return Shop.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Shop>> searchShops(String query) async {
    // Simple mock-like search using startWith logic
    // Firestore doesn't support full text search natively.
    // We use the '>=' and '<=' range query trick for prefix search.
    try {
      final endQuery = '$query\uf8ff';
      final snap =
          await _firestore
              .collection('shops')
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThan: endQuery)
              .limit(20)
              .get();
      return snap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }
}
