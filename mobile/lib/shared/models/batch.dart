import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'batch.g.dart';

@JsonSerializable(explicitToJson: true)
class Batch extends BaseModel {
  @JsonKey(name: 'batchNumber')
  final String batchNumber;
  @JsonKey(name: 'supplierId')
  final int supplierId;
  @JsonKey(name: 'purchaseDate')
  final String purchaseDate;
  @JsonKey(name: 'totalQuantity')
  final int totalQuantity;
  @JsonKey(name: 'soldQuantity')
  final int soldQuantity;
  @JsonKey(name: 'unitCost')
  final double unitCost;
  @JsonKey(name: 'totalCost')
  final double totalCost;
  final String? notes;

  Batch({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.batchNumber,
    required this.supplierId,
    required this.purchaseDate,
    required this.totalQuantity,
    this.soldQuantity = 0,
    required this.unitCost,
    required this.totalCost,
    this.notes,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BatchToJson(this);

  Batch copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? batchNumber,
    int? supplierId,
    String? purchaseDate,
    int? totalQuantity,
    int? soldQuantity,
    double? unitCost,
    double? totalCost,
    String? notes,
  }) {
    return Batch(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      supplierId: supplierId ?? this.supplierId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
    );
  }
}
