// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  description: json['description'] as String?,
  parentId: (json['parentId'] as num?)?.toInt(),
  parent: json['parent'] == null
      ? null
      : Category.fromJson(json['parent'] as Map<String, dynamic>),
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'name': instance.name,
  'description': instance.description,
  'parentId': instance.parentId,
  'parent': instance.parent,
  'children': instance.children,
};
