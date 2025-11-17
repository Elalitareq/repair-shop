// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepairItem _$RepairItemFromJson(Map<String, dynamic> json) => RepairItem(
      id: (json['id'] as num).toInt(),
      repairId: (json['repairId'] as num).toInt(),
      itemName: json['itemName'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      isLabor: json['isLabor'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RepairItemToJson(RepairItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'repairId': instance.repairId,
      'itemName': instance.itemName,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'isLabor': instance.isLabor,
    };
