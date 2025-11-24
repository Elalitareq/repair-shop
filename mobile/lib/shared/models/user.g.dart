// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'is_active': instance.isActive,
    };
