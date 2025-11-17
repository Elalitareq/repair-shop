import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'category.dart';
import 'condition.dart';
import 'quality.dart';
import 'customer.dart';
import 'item_batch.dart';

part 'item.g.dart';

@JsonSerializable(explicitToJson: true)
class Item extends BaseModel {
  final String name;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final Category? category;
  final String? brand;
  final String? model;
  final String? imei;
  @JsonKey(name: 'condition_id')
  final int? conditionId;
  final Condition? condition;
  @JsonKey(name: 'quality_id')
  final int? qualityId;
  final Quality? quality;
  @JsonKey(name: 'purchase_date')
  final DateTime purchaseDate;
  @JsonKey(name: 'supplier_id')
  final int? supplierId;
  final Customer? supplier;
  @JsonKey(name: 'batch_id')
  final int? batchId;
  final ItemBatch? batch;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'unit_cost')
  final double unitCost;

  Item({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.categoryId,
    this.category,
    this.brand,
    this.model,
    this.imei,
    this.conditionId,
    this.condition,
    this.qualityId,
    this.quality,
    required this.purchaseDate,
    this.supplierId,
    this.supplier,
    this.batchId,
    this.batch,
    this.stockQuantity = 0,
    required this.unitCost,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    int? categoryId,
    Category? category,
    String? brand,
    String? model,
    String? imei,
    int? conditionId,
    Condition? condition,
    int? qualityId,
    Quality? quality,
    DateTime? purchaseDate,
    int? supplierId,
    Customer? supplier,
    int? batchId,
    ItemBatch? batch,
    int? stockQuantity,
    double? unitCost,
  }) {
    return Item(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      imei: imei ?? this.imei,
      conditionId: conditionId ?? this.conditionId,
      condition: condition ?? this.condition,
      qualityId: qualityId ?? this.qualityId,
      quality: quality ?? this.quality,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      supplierId: supplierId ?? this.supplierId,
      supplier: supplier ?? this.supplier,
      batchId: batchId ?? this.batchId,
      batch: batch ?? this.batch,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  bool get isLowStock => stockQuantity < 10;
  bool get isOutOfStock => stockQuantity == 0;

  String get displayName {
    if (brand != null && model != null) {
      return '$brand $model - $name';
    } else if (brand != null) {
      return '$brand - $name';
    }
    return name;
  }

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}
