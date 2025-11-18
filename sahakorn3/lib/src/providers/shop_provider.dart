import 'package:flutter/material.dart';
import 'package:sahakorn3/src/services/firebase/shop/shop_repository.dart';
import 'package:sahakorn3/src/models/shop.dart';

class ShopProvider extends ChangeNotifier {
  final ShopRepository repo;
  List<Shop> shops = [];
  bool loading = false;

  ShopProvider({ShopRepository? repository}) : repo = repository ?? ShopRepository();

  Future<void> loadShops(String ownerId) async {
    loading = true;
    notifyListeners();
    shops = await repo.getShopsByOwner(ownerId);
    loading = false;
    notifyListeners();
  }

  Future<int?> countShops(String ownerId) => repo.countShops(ownerId);
}