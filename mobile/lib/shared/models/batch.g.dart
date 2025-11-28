// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Batch _$BatchFromJson(Map<String, dynamic> json) => Batch(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  batchNumber: json['batchNumber'] as String,
  supplierId: (json['supplierId'] as num).toInt(),
  purchaseDate: json['purchaseDate'] as String,
  totalQuantity: (json['totalQuantity'] as num).toInt(),
  soldQuantity: (json['soldQuantity'] as num?)?.toInt() ?? 0,
  unitCost: (json['unitCost'] as num).toDouble(),
  totalCost: (json['totalCost'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BatchToJson(Batch instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'batchNumber': instance.batchNumber,
  'supplierId': instance.supplierId,
  'purchaseDate': instance.purchaseDate,
  'totalQuantity': instance.totalQuantity,
  'soldQuantity': instance.soldQuantity,
  'unitCost': instance.unitCost,
  'totalCost': instance.totalCost,
  'notes': instance.notes,
};
