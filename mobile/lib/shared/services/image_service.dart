
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';

class ImageService {
  final ApiClient _apiClient;

  ImageService(this._apiClient);

  /// Upload an image and attach to an item
  Future<ApiResponse<Map<String, dynamic>>> uploadItemImage({
    required int itemId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/items/$itemId/images',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    return response;
  }
}

final imageServiceProvider = Provider<ImageService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageService(apiClient);
});