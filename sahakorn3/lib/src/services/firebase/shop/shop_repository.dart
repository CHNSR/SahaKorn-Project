import 'package:sahakorn3/src/services/firebase/shop/fire_shop_read_service.dart';
import 'package:sahakorn3/src/services/firebase/shop/fire_shop_write_service.dart';
import 'package:sahakorn3/src/models/shop.dart';

class ShopRepository {
  final FireShopReadService readService;
  final FireShopWriteService writeService;
  ShopRepository({
    FireShopReadService? readService,
    FireShopWriteService? writeService,
  })  : readService = readService ?? FireShopReadService(),
        writeService = writeService ?? FireShopWriteService();

  // Read APIs
  Future<List<Shop>> getShopsByOwner(String ownerId) => readService.fetchShopsByOwner(ownerId);
  Future<int?> countShops(String ownerId) => readService.countShopsByOwner(ownerId);
  Stream<List<Shop>> watchShops(String ownerId) => readService.watchShopsByOwner(ownerId);

  // Write APIs
  Future<String?> createShop(Shop shop) => writeService.createShop(shop);
  Future<void> updateShop(String shopId, Map<String, dynamic> data) => writeService.updateShop(shopId, data);
  Future<void> deleteShop(String shopId) => writeService.deleteShop(shopId);
}