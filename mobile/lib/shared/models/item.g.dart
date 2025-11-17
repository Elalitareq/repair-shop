// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      name: json['name'] as String,
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      imei: json['imei'] as String?,
      conditionId: (json['condition_id'] as num?)?.toInt(),
      condition: json['condition'] == null
          ? null
          : Condition.fromJson(json['condition'] as Map<String, dynamic>),
      qualityId: (json['quality_id'] as num?)?.toInt(),
      quality: json['quality'] == null
          ? null
          : Quality.fromJson(json['quality'] as Map<String, dynamic>),
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      supplierId: (json['supplier_id'] as num?)?.toInt(),
      supplier: json['supplier'] == null
          ? null
          : Customer.fromJson(json['supplier'] as Map<String, dynamic>),
      batchId: (json['batch_id'] as num?)?.toInt(),
      batch: json['batch'] == null
          ? null
          : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      unitCost: (json['unit_cost'] as num).toDouble(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'category_id': instance.categoryId,
      'category': instance.category?.toJson(),
      'brand': instance.brand,
      'model': instance.model,
      'imei': instance.imei,
      'condition_id': instance.conditionId,
      'condition': instance.condition?.toJson(),
      'quality_id': instance.qualityId,
      'quality': instance.quality?.toJson(),
      'purchase_date': instance.purchaseDate.toIso8601String(),
      'supplier_id': instance.supplierId,
      'supplier': instance.supplier?.toJson(),
      'batch_id': instance.batchId,
      'batch': instance.batch?.toJson(),
      'stock_quantity': instance.stockQuantity,
      'unit_cost': instance.unitCost,
    };
