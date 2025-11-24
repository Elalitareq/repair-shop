import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'api_response.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  static const String _baseUrlKey = 'API_BASE_URL';
  static const String _timeoutKey = 'API_TIMEOUT';

  ApiClient() {
    _dio = Dio();
    _setupInterceptors();
    _configureOptions();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    ]);
  }

  void _configureOptions() {
    final baseUrl = dotenv.env[_baseUrlKey] ?? 'http://localhost:8080/api';
    final timeout = int.tryParse(dotenv.env[_timeoutKey] ?? '30000') ?? 30000;

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      sendTimeout: Duration(milliseconds: timeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      T? data;
      if (fromJson != null && response.data != null) {
        data = fromJson(response.data);
      } else {
        data = response.data;
      }

      return ApiResponse<T>.success(
        data: data,
        message: 'Request successful',
        statusCode: response.statusCode ?? 200,
      );
    } catch (e) {
      _logger.e('Error parsing response: $e');
      return ApiResponse<T>.error(
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  // Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      return _handleDioError<T>(error);
    }

    _logger.e('Unexpected error: $error');
    return ApiResponse<T>.error(
      message: 'An unexpected error occurred: ${error.toString()}',
      statusCode: 500,
    );
  }

  // Download raw bytes (for backups)
  Future<ApiResponse<Uint8List>> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? []);
      return ApiResponse<Uint8List>.success(
        data: bytes,
        message: 'Download successful',
        statusCode: response.statusCode ?? 200,
      );
    } catch (e) {
      return _handleError<Uint8List>(e);
    }
  }

  // Upload multipart form data
  Future<ApiResponse<T>> uploadMultipart<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse<T>.error(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          error: error,
        );

      case DioExceptionType.connectionError:
        return ApiResponse<T>.error(
          message: 'Connection failed. Please check your internet connection.',
          statusCode: 503,
          error: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        String message = 'Server error occurred';

        // Try to extract error message from response
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          message = data['message'] ?? data['error'] ?? message;
        }

        return ApiResponse<T>.error(
          message: message,
          statusCode: statusCode,
          error: error,
        );

      case DioExceptionType.cancel:
        return ApiResponse<T>.error(
          message: 'Request was cancelled',
          statusCode: 499,
          error: error,
        );

      default:
        return ApiResponse<T>.error(
          message: 'An error occurred: ${error.message}',
          statusCode: 500,
          error: error,
        );
    }
  }

  // Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Get current base URL
  String get baseUrl => _dio.options.baseUrl;
}

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
