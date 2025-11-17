import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'customer.dart';
import 'repair_item.dart';

part 'repair.g.dart';

enum RepairStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('waiting_parts')
  waitingParts,
  @JsonValue('completed')
  completed,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

enum RepairPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

@JsonSerializable()
class Repair extends BaseModel {
  final String ticketNumber;
  final int customerId;
  final Customer? customer;
  final String deviceType;
  final String deviceModel;
  final String deviceSerial;
  final String problemDescription;
  final String? diagnosisNotes;
  final String? repairNotes;
  final RepairStatus status;
  final RepairPriority priority;
  final double estimatedCost;
  final double? finalCost;
  final DateTime? estimatedCompletion;
  final DateTime? actualCompletion;
  final DateTime? deliveredAt;
  final bool warrantyProvided;
  final int? warrantyDays;
  final List<RepairItem>? items;
  final List<RepairStatusHistory>? statusHistory;

  const Repair({
    required super.id,
    required this.ticketNumber,
    required this.customerId,
    this.customer,
    required this.deviceType,
    required this.deviceModel,
    this.deviceSerial = '',
    required this.problemDescription,
    this.diagnosisNotes,
    this.repairNotes,
    this.status = RepairStatus.pending,
    this.priority = RepairPriority.normal,
    this.estimatedCost = 0.0,
    this.finalCost,
    this.estimatedCompletion,
    this.actualCompletion,
    this.deliveredAt,
    this.warrantyProvided = false,
    this.warrantyDays,
    this.items,
    this.statusHistory,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
  });

  factory Repair.fromJson(Map<String, dynamic> json) => _$RepairFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepairToJson(this);

  Repair copyWith({
    int? id,
    String? ticketNumber,
    int? customerId,
    Customer? customer,
    String? deviceType,
    String? deviceModel,
    String? deviceSerial,
    String? problemDescription,
    String? diagnosisNotes,
    String? repairNotes,
    RepairStatus? status,
    RepairPriority? priority,
    double? estimatedCost,
    double? finalCost,
    DateTime? estimatedCompletion,
    DateTime? actualCompletion,
    DateTime? deliveredAt,
    bool? warrantyProvided,
    int? warrantyDays,
    List<RepairItem>? items,
    List<RepairStatusHistory>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
  }) {
    return Repair(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerId: customerId ?? this.customerId,
      customer: customer ?? this.customer,
      deviceType: deviceType ?? this.deviceType,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      problemDescription: problemDescription ?? this.problemDescription,
      diagnosisNotes: diagnosisNotes ?? this.diagnosisNotes,
      repairNotes: repairNotes ?? this.repairNotes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      actualCompletion: actualCompletion ?? this.actualCompletion,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      warrantyProvided: warrantyProvided ?? this.warrantyProvided,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      items: items ?? this.items,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case RepairStatus.pending:
        return 'Pending';
      case RepairStatus.inProgress:
        return 'In Progress';
      case RepairStatus.waitingParts:
        return 'Waiting for Parts';
      case RepairStatus.completed:
        return 'Completed';
      case RepairStatus.delivered:
        return 'Delivered';
      case RepairStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case RepairPriority.low:
        return 'Low';
      case RepairPriority.normal:
        return 'Normal';
      case RepairPriority.high:
        return 'High';
      case RepairPriority.urgent:
        return 'Urgent';
    }
  }

  bool get isCompleted =>
      status == RepairStatus.completed || status == RepairStatus.delivered;

  bool get canBeEdited =>
      status != RepairStatus.delivered && status != RepairStatus.cancelled;

  double get totalCost => finalCost ?? estimatedCost;
}

@JsonSerializable()
class RepairStatusHistory extends BaseModel {
  final int repairId;
  final RepairStatus status;
  final String? notes;
  final String updatedBy;

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
    RepairStatus? status,
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
