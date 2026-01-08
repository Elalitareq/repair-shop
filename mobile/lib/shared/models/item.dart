import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'category.dart';
import 'condition.dart';
import 'quality.dart';

part 'item.g.dart';

@JsonSerializable(explicitToJson: true)
class Item extends BaseModel {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'categoryId')
  final int categoryId;

  final Category? category;
  final String? brand;

  final String? model;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'conditionId')
  final int conditionId;
  final Condition? condition;
  @JsonKey(name: 'qualityId')
  final int qualityId;
  final Quality? quality;
  @JsonKey(name: 'itemType')
  final String itemType; // 'phone' or 'other'
  @JsonKey(name: 'stockQuantity')
  final int stockQuantity;
  @JsonKey(name: 'minStockLevel')
  final int minStockLevel;
  @JsonKey(name: 'sellingPrice')
  final double? sellingPrice;
  @JsonKey(name: 'lastBatchPrice')
  final double lastBatchPrice;
  final List<String>? barcodes; // List of barcode strings

  Item({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.categoryId,
    this.category,
    this.brand,
    this.model,
    this.description,
    required this.conditionId,
    this.condition,
    required this.qualityId,
    this.quality,
    this.itemType = 'other',
    this.stockQuantity = 0,
    this.minStockLevel = 5,
    this.sellingPrice,
    this.lastBatchPrice = 0.0,
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
    double? lastBatchPrice,
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
      lastBatchPrice: lastBatchPrice ?? this.lastBatchPrice,
      barcodes: barcodes ?? this.barcodes,
    );
  }

  bool get isLowStock => stockQuantity < 10;
  bool get isOutOfStock => stockQuantity == 0;

  String get displayName {
    final b = brand ?? '';
    final m = model ?? '';
    if (b.isEmpty && m.isEmpty) return name;
    return '$b $m - $name'.trim();
  }

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}
