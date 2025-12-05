import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer.dart';
import 'repair_item.dart';
import 'payment.dart';
import 'payment_allocation.dart';

part 'repair.g.dart';

@JsonSerializable()
class RepairState extends BaseModel {
  final String name;
  final String? description;
  final int order;

  const RepairState({
    required super.id,
    required this.name,
    this.description,
    required this.order,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory RepairState.fromJson(Map<String, dynamic> json) =>
      _$RepairStateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepairStateToJson(this);

  RepairState copyWith({
    int? id,
    String? name,
    String? description,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return RepairState(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

@JsonSerializable()
class RepairIssue extends BaseModel {
  final int repairId;
  final int issueTypeId;
  final String description;
  final bool resolved;

  const RepairIssue({
    required super.id,
    required this.repairId,
    required this.issueTypeId,
    required this.description,
    this.resolved = false,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory RepairIssue.fromJson(Map<String, dynamic> json) =>
      _$RepairIssueFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepairIssueToJson(this);

  RepairIssue copyWith({
    int? id,
    int? repairId,
    int? issueTypeId,
    String? description,
    bool? resolved,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return RepairIssue(
      id: id ?? this.id,
      repairId: repairId ?? this.repairId,
      issueTypeId: issueTypeId ?? this.issueTypeId,
      description: description ?? this.description,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

@JsonSerializable()
class Repair extends BaseModel {
  final String repairNumber;
  final int customerId;
  final Customer customer;
  final String deviceBrand;
  final String deviceModel;
  final String? deviceImei;
  final String? password;
  final String problemDescription;
  final String? diagnosisNotes;
  final String? repairNotes;
  final String priority;
  final double? estimatedCost;
  final double? finalCost;
  final double? serviceCharge;
  final DateTime? estimatedCompletion;
  final DateTime? actualCompletion;
  final bool warrantyProvided;
  final int? warrantyDays;
  final int stateId;
  final RepairState state;
  final String? extraInfo;
  final DateTime receivedDate;
  final DateTime? completedDate;
  final List<RepairIssue> issues;
  final List<RepairItem> items;
  final List<RepairStatusHistory> statusHistory;
  final String paymentStatus;
  final List<Payment> payments;
  final List<PaymentAllocation> paymentAllocations;

  const Repair({
    required super.id,
    required this.repairNumber,
    required this.customerId,
    required this.customer,
    required this.deviceBrand,
    required this.deviceModel,
    required this.problemDescription,
    this.deviceImei,
    this.password,
    this.diagnosisNotes,
    this.repairNotes,
    this.priority = 'normal',
    this.estimatedCost,
    this.finalCost,
    this.serviceCharge,
    this.estimatedCompletion,
    this.actualCompletion,
    this.warrantyProvided = false,
    this.warrantyDays,
    required this.stateId,
    required this.state,
    this.extraInfo,
    required this.receivedDate,
    this.completedDate,
    this.issues = const [],
    this.items = const [],
    this.statusHistory = const [],
    this.paymentStatus = 'pending',
    this.payments = const [],
    this.paymentAllocations = const [],
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory Repair.fromJson(Map<String, dynamic> json) => _$RepairFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepairToJson(this);

  Repair copyWith({
    String? repairNumber,
    int? customerId,
    Customer? customer,
    String? deviceBrand,
    String? deviceModel,
    String? deviceImei,
    String? password,
    String? problemDescription,
    String? diagnosisNotes,
    String? repairNotes,
    String? priority,
    double? estimatedCost,
    double? finalCost,
    double? serviceCharge,
    DateTime? estimatedCompletion,
    DateTime? actualCompletion,
    bool? warrantyProvided,
    int? warrantyDays,
    int? stateId,
    RepairState? state,
    String? extraInfo,
    DateTime? receivedDate,
    DateTime? completedDate,
    List<RepairIssue>? issues,
    List<RepairItem>? items,
    List<RepairStatusHistory>? statusHistory,
    String? paymentStatus,
    List<Payment>? payments,
    int? syncStatus,
  }) {
    return Repair(
      id: id,
      repairNumber: repairNumber ?? this.repairNumber,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceImei: deviceImei ?? this.deviceImei,
      password: password ?? this.password,
      problemDescription: problemDescription ?? this.problemDescription,
      diagnosisNotes: diagnosisNotes ?? this.diagnosisNotes,
      repairNotes: repairNotes ?? this.repairNotes,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      actualCompletion: actualCompletion ?? this.actualCompletion,
      warrantyProvided: warrantyProvided ?? this.warrantyProvided,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      stateId: stateId ?? this.stateId,
      state: state ?? this.state,
      extraInfo: extraInfo ?? this.extraInfo,
      receivedDate: receivedDate ?? this.receivedDate,
      completedDate: completedDate ?? this.completedDate,
      issues: issues ?? this.issues,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      payments: payments ?? this.payments,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  bool get isCompleted => completedDate != null;

  double get totalCost {
    double itemsCost = items.fold(0.0, (sum, item) => sum + (item.totalPrice));
    return (serviceCharge ?? 0.0) + itemsCost;
  }
}

@JsonSerializable()
class RepairStatusHistory extends BaseModel {
  final int? repairId;
  final String? status;
  final String? notes;
  final String? updatedBy;

  const RepairStatusHistory({
    required super.id,
    required this.repairId,
    required this.status,
    this.notes,
    required this.updatedBy,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory RepairStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$RepairStatusHistoryFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepairStatusHistoryToJson(this);

  RepairStatusHistory copyWith({
    int? id,
    int? repairId,
    String? status,
    String? notes,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return RepairStatusHistory(
      id: id ?? this.id,
      repairId: repairId ?? this.repairId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
