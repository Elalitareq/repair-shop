import 'package:json_annotation/json_annotation.dart';
import 'item_batch.dart';

part 'repair_item_batch.g.dart';

@JsonSerializable()
class RepairItemBatch {
  final int id;
  final int repairItemId;
  final int batchId;
  final double quantity;
  final DateTime createdAt;
  final ItemBatch? batch;

  const RepairItemBatch({
    required this.id,
    required this.repairItemId,
    required this.batchId,
    required this.quantity,
    required this.createdAt,
    this.batch,
  });

  factory RepairItemBatch.fromJson(Map<String, dynamic> json) =>
      _$RepairItemBatchFromJson(json);

  Map<String, dynamic> toJson() => _$RepairItemBatchToJson(this);
}
