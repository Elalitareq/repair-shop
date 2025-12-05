// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  email: json['email'] as String?,
  companyName: json['companyName'] as String?,
  type: json['type'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String?,
  taxNumber: json['taxNumber'] as String?,
  locationLink: json['locationLink'] as String?,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'name': instance.name,
  'email': instance.email,
  'companyName': instance.companyName,
  'type': instance.type,
  'phone': instance.phone,
  'address': instance.address,
  'taxNumber': instance.taxNumber,
  'locationLink': instance.locationLink,
};
