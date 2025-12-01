import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import '../services/serial_service.dart';
// Serial service provider is added for IMEI management
import '../services/category_service.dart';
import '../services/reference_service.dart';
import '../../core/network/api_client.dart';

// Item Service Provider
final itemServiceProvider = Provider<ItemService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ItemService(apiClient);
});

// Item List Provider
class ItemListState {
  final List<Item> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const ItemListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ItemListState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ItemListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ItemListNotifier extends StateNotifier<ItemListState> {
  final ItemService _itemService;

  ItemListNotifier(this._itemService) : super(const ItemListState());

  Future<void> loadItems({
    int? categoryId,
    int? conditionId,
    int? qualityId,
    int? batchId,
    bool? lowStock,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const ItemListState();
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getItems(
        categoryId: categoryId,
        conditionId: conditionId,
        qualityId: qualityId,
        batchId: batchId,
        lowStock: lowStock,
        page: refresh ? 1 : state.currentPage,
        limit: 50,
      );

      if (response.isSuccess && response.data != null) {
        final newItems = refresh
            ? response.data!
            : [...state.items, ...response.data!];
        state = state.copyWith(
          items: newItems,
          isLoading: false,
          hasMore: response.data!.length >= 50,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      await loadItems(refresh: true);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.searchItems(query);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          items: response.data!,
          isLoading: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final itemListProvider = StateNotifierProvider<ItemListNotifier, ItemListState>(
  (ref) {
    final itemService = ref.watch(itemServiceProvider);
    return ItemListNotifier(itemService);
  },
);

// Item Detail Provider
class ItemDetailState {
  final Item? item;
  final bool isLoading;
  final String? error;

  const ItemDetailState({this.item, this.isLoading = false, this.error});

  ItemDetailState copyWith({Item? item, bool? isLoading, String? error}) {
    return ItemDetailState(
      item: item ?? this.item,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ItemDetailNotifier extends StateNotifier<ItemDetailState> {
  final ItemService _itemService;

  ItemDetailNotifier(this._itemService) : super(const ItemDetailState());

  Future<void> loadItem(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getItem(id);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(item: response.data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createItem(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.createItem(data);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(item: response.data, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateItem(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.updateItem(id, data);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(item: response.data, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.deleteItem(id);

      if (response.isSuccess) {
        state = state.copyWith(item: null, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> adjustStock({
    required int itemId,
    required int quantity,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.adjustStock(
        itemId: itemId,
        quantity: quantity,
        reason: reason,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(item: response.data, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final itemDetailProvider =
    StateNotifierProvider<ItemDetailNotifier, ItemDetailState>((ref) {
      final itemService = ref.watch(itemServiceProvider);
      return ItemDetailNotifier(itemService);
    });

// Provider for serials per item
// SerialService is provided by `serial_service.dart` — don't re-declare it here.

final serialsForItemProvider = FutureProvider.family<List<Serial>, int>((
  ref,
  itemId,
) async {
  final service = ref.watch(serialServiceProvider);
  final resp = await service.getSerials(itemId: itemId);
  return resp.dataOrThrow;
});

// Provider for fetching batches for a specific item
final batchesForItemProvider =
    FutureProvider.family<List<BatchStockInfo>, int>((ref, itemId) async {
  final service = ref.watch(itemServiceProvider);
  final resp = await service.getBatchesForItem(itemId);
  return resp.dataOrThrow;
});

// Provider for fetching batches (simple list for selection)
final batchesProvider = FutureProvider<List<BatchStockInfo>>((ref) async {
  final service = ref.watch(itemServiceProvider);
  final resp = await service.getBatches(page: 1, limit: 50);
  return resp.dataOrThrow;
});

// Batch List Provider
class BatchListState {
  final List<BatchStockInfo> batches;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const BatchListState({
    this.batches = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  BatchListState copyWith({
    List<BatchStockInfo>? batches,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return BatchListState(
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class BatchListNotifier extends StateNotifier<BatchListState> {
  final ItemService _itemService;

  BatchListNotifier(this._itemService) : super(const BatchListState());

  Future<void> loadBatches({bool refresh = false}) async {
    if (refresh) {
      state = const BatchListState();
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getBatches(
        page: refresh ? 1 : state.currentPage,
        limit: 50,
      );

      if (response.isSuccess && response.data != null) {
        final newBatches = refresh
            ? response.data!
            : [...state.batches, ...response.data!];
        state = state.copyWith(
          batches: newBatches,
          isLoading: false,
          hasMore: response.data!.length >= 50,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadLowStockBatches() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getLowStockBatches();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          batches: response.data!,
          isLoading: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadOutOfStockBatches() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getOutOfStockBatches();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          batches: response.data!,
          isLoading: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadBatchesForItem(int itemId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getBatchesForItem(itemId);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          batches: response.data!,
          isLoading: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final batchListProvider =
    StateNotifierProvider<BatchListNotifier, BatchListState>((ref) {
      final itemService = ref.watch(itemServiceProvider);
      return BatchListNotifier(itemService);
    });

// Batch Detail Provider
class BatchDetailState {
  final BatchStockInfo? batch;
  final bool isLoading;
  final String? error;

  const BatchDetailState({this.batch, this.isLoading = false, this.error});

  BatchDetailState copyWith({
    BatchStockInfo? batch,
    bool? isLoading,
    String? error,
  }) {
    return BatchDetailState(
      batch: batch ?? this.batch,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BatchDetailNotifier extends StateNotifier<BatchDetailState> {
  final ItemService _itemService;

  BatchDetailNotifier(this._itemService) : super(const BatchDetailState());

  Future<void> loadBatch(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.getBatch(id);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(batch: response.data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createBatch(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.createBatch(data);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(batch: response.data, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateBatch(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.updateBatch(id, data);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(batch: response.data, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteBatch(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _itemService.deleteBatch(id);

      if (response.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final batchDetailProvider =
    StateNotifierProvider<BatchDetailNotifier, BatchDetailState>((ref) {
      final itemService = ref.watch(itemServiceProvider);
      return BatchDetailNotifier(itemService);
    });

// Low stock items provider
final lowStockItemsProvider = FutureProvider<List<Item>>((ref) async {
  final itemService = ref.watch(itemServiceProvider);
  final response = await itemService.getLowStockItems();

  return response.dataOrThrow;
});

// Categories Provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  final response = await categoryService.getCategories();
  return response.dataOrThrow;
});

// Conditions Provider
final conditionsProvider = FutureProvider<List<Condition>>((ref) async {
  final refService = ref.watch(referenceServiceProvider);
  final response = await refService.getConditions();
  return response.dataOrThrow;
});

// Qualities Provider
final qualitiesProvider = FutureProvider<List<Quality>>((ref) async {
  final refService = ref.watch(referenceServiceProvider);
  final response = await refService.getQualities();
  return response.dataOrThrow;
});

// Repair states provider
final repairStatesProvider = FutureProvider<List<RepairState>>((ref) async {
  final refService = ref.watch(referenceServiceProvider);
  final response = await refService.getRepairStates();
  return response.dataOrThrow;
});

// Payment Methods Provider
final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final refService = ref.watch(referenceServiceProvider);
  final response = await refService.getPaymentMethods();
  return response.dataOrThrow;
});

// Suppliers Provider (Customers with type 'dealer')
final suppliersProvider = FutureProvider<List<Customer>>((ref) async {
  // This would typically come from a customer service
  // For now, return empty list - will be implemented when customer service is created
  return [];
});
