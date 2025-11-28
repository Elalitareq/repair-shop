// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quality _$QualityFromJson(Map<String, dynamic> json) => Quality(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$QualityToJson(Quality instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'name': instance.name,
  'description': instance.description,
};
