import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/batch.dart';
import '../services/batch_service.dart';

final batchServiceProvider = Provider<BatchService>((ref) {
  return BatchService(ApiClient());
});

final batchesProvider = FutureProvider.autoDispose<List<Batch>>((ref) async {
  final service = ref.read(batchServiceProvider);
  return service.getBatches();
});

final batchesForItemProvider = FutureProvider.autoDispose
    .family<List<Batch>, int>((ref, itemId) async {
      final service = ref.read(batchServiceProvider);
      return service.getBatchesForItem(itemId);
    });

class BatchNotifier extends StateNotifier<AsyncValue<Batch?>> {
  final BatchService _batchService;

  BatchNotifier(this._batchService) : super(const AsyncValue.data(null));

  Future<bool> createBatch(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final batch = await _batchService.createBatch(data);
      state = AsyncValue.data(batch);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateBatch(int id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final batch = await _batchService.updateBatch(id, data);
      state = AsyncValue.data(batch);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteBatch(int id) async {
    state = const AsyncValue.loading();
    try {
      await _batchService.deleteBatch(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> loadBatch(int id) async {
    state = const AsyncValue.loading();
    try {
      final batch = await _batchService.getBatchById(id);
      state = AsyncValue.data(batch);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final batchNotifierProvider =
    StateNotifierProvider<BatchNotifier, AsyncValue<Batch?>>((ref) {
      final service = ref.read(batchServiceProvider);
      return BatchNotifier(service);
    });
