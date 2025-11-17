import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Interceptor to handle authentication tokens
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final Logger _logger = Logger();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip auth for login endpoints
      if (_isAuthEndpoint(options.path)) {
        return handler.next(options);
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.d('Added auth token to request: ${options.path}');
      } else {
        _logger.w('No auth token found for request: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error in auth interceptor: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token expiration (401 Unauthorized)
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401, attempting token refresh');

      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final retryResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        _logger.e('Token refresh failed: $e');
      }

      // If refresh fails, clear tokens and let error propagate
      await _clearTokens();
    }

    handler.next(err);
  }

  /// Check if the endpoint is an auth endpoint (login/refresh)
  bool _isAuthEndpoint(String path) {
    const authPaths = ['/auth/login', '/auth/refresh'];
    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Attempt to refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null) {
        _logger.w('No refresh token available');
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        '${_getBaseUrl()}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newToken != null) {
          await prefs.setString(_tokenKey, newToken);

          if (newRefreshToken != null) {
            await prefs.setString(_refreshTokenKey, newRefreshToken);
          }

          _logger.i('Token refreshed successfully');
          return true;
        }
      }

      _logger.w('Token refresh failed: Invalid response');
      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }

  /// Retry the original request with the new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final prefs = await SharedPreferences.getInstance();
    final newToken = prefs.getString(_tokenKey);

    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    final dio = Dio();
    return await dio.fetch(requestOptions);
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    _logger.i('Auth tokens cleared');
  }

  /// Get base URL from environment or default
  String _getBaseUrl() {
    // This should match the base URL from your API client
    return 'http://localhost:8080/api';
  }

  /// Save authentication tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);

    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  /// Get current access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all authentication data
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
