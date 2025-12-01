import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user.dart';
import '../../shared/services/auth_service.dart';

/// Authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _checkAuthenticationStatus();
  }

  /// Check if user is already authenticated on app start
  Future<void> _checkAuthenticationStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        // Get current user data
        final userResponse = await _authService.getCurrentUser();

        if (userResponse.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: userResponse.data,
            error: null,
          );
        } else {
          // Token might be expired, logout
          await _authService.logout();
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
            user: null,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  /// Login with username/email and password
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: response.data!.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      // Even if logout fails, clear local state
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final response = await _authService.getCurrentUser();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(user: response.data);
      }
    } catch (e) {
      // Don't update state on refresh error
    }
  }
}

/// Provider for auth notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
