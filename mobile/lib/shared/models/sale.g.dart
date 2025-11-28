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
  totalAmount: (json['totalAmount'] as num).toDouble(),
  saleItems: (json['items'] as List<dynamic>?)
      ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
      .toList(),
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
  'totalAmount': instance.totalAmount,
  'items': instance.saleItems,
  'payments': instance.payments,
  'notes': instance.notes,
};
