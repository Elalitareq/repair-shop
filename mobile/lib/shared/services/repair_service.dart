import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/repair.dart';
import '../models/repair_item.dart';

/// Service for managing repairs
class RepairService {
  final ApiClient _apiClient;

  RepairService(this._apiClient);

  /// Get all repairs with optional filtering
  Future<ApiResponse<List<Repair>>> getRepairs({
    String? search,
    String? status,
    String? priority,
    int? customerId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (status != null) {
      queryParams['status'] = status;
    }

    if (priority != null) {
      queryParams['priority'] = priority;
    }

    if (customerId != null) {
      queryParams['customerId'] = customerId;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/repairs',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      final dataList = response.data!['data'];
      if (dataList == null) {
        return ApiResponse.success(
          data: <Repair>[],
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final data = dataList as List<dynamic>;
      print(data);
      final repairs = data
          .map((json) => Repair.fromJson(json as Map<String, dynamic>))
          .toList();
      print(repairs);

      return ApiResponse.success(
        data: repairs,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Get repair by ID
  Future<ApiResponse<Repair>> getRepair(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/repairs/$id');

    if (response.isSuccess && response.data != null) {
      final repairData = response.data!['data'];
      if (repairData == null) {
        return ApiResponse.error(
          message: 'Repair not found',
          statusCode: response.statusCode,
        );
      }

      final repair = Repair.fromJson(repairData as Map<String, dynamic>);

      return ApiResponse.success(
        data: repair,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Create new repair
  Future<ApiResponse<Repair>> createRepair({
    required int customerId,
    required String deviceBrand,
    required String deviceModel,
    String? deviceImei,
    required String problemDescription,
    String? diagnosisNotes,
    String priority = 'Normal',
    double estimatedCost = 0.0,
    DateTime? estimatedCompletion,
    bool warrantyProvided = false,
    int? warrantyDays,
    List<RepairItem>? items,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/repairs',
      data: {
        'customerId': customerId,
        'deviceBrand': deviceBrand,
        'deviceModel': deviceModel,
        'deviceImei': deviceImei,
        'problemDescription': problemDescription,
        'diagnosisNotes': diagnosisNotes,
        'priority': priority,
        'estimatedCost': estimatedCost,
        'estimatedCompletion': estimatedCompletion?.toIso8601String(),
        'warrantyProvided': warrantyProvided,
        'warrantyDays': warrantyDays,
        'items': items?.map((item) => item.toJson()).toList(),
      },
    );

    if (response.isSuccess && response.data != null) {
      final repairData = response.data!['data'];
      if (repairData == null) {
        return ApiResponse.error(
          message: 'Failed to create repair',
          statusCode: response.statusCode,
        );
      }

      final repair = Repair.fromJson(repairData as Map<String, dynamic>);

      return ApiResponse.success(
        data: repair,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Update existing repair
  Future<ApiResponse<Repair>> updateRepair({
    required int id,
    int? customerId,
    String? deviceBrand,
    String? deviceModel,
    String? deviceImei,
    String? problemDescription,
    String? diagnosisNotes,
    String? repairNotes,
    String? status,
    String? priority,
    double? estimatedCost,
    double? finalCost,
    DateTime? estimatedCompletion,
    DateTime? actualCompletion,
    bool? warrantyProvided,
    int? warrantyDays,
    List<RepairItem>? items,
  }) async {
    final data = <String, dynamic>{};

    if (customerId != null) data['customerId'] = customerId;
    if (deviceBrand != null) data['deviceBrand'] = deviceBrand;
    if (deviceModel != null) data['deviceModel'] = deviceModel;
    if (deviceImei != null) data['deviceImei'] = deviceImei;
    if (problemDescription != null) {
      data['problemDescription'] = problemDescription;
    }
    if (diagnosisNotes != null) data['diagnosisNotes'] = diagnosisNotes;
    if (repairNotes != null) data['repairNotes'] = repairNotes;
    if (status != null) data['status'] = status;
    if (priority != null) data['priority'] = priority;
    if (estimatedCost != null) data['estimatedCost'] = estimatedCost;
    if (finalCost != null) data['finalCost'] = finalCost;
    if (estimatedCompletion != null) {
      data['estimatedCompletion'] = estimatedCompletion.toIso8601String();
    }
    if (actualCompletion != null) {
      data['actualCompletion'] = actualCompletion.toIso8601String();
    }
    if (warrantyProvided != null) data['warrantyProvided'] = warrantyProvided;
    if (warrantyDays != null) data['warrantyDays'] = warrantyDays;
    if (items != null) {
      data['items'] = items.map((item) => item.toJson()).toList();
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/repairs/$id',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final repairData = response.data!['data'];
      if (repairData == null) {
        return ApiResponse.error(
          message: 'Failed to update repair',
          statusCode: response.statusCode,
        );
      }

      final repair = Repair.fromJson(repairData as Map<String, dynamic>);

      return ApiResponse.success(
        data: repair,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Update repair status
  Future<ApiResponse<Repair>> updateRepairStatus({
    required int id,
    required String status,
    String? notes,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/repairs/$id/status',
      data: {'status': status, 'notes': notes},
    );

    if (response.isSuccess && response.data != null) {
      final repairData = response.data!['data'];
      if (repairData == null) {
        return ApiResponse.error(
          message: 'Failed to update repair status',
          statusCode: response.statusCode,
        );
      }

      final repair = Repair.fromJson(repairData as Map<String, dynamic>);

      return ApiResponse.success(
        data: repair,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Mark repair as delivered
  Future<ApiResponse<Repair>> markAsDelivered({
    required int id,
    String? notes,
  }) async {
    return updateRepairStatus(id: id, status: 'Delivered', notes: notes);
  }

  /// Cancel repair
  Future<ApiResponse<Repair>> cancelRepair({
    required int id,
    required String reason,
  }) async {
    return updateRepairStatus(id: id, status: 'Cancelled', notes: reason);
  }

  /// Delete repair
  Future<ApiResponse<void>> deleteRepair(int id) async {
    final response = await _apiClient.delete<void>('/repairs/$id');

    if (response.isSuccess) {
      return ApiResponse<void>.success(
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Search repairs
  Future<ApiResponse<List<Repair>>> searchRepairs(String query) async {
    return getRepairs(search: query);
  }

  /// Get pending repairs
  Future<ApiResponse<List<Repair>>> getPendingRepairs({
    int page = 1,
    int limit = 20,
  }) async {
    return getRepairs(status: 'Received', page: page, limit: limit);
  }

  /// Get in-progress repairs
  Future<ApiResponse<List<Repair>>> getInProgressRepairs({
    int page = 1,
    int limit = 20,
  }) async {
    return getRepairs(status: 'In Progress', page: page, limit: limit);
  }

  /// Get completed repairs
  Future<ApiResponse<List<Repair>>> getCompletedRepairs({
    int page = 1,
    int limit = 20,
  }) async {
    return getRepairs(status: 'Completed', page: page, limit: limit);
  }

  /// Get overdue repairs (past estimated completion date)
  Future<ApiResponse<List<Repair>>> getOverdueRepairs({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'overdue': true,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/repairs',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      final dataList = response.data!['data'];
      if (dataList == null) {
        return ApiResponse.success(
          data: <Repair>[],
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      final data = dataList as List<dynamic>;
      final repairs = data
          .map((json) => Repair.fromJson(json as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: repairs,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Get repair statistics
  Future<ApiResponse<Map<String, dynamic>>> getRepairStats() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/repairs/stats',
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(
        data: response.data!['data'],
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Add item to repair
  Future<ApiResponse<RepairItem>> addRepairItem({
    required int repairId,
    required String itemName,
    String? description,
    required double quantity,
    required double unitPrice,
    bool isLabor = false,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/repairs/$repairId/items',
      data: {
        'item_name': itemName,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': quantity * unitPrice,
        'is_labor': isLabor,
      },
    );

    if (response.isSuccess && response.data != null) {
      final itemData = response.data!['data'];
      if (itemData == null) {
        return ApiResponse.error(
          message: 'Failed to add repair item',
          statusCode: response.statusCode,
        );
      }

      final item = RepairItem.fromJson(itemData as Map<String, dynamic>);

      return ApiResponse.success(
        data: item,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Update repair item
  Future<ApiResponse<RepairItem>> updateRepairItem({
    required int repairId,
    required int itemId,
    String? itemName,
    String? description,
    double? quantity,
    double? unitPrice,
    bool? isLabor,
  }) async {
    final data = <String, dynamic>{};

    if (itemName != null) data['item_name'] = itemName;
    if (description != null) data['description'] = description;
    if (quantity != null) data['quantity'] = quantity;
    if (unitPrice != null) data['unit_price'] = unitPrice;
    if (isLabor != null) data['is_labor'] = isLabor;

    // Calculate total price if quantity or unit price changed
    if (quantity != null || unitPrice != null) {
      // We need the current values to calculate the new total
      final itemResponse = await _apiClient.get<Map<String, dynamic>>(
        '/repairs/$repairId/items/$itemId',
      );
      if (itemResponse.isSuccess && itemResponse.data != null) {
        final currentItemData = itemResponse.data!['data'];
        if (currentItemData != null) {
          final currentItem = RepairItem.fromJson(
            currentItemData as Map<String, dynamic>,
          );
          final newQuantity = quantity ?? currentItem.quantity ?? 0.0;
          final newUnitPrice = unitPrice ?? currentItem.unitPrice ?? 0.0;
          data['total_price'] = newQuantity * newUnitPrice;
        }
      }
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/repairs/$repairId/items/$itemId',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final itemData = response.data!['data'];
      if (itemData == null) {
        return ApiResponse.error(
          message: 'Failed to update repair item',
          statusCode: response.statusCode,
        );
      }

      final item = RepairItem.fromJson(itemData as Map<String, dynamic>);

      return ApiResponse.success(
        data: item,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  /// Delete repair item
  Future<ApiResponse<void>> deleteRepairItem({
    required int repairId,
    required int itemId,
  }) async {
    final response = await _apiClient.delete<void>(
      '/repairs/$repairId/items/$itemId',
    );

    if (response.isSuccess) {
      return ApiResponse<void>.success(
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }
}

/// Provider for RepairService
final repairServiceProvider = Provider<RepairService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RepairService(apiClient);
});
