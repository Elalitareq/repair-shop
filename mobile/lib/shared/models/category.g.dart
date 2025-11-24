// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: (json['parent_id'] as num?)?.toInt(),
      parent: json['parent'] == null
          ? null
          : Category.fromJson(json['parent'] as Map<String, dynamic>),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'name': instance.name,
      'description': instance.description,
      'parent_id': instance.parentId,
      'parent': instance.parent,
      'children': instance.children,
    };
