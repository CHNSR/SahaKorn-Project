import 'package:equatable/equatable.dart';

abstract class ShopCreditEvent extends Equatable {
  const ShopCreditEvent();

  @override
  List<Object> get props => [];
}

class LoadShopCreditData extends ShopCreditEvent {
  final String shopId;

  const LoadShopCreditData(this.shopId);

  @override
  List<Object> get props => [shopId];
}
