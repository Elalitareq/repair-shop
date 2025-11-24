import '../../core/network/api_client.dart';
import '../models/models.dart';
import '../../core/network/api_response.dart';

class SaleService {
  final ApiClient _apiClient;

  SaleService(this._apiClient);

  // Get all sales with optional filters
  Future<ApiResponse<List<Sale>>> getSales({
    int? customerId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/sales/',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final sales = data.map((json) => Sale.fromJson(json)).toList();
      return ApiResponse.success(
        data: sales,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get sale by ID
  Future<ApiResponse<Sale>> getSale(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/sales/$id');

    if (response.isSuccess && response.data != null) {
      final sale = Sale.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: sale,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Create new sale
  Future<ApiResponse<Sale>> createSale({
    int? customerId,
    required List<Map<String, dynamic>> items,
    String? discountType,
    double? discountValue,
    double? taxRate,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      if (customerId != null) 'customer_id': customerId,
      'items': items,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (taxRate != null) 'tax_rate': taxRate,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/sales/',
      data: body,
    );

    if (response.isSuccess && response.data != null) {
      final sale = Sale.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: sale,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update sale
  Future<ApiResponse<Sale>> updateSale(
    int id, {
    String? notes,
    String? status,
  }) async {
    final body = <String, dynamic>{
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
    };

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/sales/$id',
      data: body,
    );

    if (response.isSuccess && response.data != null) {
      final sale = Sale.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: sale,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Delete sale
  Future<ApiResponse<void>> deleteSale(int id) async {
    final response = await _apiClient.delete('/sales/$id');

    if (response.isSuccess) {
      return ApiResponse.success(message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update sale status
  Future<ApiResponse<Sale>> updateSaleStatus(int id, String status) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/sales/$id/status',
      data: {'status': status},
    );

    if (response.isSuccess && response.data != null) {
      final sale = Sale.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: sale,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get daily sales report
  Future<ApiResponse<Map<String, dynamic>>> getDailyReport({
    DateTime? date,
  }) async {
    final queryParams = <String, dynamic>{
      if (date != null) 'date': date.toIso8601String().split('T')[0],
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/sales/reports/daily',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(
        data: response.data!['data'],
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get monthly sales report
  Future<ApiResponse<Map<String, dynamic>>> getMonthlyReport({
    int? year,
    int? month,
  }) async {
    final queryParams = <String, dynamic>{
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/sales/reports/monthly',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(
        data: response.data!['data'],
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Scan barcode for inventory lookup
  Future<ApiResponse<Map<String, dynamic>>> scanBarcode(String barcode) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/barcodes/scan',
      data: {'barcode': barcode},
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(
        data: response.data!['data'],
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}
