// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  username: json['username'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'user',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'username': instance.username,
  'email': instance.email,
  'role': instance.role,
  'isActive': instance.isActive,
};
