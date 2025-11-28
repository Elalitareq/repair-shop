// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepairItem _$RepairItemFromJson(Map<String, dynamic> json) => RepairItem(
  id: (json['id'] as num).toInt(),
  repairId: (json['repairId'] as num?)?.toInt(),
  itemName: json['itemName'] as String?,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unitPrice: (json['unitPrice'] as num?)?.toDouble(),
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
  isLabor: json['isLabor'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RepairItemToJson(RepairItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'repairId': instance.repairId,
      'itemName': instance.itemName,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'isLabor': instance.isLabor,
    };
