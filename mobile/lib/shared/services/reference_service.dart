import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/models.dart';

class ReferenceService {
  final ApiClient _apiClient;

  ReferenceService(this._apiClient);

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
}

final referenceServiceProvider = Provider<ReferenceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReferenceService(apiClient);
});
