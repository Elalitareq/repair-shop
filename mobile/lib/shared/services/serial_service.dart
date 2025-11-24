import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/serial.dart';

class SerialService {
  final ApiClient _apiClient;
  SerialService(this._apiClient);

  Future<ApiResponse<List<Serial>>> getSerials({
    int? itemId,
    int? batchId,
  }) async {
    final params = <String, dynamic>{};
    if (itemId != null) params['itemId'] = itemId;
    if (batchId != null) params['batchId'] = batchId;

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/serials',
      queryParameters: params,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final serials = data.map((json) => Serial.fromJson(json)).toList();
      return ApiResponse.success(
        data: serials,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Serial>> createSerial(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/serials',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final serial = Serial.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: serial,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteSerial(int id) async {
    final response = await _apiClient.delete<void>("/serials/$id");
    return response;
  }
}

// Provider for SerialService
final serialServiceProvider = Provider<SerialService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SerialService(apiClient);
});
