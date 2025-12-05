// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_item_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepairItemBatch _$RepairItemBatchFromJson(Map<String, dynamic> json) =>
    RepairItemBatch(
      id: (json['id'] as num).toInt(),
      repairItemId: (json['repairItemId'] as num).toInt(),
      batchId: (json['batchId'] as num).toInt(),
      quantity: (json['quantity'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      batch: json['batch'] == null
          ? null
          : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RepairItemBatchToJson(RepairItemBatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repairItemId': instance.repairItemId,
      'batchId': instance.batchId,
      'quantity': instance.quantity,
      'createdAt': instance.createdAt.toIso8601String(),
      'batch': instance.batch,
    };
