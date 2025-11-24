import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'category.dart';
import 'condition.dart';
import 'quality.dart';

part 'item.g.dart';

@JsonSerializable(explicitToJson: true)
class Item extends BaseModel {
  final String name;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final Category? category;
  final String? brand;
  final String? model;
  // IMEI moved to Serial model - use Serial list to represent device serials
  final String? description;
  @JsonKey(name: 'condition_id')
  final int? conditionId;
  final Condition? condition;
  @JsonKey(name: 'quality_id')
  final int? qualityId;
  final Quality? quality;
  @JsonKey(name: 'item_type')
  final String itemType; // 'phone' or 'other'
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'min_stock_level')
  final int minStockLevel;
  @JsonKey(name: 'selling_price')
  final double? sellingPrice;
  final List<String>? barcodes; // List of barcode strings

  Item({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.categoryId,
    this.category,
    this.brand,
    this.model,
    this.description,
    this.conditionId,
    this.condition,
    this.qualityId,
    this.quality,
    this.itemType = 'other',
    this.stockQuantity = 0,
    this.minStockLevel = 5,
    this.sellingPrice,
    this.barcodes,
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
    String? description,
    int? conditionId,
    Condition? condition,
    int? qualityId,
    Quality? quality,
    String? itemType,
    int? stockQuantity,
    int? minStockLevel,
    double? sellingPrice,
    List<String>? barcodes,
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
      description: description ?? this.description,
      conditionId: conditionId ?? this.conditionId,
      condition: condition ?? this.condition,
      qualityId: qualityId ?? this.qualityId,
      quality: quality ?? this.quality,
      itemType: itemType ?? this.itemType,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      barcodes: barcodes ?? this.barcodes,
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
