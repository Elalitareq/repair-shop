import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor to handle and log API errors
class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    handler.next(err);
  }

  void _logError(DioException error) {
    final statusCode = error.response?.statusCode;
    final method = error.requestOptions.method;
    final path = error.requestOptions.path;
    final baseUrl = error.requestOptions.baseUrl;
    final fullUrl = '$baseUrl$path';

    _logger.e(
      'API Error: $method $fullUrl\n'
      'Status Code: $statusCode\n'
      'Error Type: ${error.type}\n'
      'Error Message: ${error.message}\n'
      'Response Data: ${error.response?.data}\n'
      'Request Headers: ${error.requestOptions.headers}\n'
      'Request Data: ${error.requestOptions.data}',
    );

    // Log specific error types for better debugging
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        _logger.w('Connection timeout for: $fullUrl');
        break;
      case DioExceptionType.sendTimeout:
        _logger.w('Send timeout for: $fullUrl');
        break;
      case DioExceptionType.receiveTimeout:
        _logger.w('Receive timeout for: $fullUrl');
        break;
      case DioExceptionType.badResponse:
        _logger.e('Bad response [$statusCode] for: $fullUrl');
        _logResponseDetails(error.response);
        break;
      case DioExceptionType.cancel:
        _logger.i('Request cancelled for: $fullUrl');
        break;
      case DioExceptionType.connectionError:
        _logger.e('Connection error for: $fullUrl - ${error.message}');
        break;
      case DioExceptionType.badCertificate:
        _logger.e('Bad certificate for: $fullUrl');
        break;
      case DioExceptionType.unknown:
        _logger.e('Unknown error for: $fullUrl - ${error.message}');
        break;
    }
  }

  void _logResponseDetails(Response? response) {
    if (response == null) return;

    _logger.e(
      'Response Details:\n'
      'Status Code: ${response.statusCode}\n'
      'Status Message: ${response.statusMessage}\n'
      'Headers: ${response.headers}\n'
      'Data: ${response.data}',
    );

    // Try to extract meaningful error messages
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final errorMessage = data['error'] ?? data['message'] ?? data['detail'];
      if (errorMessage != null) {
        _logger.e('Server Error Message: $errorMessage');
      }

      // Log validation errors if present
      final validationErrors = data['validation_errors'] ?? data['errors'];
      if (validationErrors != null) {
        _logger.e('Validation Errors: $validationErrors');
      }
    }
  }
}
