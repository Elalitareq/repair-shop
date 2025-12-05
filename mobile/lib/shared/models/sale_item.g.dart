// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
  id: (json['id'] as num).toInt(),
  saleId: (json['saleId'] as num).toInt(),
  itemId: (json['itemId'] as num).toInt(),
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  discount: (json['discount'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  batchId: (json['batchId'] as num?)?.toInt(),
  batch: json['batch'] == null
      ? null
      : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
  item: json['item'] == null
      ? null
      : Item.fromJson(json['item'] as Map<String, dynamic>),
  batches: (json['batches'] as List<dynamic>?)
      ?.map((e) => SaleItemBatch.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'saleId': instance.saleId,
  'itemId': instance.itemId,
  'batchId': instance.batchId,
  'batch': instance.batch,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'discount': instance.discount,
  'total': instance.total,
  'item': instance.item,
  'batches': instance.batches,
};
