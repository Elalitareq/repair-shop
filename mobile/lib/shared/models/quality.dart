import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'quality.g.dart';

@JsonSerializable()
class Quality extends BaseModel {
  final String name;
  final String? description;

  Quality({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.description,
  });

  factory Quality.fromJson(Map<String, dynamic> json) =>
      _$QualityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QualityToJson(this);
}
