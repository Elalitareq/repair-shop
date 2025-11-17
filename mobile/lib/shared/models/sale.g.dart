// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      saleNumber: json['sale_number'] as String,
      customerId: (json['customer_id'] as num?)?.toInt(),
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'draft',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      totalAmount: (json['total_amount'] as num).toDouble(),
      saleItems: (json['sale_items'] as List<dynamic>?)
          ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'sale_number': instance.saleNumber,
      'customer_id': instance.customerId,
      'customer': instance.customer,
      'status': instance.status,
      'payment_status': instance.paymentStatus,
      'total_amount': instance.totalAmount,
      'sale_items': instance.saleItems,
      'payments': instance.payments,
      'notes': instance.notes,
    };
