import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'condition.g.dart';

@JsonSerializable()
class Condition extends BaseModel {
  final String name;
  final String? description;

  Condition({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.description,
  });

  factory Condition.fromJson(Map<String, dynamic> json) =>
      _$ConditionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConditionToJson(this);
}
