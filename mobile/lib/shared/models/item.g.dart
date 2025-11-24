// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      name: json['name'] as String,
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      description: json['description'] as String?,
      conditionId: (json['condition_id'] as num?)?.toInt(),
      condition: json['condition'] == null
          ? null
          : Condition.fromJson(json['condition'] as Map<String, dynamic>),
      qualityId: (json['quality_id'] as num?)?.toInt(),
      quality: json['quality'] == null
          ? null
          : Quality.fromJson(json['quality'] as Map<String, dynamic>),
      itemType: json['item_type'] as String? ?? 'other',
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      minStockLevel: (json['min_stock_level'] as num?)?.toInt() ?? 5,
      sellingPrice: (json['selling_price'] as num?)?.toDouble(),
      barcodes: (json['barcodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'name': instance.name,
      'category_id': instance.categoryId,
      'category': instance.category?.toJson(),
      'brand': instance.brand,
      'model': instance.model,
      'description': instance.description,
      'condition_id': instance.conditionId,
      'condition': instance.condition?.toJson(),
      'quality_id': instance.qualityId,
      'quality': instance.quality?.toJson(),
      'item_type': instance.itemType,
      'stock_quantity': instance.stockQuantity,
      'min_stock_level': instance.minStockLevel,
      'selling_price': instance.sellingPrice,
      'barcodes': instance.barcodes,
    };
