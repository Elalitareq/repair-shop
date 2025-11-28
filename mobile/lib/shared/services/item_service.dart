import '../../core/network/api_client.dart';
import '../models/models.dart';
import '../../core/network/api_response.dart';

class ItemService {
  final ApiClient _apiClient;

  ItemService(this._apiClient);

  // Get all items with optional filters
  Future<ApiResponse<List<Item>>> getItems({
    int? categoryId,
    int? batchId,
    bool? lowStock,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (batchId != null) 'batchId': batchId,
      if (lowStock != null) 'low_stock': lowStock,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/items/',
      queryParameters: queryParams,
    );

    if (response.isSuccess && response.data != null) {
      print({"response": response.data});
      final data = response.data!['data'] as List<dynamic>;
      //    required super.id,
      // required super.createdAt,
      // required super.updatedAt,
      // required this.name,
      // required this.categoryId,
      // required this.category,
      // required this.brand,
      // required this.model,
      // this.description,
      // required this.conditionId,
      // required this.condition,
      // required this.qualityId,
      // required this.quality,
      // this.itemType = 'other',
      // this.stockQuantity = 0,
      // this.minStockLevel = 5,
      // this.sellingPrice,
      // this.barcodes,

      print({"dataId": data[0]["id"]});
      print({"dataName": data[0]["name"]});
      print({"dataBrand": data[0]["brand"]});
      print({"dataModel": data[0]["model"]});
      print({"dataDescription": data[0]["description"]});
      print({"dataItemType": data[0]["itemType"]}); // 'phone' or 'other'
      print({"dataCategoryId": data[0]["categoryId"]});
      print({"dataConditionId": data[0]["conditionId"]});
      print({"dataQualityId": data[0]["qualityId"]});
      print({"dataStockQuantity": data[0]["stockQuantity"]});
      print({"dataMinStockLevel": data[0]["minStockLevel"]});
      print({"dataSellingPrice": data[0]["sellingPrice"]});
      print({"dataBarcodes": data[0]["barcodes"]});
      print({"dataCreatedAt": data[0]["createdAt"]});
      print({"dataUpdatedAt": data[0]["updatedAt"]});
      print({"dataCategory": data[0]["category"]});
      print({"dataCondition": data[0]["condition"]});
      print({"dataQuality": data[0]["quality"]});

      try {
        final items = data.map((json) => Item.fromJson(json)).toList();

        print({"items": items});
        return ApiResponse.success(
          data: items,
          message: response.data!['message'] ?? response.message,
        );
      } catch (e) {
        print({"parsing_error": e.toString()});
        throw e;
      }
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get item by ID
  Future<ApiResponse<Item>> getItem(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/items/$id');

    if (response.isSuccess && response.data != null) {
      print({"response": response.data});
      final item = Item.fromJson(response.data!['data']);
      print({"item2": item});
      return ApiResponse.success(
        data: item,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Create new item
  Future<ApiResponse<Item>> createItem(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/items/',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final item = Item.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: item,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update item
  Future<ApiResponse<Item>> updateItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/items/$id',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final item = Item.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: item,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Delete item
  Future<ApiResponse<void>> deleteItem(int id) async {
    final response = await _apiClient.delete('/items/$id');

    if (response.isSuccess) {
      return ApiResponse.success(data: null, message: response.message);
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Search items
  Future<ApiResponse<List<Item>>> searchItems(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/items/search',
      queryParameters: {'q': query},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final items = data.map((json) => Item.fromJson(json)).toList();
      return ApiResponse.success(
        data: items,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get low stock items
  Future<ApiResponse<List<Item>>> getLowStockItems({int threshold = 10}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/items/low-stock',
      queryParameters: {'threshold': threshold},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final items = data.map((json) => Item.fromJson(json)).toList();
      return ApiResponse.success(
        data: items,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Adjust stock quantity
  Future<ApiResponse<Item>> adjustStock({
    required int itemId,
    required int quantity,
    String? reason,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/stock/adjust',
      data: {
        'itemId': itemId,
        'quantity': quantity,
        if (reason != null) 'reason': reason,
      },
    );

    if (response.isSuccess && response.data != null) {
      final item = Item.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: item,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get all batches
  Future<ApiResponse<List<BatchStockInfo>>> getBatches({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/batches/',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final batches = data
          .map((json) => BatchStockInfo.fromJson(json))
          .toList();
      return ApiResponse.success(
        data: batches,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get batch by ID
  Future<ApiResponse<BatchStockInfo>> getBatch(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/batches/$id');

    if (response.isSuccess && response.data != null) {
      final batch = BatchStockInfo.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: batch,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Create batch
  Future<ApiResponse<BatchStockInfo>> createBatch(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/batches/',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final batch = BatchStockInfo.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: batch,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update batch
  Future<ApiResponse<BatchStockInfo>> updateBatch(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/batches/$id',
      data: data,
    );

    if (response.isSuccess && response.data != null) {
      final batch = BatchStockInfo.fromJson(response.data!['data']);
      return ApiResponse.success(
        data: batch,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Delete batch
  Future<ApiResponse<void>> deleteBatch(int id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/batches/$id',
    );

    if (response.isSuccess) {
      return ApiResponse.success(
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get low stock batches
  Future<ApiResponse<List<BatchStockInfo>>> getLowStockBatches() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/batches/low-stock',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final batches = data
          .map((json) => BatchStockInfo.fromJson(json))
          .toList();
      return ApiResponse.success(
        data: batches,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get out of stock batches
  Future<ApiResponse<List<BatchStockInfo>>> getOutOfStockBatches() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/batches/out-of-stock',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final batches = data
          .map((json) => BatchStockInfo.fromJson(json))
          .toList();
      return ApiResponse.success(
        data: batches,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get batches for item
  Future<ApiResponse<List<BatchStockInfo>>> getBatchesForItem(
    int itemId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/batches/item/$itemId',
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>;
      final batches = data
          .map((json) => BatchStockInfo.fromJson(json))
          .toList();
      return ApiResponse.success(
        data: batches,
        message: response.data!['message'] ?? response.message,
      );
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}
