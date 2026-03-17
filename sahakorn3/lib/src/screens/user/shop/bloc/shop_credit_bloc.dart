import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sahakorn3/src/services/firebase/credit/credit_repository.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'shop_credit_event.dart';
import 'shop_credit_state.dart';

class ShopCreditBloc extends Bloc<ShopCreditEvent, ShopCreditState> {
  final CreditRepository _creditRepo;
  final TransactionRepository _transactionRepo;

  ShopCreditBloc({
    required CreditRepository creditRepo,
    required TransactionRepository transactionRepo,
  })  : _creditRepo = creditRepo,
        _transactionRepo = transactionRepo,
        super(ShopCreditInitial()) {
    on<LoadShopCreditData>(_onLoadShopCreditData);
  }

  Future<void> _onLoadShopCreditData(
      LoadShopCreditData event, Emitter<ShopCreditState> emit) async {
    emit(ShopCreditLoading());
    try {
      final used = await _creditRepo.countTotalAmountDistributedCredit(
        shopId: event.shopId,
      );
      final txns = await _transactionRepo.getByCatagoryOfUser(
        catagory: TransactionQueryType.shop,
        playload: event.shopId,
        limit: 1000,
      );

      emit(ShopCreditLoaded(
        usedCredit: used ?? 0.0,
        transactions: txns,
      ));
    } catch (e) {
      emit(ShopCreditError(e.toString()));
    }
  }
}
