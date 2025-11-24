import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'item_batch.dart';

part 'serial.g.dart';

@JsonSerializable()
class Serial extends BaseModel {
  final String imei;

  @JsonKey(name: 'item_id')
  final int itemId;

  @JsonKey(name: 'batch_id')
  final int batchId;

  @JsonKey(name: 'batch')
  final ItemBatch? batch;

  final String status;

  const Serial({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.imei,
    required this.itemId,
    required this.batchId,
    this.batch,
    this.status = 'available',
  });

  factory Serial.fromJson(Map<String, dynamic> json) => _$SerialFromJson(json);

  Map<String, dynamic> toJson() => _$SerialToJson(this);
}
