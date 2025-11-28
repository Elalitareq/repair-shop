import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'payment_method.g.dart';

/// PaymentMethod represents available payment methods
@JsonSerializable()
class PaymentMethod extends BaseModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'feeRate')
  final double feeRate;

  @JsonKey(name: 'description')
  final String? description;

  const PaymentMethod({
    required super.id,
    required this.name,
    this.description,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    this.feeRate = 0.0,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  /// Calculate fee for a given amount
  double calculateFee(double amount) {
    return amount * (feeRate / 100);
  }

  /// Get total amount including fee
  double getTotalWithFee(double amount) {
    return amount + calculateFee(amount);
  }

  @override
  String toString() {
    return 'PaymentMethod{id: $id, name: $name}';
  }
}
