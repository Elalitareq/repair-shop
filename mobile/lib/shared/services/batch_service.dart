import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/batch.dart';

class BatchService {
  final ApiClient _apiClient;

  BatchService(this._apiClient);

  Future<List<Batch>> getBatches({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiClient.get(
        '/batches',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        // Handle nested batch object if it exists
        final batchData = json['batch'] ?? json;
        return Batch.fromJson(batchData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load batches: $e');
    }
  }

  Future<Batch> getBatchById(int id) async {
    try {
      final response = await _apiClient.get('/batches/$id');
      final batchData = response.data['data']['batch'] ?? response.data['data'];
      return Batch.fromJson(batchData);
    } catch (e) {
      throw Exception('Failed to load batch: $e');
    }
  }

  Future<Batch> createBatch(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/batches', data: data);
      final batchData = response.data['data']['batch'] ?? response.data['data'];
      return Batch.fromJson(batchData);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to create batch');
      }
      throw Exception('Failed to create batch: $e');
    }
  }

  Future<Batch> updateBatch(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/batches/$id', data: data);
      final batchData = response.data['data']['batch'] ?? response.data['data'];
      return Batch.fromJson(batchData);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to update batch');
      }
      throw Exception('Failed to update batch: $e');
    }
  }

  Future<void> deleteBatch(int id, {int? itemId}) async {
    try {
      final queryParams = itemId != null ? {'itemId': itemId} : null;
      await _apiClient.delete('/batches/$id', queryParameters: queryParams);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to delete batch');
      }
      throw Exception('Failed to delete batch: $e');
    }
  }

  Future<List<Batch>> getBatchesForItem(int itemId) async {
    try {
      final response = await _apiClient.get('/batches/item/$itemId');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) {
        final batchData = json['batch'] ?? json;
        return Batch.fromJson(batchData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load batches for item: $e');
    }
  }
}

// Provider for BatchService
final batchServiceProvider = Provider<BatchService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BatchService(apiClient);
});
