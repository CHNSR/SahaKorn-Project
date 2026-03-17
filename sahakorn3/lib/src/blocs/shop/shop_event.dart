import 'package:equatable/equatable.dart';
import 'package:sahakorn3/src/models/shop.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object> get props => [];
}

class LoadShopsEvent extends ShopEvent {
  final String ownerId;

  const LoadShopsEvent(this.ownerId);

  @override
  List<Object> get props => [ownerId];
}

class SelectShopEvent extends ShopEvent {
  final Shop shop;

  const SelectShopEvent(this.shop);

  @override
  List<Object> get props => [shop];
}
