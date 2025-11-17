import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer.dart';

part 'item_batch.g.dart';

/// ItemBatch represents batch purchases
@JsonSerializable()
class ItemBatch extends BaseModel {
  @JsonKey(name: 'batch_number')
  final String batchNumber;

  @JsonKey(name: 'supplier_id')
  final int supplierId;

  @JsonKey(name: 'supplier')
  final Customer? supplier;

  @JsonKey(name: 'purchase_date')
  final DateTime purchaseDate;

  @JsonKey(name: 'total_quantity')
  final int totalQuantity;

  @JsonKey(name: 'sold_quantity')
  final int soldQuantity;

  @JsonKey(name: 'total_cost')
  final double totalCost;

  @JsonKey(name: 'notes')
  final String? notes;

  const ItemBatch({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.batchNumber,
    required this.supplierId,
    this.supplier,
    required this.purchaseDate,
    required this.totalQuantity,
    this.soldQuantity = 0,
    required this.totalCost,
    this.notes,
  });

  factory ItemBatch.fromJson(Map<String, dynamic> json) =>
      _$ItemBatchFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemBatchToJson(this);

  /// Get remaining stock
  int get remainingStock {
    final remaining = totalQuantity - soldQuantity;
    return remaining < 0 ? 0 : remaining;
  }

  /// Get stock percentage remaining
  double get stockPercentage {
    if (totalQuantity == 0) return 0;
    return (remainingStock / totalQuantity) * 100;
  }

  /// Check if batch is low on stock (less than 20%)
  bool get isLowStock => stockPercentage < 20.0;

  /// Check if batch is out of stock
  bool get isOutOfStock => remainingStock == 0;

  /// Get cost per unit
  double get costPerUnit {
    if (totalQuantity == 0) return 0;
    return totalCost / totalQuantity;
  }

  @override
  String toString() {
    return 'ItemBatch{id: $id, batchNumber: $batchNumber, remaining: $remainingStock/$totalQuantity}';
  }
}

/// BatchStockInfo represents batch information with stock status
@JsonSerializable(explicitToJson: true)
class BatchStockInfo {
  final ItemBatch batch;

  @JsonKey(name: 'remaining_stock')
  final int remainingStock;

  @JsonKey(name: 'stock_percentage')
  final double stockPercentage;

  @JsonKey(name: 'is_low_stock')
  final bool isLowStock;

  @JsonKey(name: 'is_out_of_stock')
  final bool isOutOfStock;

  const BatchStockInfo({
    required this.batch,
    required this.remainingStock,
    required this.stockPercentage,
    required this.isLowStock,
    required this.isOutOfStock,
  });

  factory BatchStockInfo.fromJson(Map<String, dynamic> json) =>
      _$BatchStockInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BatchStockInfoToJson(this);

  @override
  String toString() {
    return 'BatchStockInfo{batch: ${batch.batchNumber}, remaining: $remainingStock, percentage: $stockPercentage%}';
  }
}
