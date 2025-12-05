// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepairState _$RepairStateFromJson(Map<String, dynamic> json) => RepairState(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  order: (json['order'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RepairStateToJson(RepairState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'name': instance.name,
      'description': instance.description,
      'order': instance.order,
    };

RepairIssue _$RepairIssueFromJson(Map<String, dynamic> json) => RepairIssue(
  id: (json['id'] as num).toInt(),
  repairId: (json['repairId'] as num).toInt(),
  issueTypeId: (json['issueTypeId'] as num).toInt(),
  description: json['description'] as String,
  resolved: json['resolved'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RepairIssueToJson(RepairIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'repairId': instance.repairId,
      'issueTypeId': instance.issueTypeId,
      'description': instance.description,
      'resolved': instance.resolved,
    };

Repair _$RepairFromJson(Map<String, dynamic> json) => Repair(
  id: (json['id'] as num).toInt(),
  repairNumber: json['repairNumber'] as String,
  customerId: (json['customerId'] as num).toInt(),
  customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
  deviceBrand: json['deviceBrand'] as String,
  deviceModel: json['deviceModel'] as String,
  problemDescription: json['problemDescription'] as String,
  deviceImei: json['deviceImei'] as String?,
  password: json['password'] as String?,
  diagnosisNotes: json['diagnosisNotes'] as String?,
  repairNotes: json['repairNotes'] as String?,
  priority: json['priority'] as String? ?? 'normal',
  estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
  finalCost: (json['finalCost'] as num?)?.toDouble(),
  serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
  estimatedCompletion: json['estimatedCompletion'] == null
      ? null
      : DateTime.parse(json['estimatedCompletion'] as String),
  actualCompletion: json['actualCompletion'] == null
      ? null
      : DateTime.parse(json['actualCompletion'] as String),
  warrantyProvided: json['warrantyProvided'] as bool? ?? false,
  warrantyDays: (json['warrantyDays'] as num?)?.toInt(),
  stateId: (json['stateId'] as num).toInt(),
  state: RepairState.fromJson(json['state'] as Map<String, dynamic>),
  extraInfo: json['extraInfo'] as String?,
  receivedDate: DateTime.parse(json['receivedDate'] as String),
  completedDate: json['completedDate'] == null
      ? null
      : DateTime.parse(json['completedDate'] as String),
  issues:
      (json['issues'] as List<dynamic>?)
          ?.map((e) => RepairIssue.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RepairItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  statusHistory:
      (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => RepairStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  paymentStatus: json['paymentStatus'] as String? ?? 'pending',
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  paymentAllocations:
      (json['paymentAllocations'] as List<dynamic>?)
          ?.map((e) => PaymentAllocation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RepairToJson(Repair instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'repairNumber': instance.repairNumber,
  'customerId': instance.customerId,
  'customer': instance.customer,
  'deviceBrand': instance.deviceBrand,
  'deviceModel': instance.deviceModel,
  'deviceImei': instance.deviceImei,
  'password': instance.password,
  'problemDescription': instance.problemDescription,
  'diagnosisNotes': instance.diagnosisNotes,
  'repairNotes': instance.repairNotes,
  'priority': instance.priority,
  'estimatedCost': instance.estimatedCost,
  'finalCost': instance.finalCost,
  'serviceCharge': instance.serviceCharge,
  'estimatedCompletion': instance.estimatedCompletion?.toIso8601String(),
  'actualCompletion': instance.actualCompletion?.toIso8601String(),
  'warrantyProvided': instance.warrantyProvided,
  'warrantyDays': instance.warrantyDays,
  'stateId': instance.stateId,
  'state': instance.state,
  'extraInfo': instance.extraInfo,
  'receivedDate': instance.receivedDate.toIso8601String(),
  'completedDate': instance.completedDate?.toIso8601String(),
  'issues': instance.issues,
  'items': instance.items,
  'statusHistory': instance.statusHistory,
  'paymentStatus': instance.paymentStatus,
  'payments': instance.payments,
  'paymentAllocations': instance.paymentAllocations,
};

RepairStatusHistory _$RepairStatusHistoryFromJson(Map<String, dynamic> json) =>
    RepairStatusHistory(
      id: (json['id'] as num).toInt(),
      repairId: (json['repairId'] as num?)?.toInt(),
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: (json['syncStatus'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RepairStatusHistoryToJson(
  RepairStatusHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncStatus': instance.syncStatus,
  'repairId': instance.repairId,
  'status': instance.status,
  'notes': instance.notes,
  'updatedBy': instance.updatedBy,
};
