// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
  categoryId: (json['categoryId'] as num).toInt(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  brand: json['brand'] as String,
  model: json['model'] as String,
  description: json['description'] as String?,
  conditionId: (json['conditionId'] as num).toInt(),
  condition: json['condition'] == null
      ? null
      : Condition.fromJson(json['condition'] as Map<String, dynamic>),
  qualityId: (json['qualityId'] as num).toInt(),
  quality: json['quality'] == null
      ? null
      : Quality.fromJson(json['quality'] as Map<String, dynamic>),
  itemType: json['itemType'] as String? ?? 'other',
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  minStockLevel: (json['minStockLevel'] as num?)?.toInt() ?? 5,
  sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
  lastBatchPrice: (json['lastBatchPrice'] as num?)?.toDouble() ?? 0.0,
  barcodes: (json['barcodes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'name': instance.name,
  'categoryId': instance.categoryId,
  'category': instance.category?.toJson(),
  'brand': instance.brand,
  'model': instance.model,
  'description': instance.description,
  'conditionId': instance.conditionId,
  'condition': instance.condition?.toJson(),
  'qualityId': instance.qualityId,
  'quality': instance.quality?.toJson(),
  'itemType': instance.itemType,
  'stockQuantity': instance.stockQuantity,
  'minStockLevel': instance.minStockLevel,
  'sellingPrice': instance.sellingPrice,
  'lastBatchPrice': instance.lastBatchPrice,
  'barcodes': instance.barcodes,
};
