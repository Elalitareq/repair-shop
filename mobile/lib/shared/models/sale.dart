import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer.dart';
import 'sale_item.dart';
import 'payment.dart';
import 'payment_allocation.dart';

part 'sale.g.dart';

/// Sale represents sales transactions
@JsonSerializable()
class Sale extends BaseModel {
  @JsonKey(name: 'saleNumber')
  final String? saleNumber;

  @JsonKey(name: 'customerId')
  final int? customerId;

  @JsonKey(name: 'customer')
  final Customer? customer;

  @JsonKey(name: 'status')
  final String status; // draft, confirmed, paid, cancelled, refunded

  @JsonKey(name: 'paymentStatus')
  final String paymentStatus; // pending, partial, paid

  @JsonKey(name: 'subtotal')
  final double subtotal;

  @JsonKey(name: 'discountType')
  final String? discountType;

  @JsonKey(name: 'discountValue')
  final double discountValue;

  @JsonKey(name: 'discountAmount')
  final double discountAmount;

  @JsonKey(name: 'taxRate')
  final double taxRate;

  @JsonKey(name: 'taxAmount')
  final double taxAmount;

  @JsonKey(name: 'totalAmount')
  final double totalAmount;

  @JsonKey(name: 'cogs')
  final double cogs;

  @JsonKey(name: 'profit')
  final double profit;

  @JsonKey(name: 'items')
  final List<SaleItem>? saleItems;

  @JsonKey(name: 'payments')
  final List<Payment>? payments;

  @JsonKey(name: 'paymentAllocations')
  final List<PaymentAllocation> paymentAllocations;

  @JsonKey(name: 'notes')
  final String? notes;

  const Sale({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    this.saleNumber,
    this.customerId,
    this.customer,
    this.status = 'draft',
    this.paymentStatus = 'pending',
    required this.subtotal,
    this.discountType,
    this.discountValue = 0.0,
    this.discountAmount = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.cogs = 0.0,
    this.profit = 0.0,
    this.saleItems,
    this.payments,
    this.paymentAllocations = const [],
    this.notes,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  /// Check if sale is editable
  bool get isEditable => status == 'draft';

  /// Check if sale is completed
  bool get isCompleted => status == 'confirmed' && paymentStatus == 'paid';

  /// Check if sale is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get total paid amount
  double get totalPaid {
    if (payments == null) return 0.0;
    return payments!.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get remaining balance
  double get remainingBalance {
    final remaining = totalAmount - totalPaid;
    return remaining < 0 ? 0 : remaining;
  }

  /// Check if fully paid
  bool get isFullyPaid =>
      remainingBalance <= 0.01; // Allow for small floating point errors

  /// Get total item count
  double get totalItems {
    if (saleItems == null) return 0;
    return saleItems!.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get status color for UI
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'orange';
      case 'confirmed':
        return isFullyPaid ? 'green' : 'blue';
      case 'cancelled':
        return 'red';
      case 'refunded':
        return 'purple';
      default:
        return 'grey';
    }
  }

  /// Get display status text
  String getDisplayStatus() {
    if (status == 'confirmed' && paymentStatus == 'paid') {
      return 'Completed';
    }
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  @override
  String toString() {
    return 'Sale{id: $id, saleNumber: ${saleNumber ?? 'N/A'}, status: $status, total: $totalAmount}';
  }
}
