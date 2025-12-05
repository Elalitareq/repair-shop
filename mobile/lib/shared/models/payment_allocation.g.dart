// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_allocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAllocation _$PaymentAllocationFromJson(Map<String, dynamic> json) =>
    PaymentAllocation(
      id: (json['id'] as num).toInt(),
      paymentId: (json['paymentId'] as num).toInt(),
      saleId: (json['saleId'] as num?)?.toInt(),
      repairId: (json['repairId'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      payment: json['payment'] == null
          ? null
          : Payment.fromJson(json['payment'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PaymentAllocationToJson(PaymentAllocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'paymentId': instance.paymentId,
      'saleId': instance.saleId,
      'repairId': instance.repairId,
      'amount': instance.amount,
      'payment': instance.payment,
    };
