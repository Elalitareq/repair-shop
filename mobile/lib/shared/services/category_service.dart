import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/models.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<ApiResponse<List<Category>>> getCategories({
    bool forceRefresh = false,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final categories = data.map((json) => Category.fromJson(json)).toList();
      return ApiResponse.success(
        data: categories,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Category>> getCategory(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/categories/$id',
    );

    if (response.isSuccess && response.data != null) {
      final category = Category.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: category,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
    int? parentId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/categories',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
      },
    );

    if (response.isSuccess && response.data != null) {
      final category = Category.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: category,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<Category>> updateCategory({
    required int id,
    required String name,
    String? description,
    int? parentId,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/categories/$id',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
      },
    );

    if (response.isSuccess && response.data != null) {
      final category = Category.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: category,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteCategory(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/categories/$id',
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

// Provider for CategoryService

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CategoryService(apiClient);
});
