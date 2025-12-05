// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItemBatch _$SaleItemBatchFromJson(Map<String, dynamic> json) =>
    SaleItemBatch(
      id: (json['id'] as num).toInt(),
      saleItemId: (json['saleItemId'] as num).toInt(),
      batchId: (json['batchId'] as num).toInt(),
      quantity: (json['quantity'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      batch: json['batch'] == null
          ? null
          : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SaleItemBatchToJson(SaleItemBatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleItemId': instance.saleItemId,
      'batchId': instance.batchId,
      'quantity': instance.quantity,
      'createdAt': instance.createdAt.toIso8601String(),
      'batch': instance.batch,
    };
