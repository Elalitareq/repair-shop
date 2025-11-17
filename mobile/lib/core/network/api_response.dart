/// Generic API response wrapper class
class ApiResponse<T> {
  final T? data;
  final String message;
  final bool isSuccess;
  final int statusCode;
  final dynamic error;

  const ApiResponse._({
    required this.isSuccess,
    required this.message,
    required this.statusCode,
    this.data,
    this.error,
  });

  /// Create a successful response
  factory ApiResponse.success({
    T? data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create an error response
  factory ApiResponse.error({
    required String message,
    int statusCode = 500,
    dynamic error,
  }) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  /// Check if response is successful
  bool get isError => !isSuccess;

  /// Get data with null safety
  T? get dataOrNull => data;

  /// Get data or throw exception
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw ApiException(message, statusCode, error);
  }

  @override
  String toString() {
    return 'ApiResponse{isSuccess: $isSuccess, message: $message, statusCode: $statusCode, data: $data}';
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic originalError;

  const ApiException(this.message, this.statusCode, [this.originalError]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
