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
      if (shops.isNotEmpty && _currentShop == null) {
        _currentShop = shops.first;
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

  void loadMockShops() {
    shops = [
      Shop(
        id: 'mock_1',
        name: 'SahaKorn Demo 1',
        address: '123 Fake St',
        phone: '0812345678',
        email: 'demo1@test.com',
        ownerId: 'mock_owner',
        description: 'Mock shop 1',
        logo: '',
        status: 'active',
      ),
      Shop(
        id: 'mock_2',
        name: 'SahaKorn Branch 2',
        address: '456 Test Ave',
        phone: '0898765432',
        email: 'demo2@test.com',
        ownerId: 'mock_owner',
        description: 'Mock shop 2',
        logo: '',
        status: 'active',
      ),
      Shop(
        id: 'mock_3',
        name: 'Coffee Cafe',
        address: '789 Java Rd',
        phone: '021239999',
        email: 'coffee@cafe.com',
        ownerId: 'mock_owner',
        description: 'Mock shop 3',
        logo: '',
        status: 'active',
      ),
    ];
    _currentShop = shops.first;
    notifyListeners();
  }
}
