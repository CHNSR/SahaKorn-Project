enum TransactionQueryType {
  shop('shop_id'),
  user('user_id');

  final String fieldName;
  const TransactionQueryType(this.fieldName);
}
