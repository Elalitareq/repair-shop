// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Serial _$SerialFromJson(Map<String, dynamic> json) => Serial(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      imei: json['imei'] as String,
      itemId: (json['item_id'] as num).toInt(),
      batchId: (json['batch_id'] as num).toInt(),
      batch: json['batch'] == null
          ? null
          : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'available',
    );

Map<String, dynamic> _$SerialToJson(Serial instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'imei': instance.imei,
      'item_id': instance.itemId,
      'batch_id': instance.batchId,
      'batch': instance.batch,
      'status': instance.status,
    };
