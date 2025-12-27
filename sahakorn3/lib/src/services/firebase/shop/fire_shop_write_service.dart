import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahakorn3/src/models/shop.dart';

class FireShopWriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createShop(Shop shop) async {
    try {
      // Generate the ID locally first
      final docRef = _firestore.collection('shops').doc();

      await docRef.set({
        ...shop.toMap(),
        'id': docRef.id, // Save the ID in the document
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
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
