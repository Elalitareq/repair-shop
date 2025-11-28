// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Serial _$SerialFromJson(Map<String, dynamic> json) => Serial(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  imei: json['imei'] as String,
  itemId: (json['itemId'] as num).toInt(),
  batchId: (json['batchId'] as num).toInt(),
  batch: json['batch'] == null
      ? null
      : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
  status: json['status'] as String? ?? 'available',
);

Map<String, dynamic> _$SerialToJson(Serial instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'imei': instance.imei,
  'itemId': instance.itemId,
  'batchId': instance.batchId,
  'batch': instance.batch,
  'status': instance.status,
};
