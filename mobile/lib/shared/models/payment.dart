import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'payment_method.dart';

part 'payment.g.dart';

/// Payment represents payment transactions
@JsonSerializable()
class Payment extends BaseModel {
  @JsonKey(name: 'saleId')
  final int saleId;

  @JsonKey(name: 'paymentMethod')
  final PaymentMethod? paymentMethod;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'referenceNumber')
  final String? referenceNumber;

  @JsonKey(name: 'paymentDate')
  final DateTime paymentDate;

  @JsonKey(name: 'status')
  final String status; // pending, completed, failed, refunded

  @JsonKey(name: 'processedById')
  final int? processedById;

  @JsonKey(name: 'notes')
  final String? notes;

  const Payment({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.saleId,
    required this.paymentMethod,
    required this.amount,
    this.referenceNumber,
    required this.paymentDate,
    this.status = 'pending',
    this.processedById,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  /// Check if payment is completed
  bool get isCompleted => status == 'completed';

  /// Check if payment is pending
  bool get isPending => status == 'pending';

  /// Check if payment failed
  bool get isFailed => status == 'failed';

  /// Check if payment is refunded
  bool get isRefunded => status == 'refunded';

  /// Get payment method display name
  String get paymentMethodDisplay => paymentMethod?.name ?? 'Unknown Method';

  @override
  String toString() {
    return 'Payment{id: $id, saleId: $saleId, method: ${paymentMethod?.name ?? 'Unknown'}, amount: $amount, status: $status}';
  }
}
