// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssueType _$IssueTypeFromJson(Map<String, dynamic> json) => IssueType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$IssueTypeToJson(IssueType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
};
