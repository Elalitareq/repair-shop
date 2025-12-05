import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/models.dart';
import 'repair_service.dart'; // Import IssueType

class ReferenceService {
  final ApiClient _apiClient;

  ReferenceService(this._apiClient);

  // Conditions
  Future<ApiResponse<List<Condition>>> getConditions() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reference/conditions',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final conditions = data.map((json) => Condition.fromJson(json)).toList();
      return ApiResponse.success(
        data: conditions,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Condition>> createCondition({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reference/conditions',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final condition = Condition.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: condition,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Condition>> updateCondition({
    required int id,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/reference/conditions/$id',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final condition = Condition.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: condition,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteCondition(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reference/conditions/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(
        data: null,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Qualities
  Future<ApiResponse<List<Quality>>> getQualities() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reference/qualities',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final qualities = data.map((json) => Quality.fromJson(json)).toList();
      return ApiResponse.success(
        data: qualities,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reference/payment-methods',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final methods = <PaymentMethod>[];
      for (final json in data) {
        try {
          final method = PaymentMethod.fromJson(json as Map<String, dynamic>);
          methods.add(method);
        } catch (e) {
          // Log and skip problematic entries
        
          continue;
        }
      }
      return ApiResponse.success(
        data: methods,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Issue Types
  Future<ApiResponse<List<IssueType>>> getIssueTypes() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reference/issue-types',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final issueTypes = data.map((json) => IssueType.fromJson(json)).toList();
      return ApiResponse.success(
        data: issueTypes,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<IssueType>> createIssueType({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reference/issue-types',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final issueType = IssueType.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: issueType,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<IssueType>> updateIssueType({
    required int id,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/reference/issue-types/$id',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final issueType = IssueType.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: issueType,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteIssueType(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reference/issue-types/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(
        data: null,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Repair States
  Future<ApiResponse<List<RepairState>>> getRepairStates() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/reference/repair-states',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final states = data
          .map((json) => RepairState.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(
        data: states,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<RepairState>> createRepairState({
    required String name,
    String? description,
    int? order,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reference/repair-states',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
      },
    );

    if (response.isSuccess && response.data != null) {
      final state = RepairState.fromJson(response.data!['data']);
      return ApiResponse.success(data: state, message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<RepairState>> updateRepairState({
    required int id,
    required String name,
    String? description,
    int? order,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/reference/repair-states/$id',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (order != null) 'order': order,
      },
    );

    if (response.isSuccess && response.data != null) {
      final state = RepairState.fromJson(response.data!['data']);
      return ApiResponse.success(data: state, message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteRepairState(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reference/repair-states/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(data: null, message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<PaymentMethod>> createPaymentMethod({
    required String name,
    double? feeRate,
    String? description,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reference/payment-methods',
      data: {
        'name': name,
        if (feeRate != null) 'feeRate': feeRate,
        if (description != null) 'description': description,
      },
    );

    if (response.isSuccess && response.data != null) {
      final method = PaymentMethod.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: method,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<PaymentMethod>> updatePaymentMethod({
    required int id,
    required String name,
    double? feeRate,
    String? description,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/reference/payment-methods/$id',
      data: {
        'name': name,
        if (feeRate != null) 'feeRate': feeRate,
        if (description != null) 'description': description,
      },
    );

    if (response.isSuccess && response.data != null) {
      final method = PaymentMethod.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: method,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deletePaymentMethod(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reference/payment-methods/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(data: null, message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Quality>> createQuality({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/reference/qualities',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final quality = Quality.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: quality,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Quality>> updateQuality({
    required int id,
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/reference/qualities/$id',
      data: {'name': name, if (description != null) 'description': description},
    );

    if (response.isSuccess && response.data != null) {
      final quality = Quality.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: quality,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteQuality(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/reference/qualities/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(
        data: null,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}

final referenceServiceProvider = Provider<ReferenceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReferenceService(apiClient);
});
