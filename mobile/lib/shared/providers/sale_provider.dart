import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/sale_service.dart';
import '../../core/network/api_client.dart';

// Sale Service Provider
final saleServiceProvider = Provider<SaleService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SaleService(apiClient);
});

// Sale List Provider
class SaleListState {
  final List<Sale> sales;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const SaleListState({
    this.sales = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  SaleListState copyWith({
    List<Sale>? sales,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return SaleListState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class SaleListNotifier extends StateNotifier<SaleListState> {
  final SaleService _saleService;

  SaleListNotifier(this._saleService) : super(const SaleListState());

  Future<void> loadSales({
    int? customerId,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const SaleListState();
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
  
      final response = await _saleService.getSales(
        customerId: customerId,
        status: status,
        page: refresh ? 1 : state.currentPage,
        limit: 50,
      );

  

      if (response.isSuccess && response.data != null) {
        final newSales = refresh
            ? response.data!
            : [...state.sales, ...response.data!];

      

        state = state.copyWith(
          sales: newSales,
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
}

final saleListProvider = StateNotifierProvider<SaleListNotifier, SaleListState>(
  (ref) {
    final saleService = ref.watch(saleServiceProvider);
    return SaleListNotifier(saleService);
  },
);

// Sale Detail Provider
class SaleDetailState {
  final Sale? sale;
  final bool isLoading;
  final String? error;

  const SaleDetailState({this.sale, this.isLoading = false, this.error});

  SaleDetailState copyWith({Sale? sale, bool? isLoading, String? error}) {
    return SaleDetailState(
      sale: sale ?? this.sale,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SaleDetailNotifier extends StateNotifier<SaleDetailState> {
  final SaleService _saleService;

  SaleDetailNotifier(this._saleService) : super(const SaleDetailState());

  Future<void> loadSale(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _saleService.getSale(id);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(sale: response.data, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateSaleStatus(int id, String status) async {
    try {
      final response = await _saleService.updateSaleStatus(id, status);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(sale: response.data);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addPayment(
    int saleId, {
    required int paymentMethodId,
    required double amount,
    String? referenceNumber,
    DateTime? paymentDate,
    String? notes,
  }) async {
    try {
      final response = await _saleService.createPayment(
        saleId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        referenceNumber: referenceNumber,
        paymentDate: paymentDate,
        notes: notes,
      );

      if (response.isSuccess && response.data != null) {
        // After successful payment, reload sale to refresh payments and totals
        await loadSale(saleId);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteSale(int id) async {
    try {
      final response = await _saleService.deleteSale(id);

      if (response.isSuccess) {
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final saleDetailProvider =
    StateNotifierProvider<SaleDetailNotifier, SaleDetailState>((ref) {
      final saleService = ref.watch(saleServiceProvider);
      return SaleDetailNotifier(saleService);
    });

// Sale Form Provider for creating/editing sales
class SaleFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SaleFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SaleFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return SaleFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SaleFormNotifier extends StateNotifier<SaleFormState> {
  final SaleService _saleService;

  SaleFormNotifier(this._saleService) : super(const SaleFormState());

  Future<Sale?> createSale({
    int? customerId,
    required List<Map<String, dynamic>> items,
    String? discountType,
    double? discountValue,
    double? taxRate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await _saleService.createSale(
        customerId: customerId,
        items: items,
        discountType: discountType,
        discountValue: discountValue,
        taxRate: taxRate,
        notes: notes,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return response.data;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<Sale?> updateSale(int id, {String? notes, String? status}) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await _saleService.updateSale(
        id,
        notes: notes,
        status: status,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return response.data;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const SaleFormState();
  }
}

final saleFormProvider = StateNotifierProvider<SaleFormNotifier, SaleFormState>(
  (ref) {
    final saleService = ref.watch(saleServiceProvider);
    return SaleFormNotifier(saleService);
  },
);
