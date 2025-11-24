// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemBatch _$ItemBatchFromJson(Map<String, dynamic> json) => ItemBatch(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      serials: (json['serials'] as List<dynamic>?)
          ?.map((e) => Serial.fromJson(e as Map<String, dynamic>))
          .toList(),
      batchNumber: json['batch_number'] as String,
      supplierId: (json['supplier_id'] as num).toInt(),
      supplier: json['supplier'] == null
          ? null
          : Customer.fromJson(json['supplier'] as Map<String, dynamic>),
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      totalQuantity: (json['total_quantity'] as num).toInt(),
      soldQuantity: (json['sold_quantity'] as num?)?.toInt() ?? 0,
      totalCost: (json['total_cost'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ItemBatchToJson(ItemBatch instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'batch_number': instance.batchNumber,
      'supplier_id': instance.supplierId,
      'supplier': instance.supplier,
      'purchase_date': instance.purchaseDate.toIso8601String(),
      'total_quantity': instance.totalQuantity,
      'serials': instance.serials,
      'sold_quantity': instance.soldQuantity,
      'total_cost': instance.totalCost,
      'notes': instance.notes,
    };

BatchStockInfo _$BatchStockInfoFromJson(Map<String, dynamic> json) =>
    BatchStockInfo(
      batch: ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
      remainingStock: (json['remaining_stock'] as num).toInt(),
      stockPercentage: (json['stock_percentage'] as num).toDouble(),
      isLowStock: json['is_low_stock'] as bool,
      isOutOfStock: json['is_out_of_stock'] as bool,
    );

Map<String, dynamic> _$BatchStockInfoToJson(BatchStockInfo instance) =>
    <String, dynamic>{
      'batch': instance.batch.toJson(),
      'remaining_stock': instance.remainingStock,
      'stock_percentage': instance.stockPercentage,
      'is_low_stock': instance.isLowStock,
      'is_out_of_stock': instance.isOutOfStock,
    };
