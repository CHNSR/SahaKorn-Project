import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sahakorn3/src/services/firebase/shop/shop_repository.dart';
import 'package:sahakorn3/src/utils/logger.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository _repository;

  ShopBloc({ShopRepository? repository})
      : _repository = repository ?? ShopRepository(),
        super(ShopInitial()) {
    on<LoadShopsEvent>(_onLoadShops);
    on<SelectShopEvent>(_onSelectShop);
  }

  Future<void> _onLoadShops(
    LoadShopsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(ShopLoading());
    try {
      logger.i('ShopBloc: Load shops for owner: ${event.ownerId}');
      final shops = await _repository.getShopsByOwner(event.ownerId);
      logger.i('ShopBloc: Loaded ${shops.length} shops');

      if (shops.isNotEmpty) {
        // If there's an existing current shop, try to keep it selected
        emit(ShopLoaded(shops: shops, currentShop: shops.first));
      } else {
        emit(ShopLoaded(shops: const []));
      }
    } catch (e, stackTrace) {
      logger.e(
        'ShopBloc: Error loading shops',
        error: e,
        stackTrace: stackTrace,
      );
      emit(ShopError(e.toString()));
    }
  }

  void _onSelectShop(
    SelectShopEvent event,
    Emitter<ShopState> emit,
  ) {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      logger.i('ShopBloc: Selected shop: ${event.shop.name}');
      emit(currentState.copyWith(currentShop: event.shop));
    }
  }
}
