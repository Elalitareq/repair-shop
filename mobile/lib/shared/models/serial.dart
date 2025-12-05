import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'item_batch.dart';

part 'serial.g.dart';

@JsonSerializable()
class Serial extends BaseModel {
  final String imei;

  @JsonKey(name: 'itemId')
  final int itemId;

  @JsonKey(name: 'batchId')
  final int batchId;

  @JsonKey(name: 'batch')
  final ItemBatch? batch;

  final String status;
  final int? saleItemId;
  final int? repairItemId;

  const Serial({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.imei,
    required this.itemId,
    required this.batchId,
    this.batch,
    this.status = 'available',
    this.saleItemId,
    this.repairItemId,
  });

  factory Serial.fromJson(Map<String, dynamic> json) => _$SerialFromJson(json);

  Map<String, dynamic> toJson() => _$SerialToJson(this);
}
