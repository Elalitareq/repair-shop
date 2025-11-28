import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repair_shop_mobile/core/router/app_router.dart';
import 'package:repair_shop_mobile/shared/providers/auth_provider.dart';
import 'package:repair_shop_mobile/shared/services/auth_service.dart';
import 'package:repair_shop_mobile/shared/models/user.dart';
import 'package:repair_shop_mobile/core/network/api_response.dart';

class FakeAuthService implements AuthService {
  @override
  Future<ApiResponse<AuthResponse>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    return ApiResponse.error(message: 'Not implemented');
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    return ApiResponse.error(message: 'Not implemented');
  }

  @override
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    return ApiResponse.error(message: 'Not implemented');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isAuthenticated() async {
    return Future.value(false);
  }

  @override
  Future<String?> getAccessToken() async {
    return Future.value(null);
  }
}

void main() {
  test('route names are unique', () {
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(FakeAuthService())],
    );

    final router = container.read(appRouterProvider);

    final names = <String>{};
    final duplicates = <String>[];

    void collect(GoRoute route) {
      final name = route.name;
      if (name != null) {
        if (!names.add(name)) duplicates.add(name);
      }
      for (final child in route.routes) {
        collect(child);
      }
    }

    for (final r in router.routes) {
      collect(r);
    }

    expect(
      duplicates,
      isEmpty,
      reason: 'Found duplicate route names: $duplicates',
    );
  });
}
