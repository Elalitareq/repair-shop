// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  saleId: (json['saleId'] as num).toInt(),
  paymentMethod: json['paymentMethod'] == null
      ? null
      : PaymentMethod.fromJson(json['paymentMethod'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
  referenceNumber: json['referenceNumber'] as String?,
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  status: json['status'] as String? ?? 'pending',
  processedById: (json['processedById'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'saleId': instance.saleId,
  'paymentMethod': instance.paymentMethod,
  'amount': instance.amount,
  'referenceNumber': instance.referenceNumber,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'status': instance.status,
  'processedById': instance.processedById,
  'notes': instance.notes,
};
