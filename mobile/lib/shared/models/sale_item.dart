import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'item_batch.dart';
import 'item.dart';
import 'sale_item_batch.dart';

part 'sale_item.g.dart';

/// SaleItem represents items in a sale
@JsonSerializable()
class SaleItem extends BaseModel {
  @JsonKey(name: 'saleId')
  final int saleId;

  @JsonKey(name: 'itemId')
  final int itemId;

  @JsonKey(name: 'batchId')
  final int? batchId;

  @JsonKey(name: 'batch')
  final ItemBatch? batch;

  @JsonKey(name: 'quantity')
  final double quantity;
  final double unitPrice;
  final double discount;
  final double total;
  final Item? item;
  final List<SaleItemBatch>? batches;

  const SaleItem({
    required super.id,
    required this.saleId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
    required super.createdAt,
    required super.updatedAt,
    this.batchId,
    this.batch,
    this.item,
    this.batches,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);

  /// Get subtotal before discount
  double get subtotal => unitPrice * quantity;

  /// Get discount amount
  double get discountAmount => subtotal * (discount / 100);

  /// Get net total after discount
  double get netTotal => subtotal - discountAmount;

  /// Check if item has discount
  bool get hasDiscount => discount > 0;

  /// Get display name for the item
  String get displayName => item?.name ?? 'Item #$itemId';

  /// Check if this sale item has a batch assigned
  bool get hasBatch => batchId != null;

  @override
  String toString() {
    return 'SaleItem{id: $id, itemId: $itemId, quantity: $quantity, unitPrice: $unitPrice, total: $total}';
  }
}
