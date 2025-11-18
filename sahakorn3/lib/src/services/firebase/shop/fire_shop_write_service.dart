import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/shop.dart';

class FireShopWriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createShop(Shop shop) async {
    try {
      final doc = await _firestore.collection('shops').add({
        ...shop.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } on FirebaseException catch (e) {
      return Future.error(e.message ?? e.code);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    await _firestore.collection('shops').doc(shopId).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteShop(String shopId) async {
    await _firestore.collection('shops').doc(shopId).delete();
  }
}