import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'payment.dart';

part 'payment_allocation.g.dart';

@JsonSerializable()
class PaymentAllocation extends BaseModel {
  final int paymentId;
  final int? saleId;
  final int? repairId;
  final double amount;
  final Payment? payment;

  const PaymentAllocation({
    required super.id,
    required this.paymentId,
    this.saleId,
    this.repairId,
    required this.amount,
    this.payment,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) =>
      _$PaymentAllocationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentAllocationToJson(this);
}
