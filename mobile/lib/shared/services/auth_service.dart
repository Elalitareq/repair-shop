import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/network/auth_interceptor.dart';
import '../models/user.dart';

/// Authentication service for handling login and token management
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login user with username/email and password
  Future<ApiResponse<AuthResponse>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username_or_email': usernameOrEmail, 'password': password},
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);

      // Save tokens
      await AuthInterceptor.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return ApiResponse.success(
        data: authResponse,
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

  /// Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');

    if (response.isSuccess && response.data != null) {
      final user = User.fromJson(response.data!);

      return ApiResponse.success(
        data: user,
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

  /// Refresh access token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/refresh',
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);

      // Save new tokens
      await AuthInterceptor.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return ApiResponse.success(
        data: authResponse,
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

  /// Logout user (clear tokens)
  Future<void> logout() async {
    await AuthInterceptor.clearAuth();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await AuthInterceptor.isAuthenticated();
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await AuthInterceptor.getAccessToken();
  }
}

/// Authentication response model
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final DateTime expiresAt;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken:
          json['token'] as String, // Server returns 'token', not 'access_token'
      refreshToken: json['refresh_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.now().add(
        const Duration(hours: 24),
      ), // Default expiry since server doesn't send it
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});
