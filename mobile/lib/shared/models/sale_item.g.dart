// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => SaleItem(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      saleId: (json['sale_id'] as num).toInt(),
      itemId: (json['item_id'] as num).toInt(),
      batchId: (json['batch_id'] as num?)?.toInt(),
      batch: json['batch'] == null
          ? null
          : ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      itemName: json['item_name'] as String?,
    );

Map<String, dynamic> _$SaleItemToJson(SaleItem instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'sale_id': instance.saleId,
      'item_id': instance.itemId,
      'batch_id': instance.batchId,
      'batch': instance.batch,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'discount': instance.discount,
      'total': instance.total,
      'notes': instance.notes,
      'item_name': instance.itemName,
    };
