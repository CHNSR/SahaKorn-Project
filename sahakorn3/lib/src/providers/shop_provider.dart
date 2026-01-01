import 'package:flutter/material.dart';
import 'package:sahakorn3/src/services/firebase/shop/shop_repository.dart';
import 'package:sahakorn3/src/models/shop.dart';
import 'package:sahakorn3/src/utils/logger.dart';

class ShopProvider extends ChangeNotifier {
  final ShopRepository repo;
  List<Shop> shops = [];
  Shop? _currentShop;
  bool loading = false;
  Shop? get currentShop => _currentShop;

  ShopProvider({ShopRepository? repository})
    : repo = repository ?? ShopRepository();

  Future<List<Shop>> loadShops(String ownerId) async {
    try {
      logger.i('Provider: Load shops for owner: $ownerId');
      loading = true;
      notifyListeners();
      shops = await repo.getShopsByOwner(ownerId);
      loading = false;
      notifyListeners();
      logger.i('Provider: Loaded ${shops.length} shops: $shops');

      // Select first shop by default if none selected
      if (shops.isNotEmpty) {
        if (_currentShop == null) {
          _currentShop = shops.first;
        } else {
          // Refresh current shop data
          final refreshedShop = shops.firstWhere(
            (s) => s.id == _currentShop!.id,
            orElse: () => shops.first,
          );
          _currentShop = refreshedShop;
        }
      }
      return shops;
    } catch (e, stackTrace) {
      logger.e(
        'Provider: Error loading shops',
        error: e,
        stackTrace: stackTrace,
      );
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<int?> countShops(String ownerId) => repo.countShops(ownerId);

  void selectShop(Shop shop) {
    _currentShop = shop;
    logger.i('Selected shop: ${shop.name}');
    notifyListeners();
  }
}
