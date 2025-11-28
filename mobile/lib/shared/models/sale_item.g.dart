// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  saleId: (json['saleId'] as num).toInt(),
  itemId: (json['itemId'] as num).toInt(),
  batchId: (json['batchId'] as num?)?.toInt(),
  batch: json['batch'] == null
      ? null
      : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num).toDouble(),
  notes: json['notes'] as String?,
  item: json['item'] == null
      ? null
      : Item.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'saleId': instance.saleId,
  'itemId': instance.itemId,
  'batchId': instance.batchId,
  'batch': instance.batch,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'discount': instance.discount,
  'total': instance.total,
  'notes': instance.notes,
  'item': instance.item,
};
