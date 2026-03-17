import 'package:equatable/equatable.dart';
import 'package:sahakorn3/src/models/shop.dart';

abstract class ShopState extends Equatable {
  const ShopState();
  
  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<Shop> shops;
  final Shop? currentShop;

  const ShopLoaded({
    required this.shops,
    this.currentShop,
  });

  @override
  List<Object?> get props => [shops, currentShop];
  
  ShopLoaded copyWith({
    List<Shop>? shops,
    Shop? currentShop,
  }) {
    return ShopLoaded(
      shops: shops ?? this.shops,
      currentShop: currentShop ?? this.currentShop,
    );
  }
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object> get props => [message];
}
