import 'package:equatable/equatable.dart';
import 'package:sahakorn3/src/routes/exports.dart';

abstract class ShopCreditState extends Equatable {
  const ShopCreditState();
  
  @override
  List<Object> get props => [];
}

class ShopCreditInitial extends ShopCreditState {}

class ShopCreditLoading extends ShopCreditState {}

class ShopCreditLoaded extends ShopCreditState {
  final double usedCredit;
  final List<AppTransaction> transactions;

  const ShopCreditLoaded({
    required this.usedCredit,
    required this.transactions,
  });

  @override
  List<Object> get props => [usedCredit, transactions];
}

class ShopCreditError extends ShopCreditState {
  final String message;

  const ShopCreditError(this.message);

  @override
  List<Object> get props => [message];
}
