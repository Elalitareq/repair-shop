// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemBatch _$ItemBatchFromJson(Map<String, dynamic> json) => ItemBatch(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  serials: (json['serials'] as List<dynamic>?)
      ?.map((e) => Serial.fromJson(e as Map<String, dynamic>))
      .toList(),
  batchNumber: json['batchNumber'] as String,
  supplierId: (json['supplierId'] as num).toInt(),
  supplier: json['supplier'] == null
      ? null
      : Customer.fromJson(json['supplier'] as Map<String, dynamic>),
  purchaseDate: DateTime.parse(json['purchaseDate'] as String),
  totalQuantity: (json['totalQuantity'] as num).toInt(),
  soldQuantity: (json['soldQuantity'] as num?)?.toInt() ?? 0,
  totalCost: (json['totalCost'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ItemBatchToJson(ItemBatch instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'batchNumber': instance.batchNumber,
  'supplierId': instance.supplierId,
  'supplier': instance.supplier,
  'purchaseDate': instance.purchaseDate.toIso8601String(),
  'totalQuantity': instance.totalQuantity,
  'serials': instance.serials,
  'soldQuantity': instance.soldQuantity,
  'totalCost': instance.totalCost,
  'notes': instance.notes,
};

BatchStockInfo _$BatchStockInfoFromJson(Map<String, dynamic> json) =>
    BatchStockInfo(
      batch: ItemBatch.fromJson(json['batch'] as Map<String, dynamic>),
      remainingStock: (json['remainingStock'] as num).toInt(),
      stockPercentage: (json['stockPercentage'] as num).toDouble(),
      isLowStock: json['isLowStock'] as bool,
      isOutOfStock: json['isOutOfStock'] as bool,
    );

Map<String, dynamic> _$BatchStockInfoToJson(BatchStockInfo instance) =>
    <String, dynamic>{
      'batch': instance.batch.toJson(),
      'remainingStock': instance.remainingStock,
      'stockPercentage': instance.stockPercentage,
      'isLowStock': instance.isLowStock,
      'isOutOfStock': instance.isOutOfStock,
    };
