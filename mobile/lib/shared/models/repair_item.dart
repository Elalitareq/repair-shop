import 'package:json_annotation/json_annotation.dart';
import 'repair_item_batch.dart';

part 'repair_item.g.dart';

@JsonSerializable()
class RepairItem {
  final int id;
  final int repairId;
  final String itemName;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final bool isLabor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? itemId;
  @JsonKey(name: 'repairItemBatches')
  final List<RepairItemBatch>? batches;

  const RepairItem({
    required this.id,
    required this.repairId,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.isLabor,
    required this.createdAt,
    required this.updatedAt,
    this.itemId,
    this.batches,
  });

  factory RepairItem.fromJson(Map<String, dynamic> json) =>
      _$RepairItemFromJson(json);

  Map<String, dynamic> toJson() => _$RepairItemToJson(this);

  RepairItem copyWith({
    int? id,
    int? repairId,
    String? itemName,
    String? description,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    bool? isLabor,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return RepairItem(
      id: id ?? this.id,
      repairId: repairId ?? this.repairId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      isLabor: isLabor ?? this.isLabor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
