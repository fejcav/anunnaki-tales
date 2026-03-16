import '../database.dart';

class PurchasesTable extends SupabaseTable<PurchasesRow> {
  @override
  String get tableName => 'purchases';

  @override
  PurchasesRow createRow(Map<String, dynamic> data) => PurchasesRow(data);
}

class PurchasesRow extends SupabaseDataRow {
  PurchasesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PurchasesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get productId => getField<String>('product_id')!;
  set productId(String value) => setField<String>('product_id', value);

  String? get productType => getField<String>('product_type');
  set productType(String? value) => setField<String>('product_type', value);

  String? get revenueCatTransactionId =>
      getField<String>('revenue_cat_transaction_id');
  set revenueCatTransactionId(String? value) =>
      setField<String>('revenue_cat_transaction_id', value);

  double? get priceUsd => getField<double>('price_usd');
  set priceUsd(double? value) => setField<double>('price_usd', value);

  DateTime? get purchasedAt => getField<DateTime>('purchased_at');
  set purchasedAt(DateTime? value) => setField<DateTime>('purchased_at', value);
}
