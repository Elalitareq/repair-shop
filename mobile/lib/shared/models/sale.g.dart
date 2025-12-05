// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  saleNumber: json['saleNumber'] as String?,
  customerId: (json['customerId'] as num?)?.toInt(),
  customer: json['customer'] == null
      ? null
      : Customer.fromJson(json['customer'] as Map<String, dynamic>),
  status: json['status'] as String? ?? 'draft',
  paymentStatus: json['paymentStatus'] as String? ?? 'pending',
  subtotal: (json['subtotal'] as num).toDouble(),
  discountType: json['discountType'] as String?,
  discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
  taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  cogs: (json['cogs'] as num?)?.toDouble() ?? 0.0,
  profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
  saleItems: (json['items'] as List<dynamic>?)
      ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentAllocations:
      (json['paymentAllocations'] as List<dynamic>?)
          ?.map((e) => PaymentAllocation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'saleNumber': instance.saleNumber,
  'customerId': instance.customerId,
  'customer': instance.customer,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'subtotal': instance.subtotal,
  'discountType': instance.discountType,
  'discountValue': instance.discountValue,
  'discountAmount': instance.discountAmount,
  'taxRate': instance.taxRate,
  'taxAmount': instance.taxAmount,
  'totalAmount': instance.totalAmount,
  'cogs': instance.cogs,
  'profit': instance.profit,
  'items': instance.saleItems,
  'payments': instance.payments,
  'paymentAllocations': instance.paymentAllocations,
  'notes': instance.notes,
};
