import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'item_batch.dart';

part 'sale_item.g.dart';

/// SaleItem represents items in a sale
@JsonSerializable()
class SaleItem extends BaseModel {
  @JsonKey(name: 'sale_id')
  final int saleId;

  @JsonKey(name: 'item_id')
  final int itemId;

  @JsonKey(name: 'batch_id')
  final int? batchId;

  @JsonKey(name: 'batch')
  final ItemBatch? batch;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'unit_price')
  final double unitPrice;

  @JsonKey(name: 'discount')
  final double discount;

  @JsonKey(name: 'total')
  final double total;

  @JsonKey(name: 'notes')
  final String? notes;

  // Item name for display (from Item relationship)
  @JsonKey(name: 'item_name')
  final String? itemName;

  const SaleItem({
    required super.id,
    super.createdAt,
    super.updatedAt,
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
    this.itemName,
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
  String get displayName => itemName ?? 'Item #$itemId';

  /// Check if this sale item has a batch assigned
  bool get hasBatch => batchId != null;

  @override
  String toString() {
    return 'SaleItem{id: $id, itemId: $itemId, quantity: $quantity, unitPrice: $unitPrice, total: $total}';
  }
}
