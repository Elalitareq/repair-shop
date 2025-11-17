// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      saleId: (json['sale_id'] as num).toInt(),
      paymentMethod: json['payment_method'] as String,
      amount: (json['amount'] as num).toDouble(),
      referenceNumber: json['reference_number'] as String?,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      status: json['status'] as String? ?? 'pending',
      processedById: (json['processed_by_id'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'sale_id': instance.saleId,
      'payment_method': instance.paymentMethod,
      'amount': instance.amount,
      'reference_number': instance.referenceNumber,
      'payment_date': instance.paymentDate.toIso8601String(),
      'status': instance.status,
      'processed_by_id': instance.processedById,
      'notes': instance.notes,
    };
