// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Batch _$BatchFromJson(Map<String, dynamic> json) => Batch(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      batchNumber: json['batch_number'] as String,
      supplierId: (json['supplier_id'] as num).toInt(),
      purchaseDate: json['purchase_date'] as String,
      totalQuantity: (json['total_quantity'] as num).toInt(),
      soldQuantity: (json['sold_quantity'] as num?)?.toInt() ?? 0,
      unitCost: (json['unit_cost'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BatchToJson(Batch instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'batch_number': instance.batchNumber,
      'supplier_id': instance.supplierId,
      'purchase_date': instance.purchaseDate,
      'total_quantity': instance.totalQuantity,
      'sold_quantity': instance.soldQuantity,
      'unit_cost': instance.unitCost,
      'total_cost': instance.totalCost,
      'notes': instance.notes,
    };
