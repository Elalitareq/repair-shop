// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repair _$RepairFromJson(Map<String, dynamic> json) => Repair(
      id: (json['id'] as num).toInt(),
      ticketNumber: json['ticketNumber'] as String,
      customerId: (json['customerId'] as num).toInt(),
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      deviceType: json['deviceType'] as String,
      deviceModel: json['deviceModel'] as String,
      deviceSerial: json['deviceSerial'] as String? ?? '',
      problemDescription: json['problemDescription'] as String,
      diagnosisNotes: json['diagnosisNotes'] as String?,
      repairNotes: json['repairNotes'] as String?,
      status: $enumDecodeNullable(_$RepairStatusEnumMap, json['status']) ??
          RepairStatus.pending,
      priority:
          $enumDecodeNullable(_$RepairPriorityEnumMap, json['priority']) ??
              RepairPriority.normal,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      finalCost: (json['finalCost'] as num?)?.toDouble(),
      estimatedCompletion: json['estimatedCompletion'] == null
          ? null
          : DateTime.parse(json['estimatedCompletion'] as String),
      actualCompletion: json['actualCompletion'] == null
          ? null
          : DateTime.parse(json['actualCompletion'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      warrantyProvided: json['warrantyProvided'] as bool? ?? false,
      warrantyDays: (json['warrantyDays'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => RepairItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => RepairStatusHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RepairToJson(Repair instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'ticketNumber': instance.ticketNumber,
      'customerId': instance.customerId,
      'customer': instance.customer,
      'deviceType': instance.deviceType,
      'deviceModel': instance.deviceModel,
      'deviceSerial': instance.deviceSerial,
      'problemDescription': instance.problemDescription,
      'diagnosisNotes': instance.diagnosisNotes,
      'repairNotes': instance.repairNotes,
      'status': _$RepairStatusEnumMap[instance.status]!,
      'priority': _$RepairPriorityEnumMap[instance.priority]!,
      'estimatedCost': instance.estimatedCost,
      'finalCost': instance.finalCost,
      'estimatedCompletion': instance.estimatedCompletion?.toIso8601String(),
      'actualCompletion': instance.actualCompletion?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'warrantyProvided': instance.warrantyProvided,
      'warrantyDays': instance.warrantyDays,
      'items': instance.items,
      'statusHistory': instance.statusHistory,
    };

const _$RepairStatusEnumMap = {
  RepairStatus.pending: 'pending',
  RepairStatus.inProgress: 'in_progress',
  RepairStatus.waitingParts: 'waiting_parts',
  RepairStatus.completed: 'completed',
  RepairStatus.delivered: 'delivered',
  RepairStatus.cancelled: 'cancelled',
};

const _$RepairPriorityEnumMap = {
  RepairPriority.low: 'low',
  RepairPriority.normal: 'normal',
  RepairPriority.high: 'high',
  RepairPriority.urgent: 'urgent',
};

RepairStatusHistory _$RepairStatusHistoryFromJson(Map<String, dynamic> json) =>
    RepairStatusHistory(
      id: (json['id'] as num).toInt(),
      repairId: (json['repairId'] as num).toInt(),
      status: $enumDecode(_$RepairStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      updatedBy: json['updatedBy'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RepairStatusHistoryToJson(
        RepairStatusHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
      'repairId': instance.repairId,
      'status': _$RepairStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'updatedBy': instance.updatedBy,
    };
