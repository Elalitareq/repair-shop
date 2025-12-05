import 'package:json_annotation/json_annotation.dart';
import 'item_batch.dart';

part 'sale_item_batch.g.dart';

@JsonSerializable()
class SaleItemBatch {
  final int id;
  final int saleItemId;
  final int batchId;
  final double quantity;
  final DateTime createdAt;
  final ItemBatch? batch;

  const SaleItemBatch({
    required this.id,
    required this.saleItemId,
    required this.batchId,
    required this.quantity,
    required this.createdAt,
    this.batch,
  });

  factory SaleItemBatch.fromJson(Map<String, dynamic> json) =>
      _$SaleItemBatchFromJson(json);

  Map<String, dynamic> toJson() => _$SaleItemBatchToJson(this);
}
