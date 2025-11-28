import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/customer.dart';

/// Service for managing customers and dealers
class CustomerService {
  final ApiClient _apiClient;

  CustomerService(this._apiClient);

  /// Get all customers with optional filtering
  Future<ApiResponse<List<Customer>>> getCustomers({
    String? search,
    String? type, // dealer, customer
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final customers = data
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: customers,
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

  /// Get customer by ID
  Future<ApiResponse<Customer>> getCustomer(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$id',
    );

    if (response.isSuccess && response.data != null) {
      final customer = Customer.fromJson(response.data!['data']);

      return ApiResponse.success(
        data: customer,
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

  /// Create new customer
  Future<ApiResponse<Customer>> createCustomer({
    required String name,
    String? companyName,
    required String type,
    required String phone,
    String? address,
    String? taxNumber,
    String? locationLink,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/customers',
      data: {
        'name': name,
        'companyName': companyName,
        'type': type,
        'phone': phone,
        'address': address,
        'taxNumber': taxNumber,
        'locationLink': locationLink,
      },
    );

    if (response.isSuccess && response.data != null) {
      final customer = Customer.fromJson(response.data!['data']);

      return ApiResponse.success(
        data: customer,
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

  /// Update existing customer
  Future<ApiResponse<Customer>> updateCustomer({
    required int id,
    String? name,
    String? companyName,
    String? type,
    String? phone,
    String? address,
    String? taxNumber,
    String? locationLink,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (companyName != null) data['companyName'] = companyName;
    if (type != null) data['type'] = type;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (taxNumber != null) data['taxNumber'] = taxNumber;
    if (locationLink != null) data['locationLink'] = locationLink;

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/customers/$id',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final customer = Customer.fromJson(response.data!['data']);

      return ApiResponse.success(
        data: customer,
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

  /// Delete customer
  Future<ApiResponse<void>> deleteCustomer(int id) async {
    final response = await _apiClient.delete<void>('/customers/$id');

    if (response.isSuccess) {
      return ApiResponse<void>.success(
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

  /// Search customers
  Future<ApiResponse<List<Customer>>> searchCustomers(String query) async {
    return getCustomers(search: query);
  }

  /// Get dealers only
  Future<ApiResponse<List<Customer>>> getDealers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    return getCustomers(
      search: search,
      type: 'dealer',
      page: page,
      limit: limit,
    );
  }

  /// Get customers only (not dealers)
  Future<ApiResponse<List<Customer>>> getRegularCustomers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    return getCustomers(
      search: search,
      type: 'customer',
      page: page,
      limit: limit,
    );
  }
}

/// Provider for CustomerService
final customerServiceProvider = Provider<CustomerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerService(apiClient);
});
