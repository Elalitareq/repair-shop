import 'package:flutter_test/flutter_test.dart';
import 'package:repair_shop_mobile/shared/services/item_service.dart';
import 'package:repair_shop_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:repair_shop_mobile/core/network/api_response.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient() : super();

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    // Return a Map<String, dynamic> structure for T == Map<String, dynamic>
    if (T == Map<String, dynamic>) {
      final data = <String, dynamic>{'data': <dynamic>[]};
      return ApiResponse<T>.success(data: data as T, message: 'OK');
    }

    return ApiResponse<T>.error(message: 'Unexpected type');
  }
}

void main() {
  test('getItems returns empty list when API returns no items', () async {
    final fakeApi = FakeApiClient();
    final service = ItemService(fakeApi);

    final response = await service.getItems();

    expect(response.isSuccess, true);
    expect(response.data, isEmpty);
  });
}
