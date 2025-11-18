import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart'; 
import 'package:sahakorn3/src/models/shop.dart';

class FireShopReadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Shop>> fetchShopsByOwner(String ownerId) async {
    final snap = await _firestore.collection('shops').where('ownerId', isEqualTo: ownerId).get();
    return snap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList();
  }

  Future<int?> countShopsByOwner(String ownerId) async {
    try {
      final agg = await _firestore.collection('shops').where('ownerId', isEqualTo: ownerId).count().get();
      return agg.count;
    } catch (_) {
      final snap = await _firestore.collection('shops').where('ownerId', isEqualTo: ownerId).get();
      return snap.docs.length;
    }
  }

  Stream<List<Shop>> watchShopsByOwner(String ownerId) {
    return _firestore.collection('shops').where('ownerId', isEqualTo: ownerId).snapshots().map(
        (snap) => snap.docs.map((d) => Shop.fromMap(d.id, d.data())).toList());
  }
}