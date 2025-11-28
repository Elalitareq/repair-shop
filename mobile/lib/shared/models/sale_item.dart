import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'item_batch.dart';
import 'item.dart';

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
  final int quantity;

  @JsonKey(name: 'unitPrice')
  final double unitPrice;

  @JsonKey(name: 'discount')
  final double discount;

  @JsonKey(name: 'total')
  final double total;

  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'item')
  final Item? item;

  const SaleItem({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.saleId,
    required this.itemId,
    this.batchId,
    this.batch,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    required this.total,
    this.notes,
    this.item,
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
