// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      companyName: json['company_name'] as String?,
      type: json['type'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String?,
      taxNumber: json['tax_number'] as String?,
      locationLink: json['location_link'] as String?,
    );

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'name': instance.name,
      'company_name': instance.companyName,
      'type': instance.type,
      'phone_number': instance.phoneNumber,
      'address': instance.address,
      'tax_number': instance.taxNumber,
      'location_link': instance.locationLink,
    };
