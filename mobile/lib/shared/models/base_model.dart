import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

/// Base model with common fields
@JsonSerializable()
class BaseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'sync_status')
  final int syncStatus;

  const BaseModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 0,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BaseModel{id: $id, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus}';
  }
}
