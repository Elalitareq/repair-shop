import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'payment.g.dart';

/// Payment represents payment transactions
@JsonSerializable()
class Payment extends BaseModel {
  @JsonKey(name: 'sale_id')
  final int saleId;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'reference_number')
  final String? referenceNumber;

  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;

  @JsonKey(name: 'status')
  final String status; // pending, completed, failed, refunded

  @JsonKey(name: 'processed_by_id')
  final int? processedById;

  @JsonKey(name: 'notes')
  final String? notes;

  const Payment({
    required super.id,
    super.createdAt,
    super.updatedAt,
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
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'mixed':
        return 'Mixed';
      default:
        return paymentMethod;
    }
  }

  @override
  String toString() {
    return 'Payment{id: $id, saleId: $saleId, method: $paymentMethod, amount: $amount, status: $status}';
  }
}
