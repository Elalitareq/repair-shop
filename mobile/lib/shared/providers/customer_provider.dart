import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import '../models/repair.dart';
import '../services/repair_service.dart';
import './sale_provider.dart';
import '../services/sale_service.dart';
import '../services/customer_service.dart';

/// State for customer list
class CustomerListState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final String? typeFilter;

  const CustomerListState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
    this.typeFilter,
  });

  CustomerListState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    String? typeFilter,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

/// Notifier for customer list
class CustomerListNotifier extends StateNotifier<CustomerListState> {
  final CustomerService _customerService;

  CustomerListNotifier(this._customerService)
    : super(const CustomerListState());

  Future<void> loadCustomers({
    bool refresh = false,
    String? search,
    String? type,
  }) async {
    if (refresh) {
      state = const CustomerListState();
    }

    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: search,
      typeFilter: type,
    );

    try {
      final response = await _customerService.getCustomers(
        search: search,
        type: type,
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      if (response.isSuccess && response.data != null) {
        final newCustomers = refresh
            ? response.data!
            : [...state.customers, ...response.data!];
        state = state.copyWith(
          customers: newCustomers,
          isLoading: false,
          hasMore: response.data!.length >= 20,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchCustomers(String query) async {
    await loadCustomers(refresh: true, search: query);
  }

  Future<void> filterByType(String? type) async {
    await loadCustomers(refresh: true, type: type);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// State for single customer
class CustomerDetailState {
  final Customer? customer;
  final Map<String, dynamic>? stats;
  final List<Repair>? recentRepairs;
  final bool isLoading;
  final String? error;

  const CustomerDetailState({
    this.customer,
    this.stats,
    this.recentRepairs,
    this.isLoading = false,
    this.error,
  });

  CustomerDetailState copyWith({
    Customer? customer,
    Map<String, dynamic>? stats,
    List<Repair>? recentRepairs,
    bool? isLoading,
    String? error,
  }) {
    return CustomerDetailState(
      customer: customer ?? this.customer,
      stats: stats ?? this.stats,
      recentRepairs: recentRepairs ?? this.recentRepairs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for customer detail
class CustomerDetailNotifier extends StateNotifier<CustomerDetailState> {
  final CustomerService _customerService;
  final RepairService _repairService;
  final SaleService _saleService;

  CustomerDetailNotifier(
    this._customerService,
    this._repairService,
    this._saleService,
  ) : super(const CustomerDetailState());

  Future<void> loadCustomer(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _customerService.getCustomer(id);

      if (response.isSuccess && response.data != null) {
        // Also fetch customer stats and recent repairs in parallel
        final recentRepairsFuture = _repairService.getRepairs(
          customerId: id,
          page: 1,
          limit: 5,
        );
        final salesResp = await _saleService.getSales(
          customerId: id,
          page: 1,
          limit: 100,
        );
        final recentRepairsResp = await recentRepairsFuture;

        final totalRepairs =
            recentRepairsResp.isSuccess && recentRepairsResp.data != null
            ? recentRepairsResp.data!.length
            : 0;

        final totalSpent = salesResp.isSuccess && salesResp.data != null
            ? salesResp.data!.fold<double>(
                0.0,
                (sum, sale) => sum + sale.totalAmount,
              )
            : 0.0;

        state = state.copyWith(
          customer: response.data,
          stats: {'totalRepairs': totalRepairs, 'totalSpent': totalSpent},
          recentRepairs: recentRepairsResp.isSuccess
              ? recentRepairsResp.data
              : null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _customerService.createCustomer(
        name: data['name'],
        companyName: data['company_name'],
        type: data['type'],
        phoneNumber: data['phone_number'],
        address: data['address'],
        taxNumber: data['tax_number'],
        locationLink: data['location_link'],
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(customer: response.data, isLoading: false);
        // Re-fetch stats and recent repairs with the new id
        await loadCustomer(response.data!.id);
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

  Future<bool> updateCustomer(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _customerService.updateCustomer(
        id: id,
        name: data['name'],
        companyName: data['company_name'],
        type: data['type'],
        phoneNumber: data['phone_number'],
        address: data['address'],
        taxNumber: data['tax_number'],
        locationLink: data['location_link'],
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(customer: response.data, isLoading: false);
        await loadCustomer(id);
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

  Future<bool> deleteCustomer(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _customerService.deleteCustomer(id);

      if (response.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          stats: null,
          recentRepairs: null,
          customer: null,
        );
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

/// Providers
final customerListProvider =
    StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
      final customerService = ref.watch(customerServiceProvider);
      return CustomerListNotifier(customerService);
    });

final customerDetailProvider =
    StateNotifierProvider<CustomerDetailNotifier, CustomerDetailState>((ref) {
      final customerService = ref.watch(customerServiceProvider);
      final repairService = ref.watch(repairServiceProvider);
      final saleService = ref.watch(saleServiceProvider);
      return CustomerDetailNotifier(
        customerService,
        repairService,
        saleService,
      );
    });

/// Future providers for simple use cases
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final customerService = ref.watch(customerServiceProvider);
  final response = await customerService.getCustomers();
  return response.dataOrThrow;
});

final dealersProvider = FutureProvider<List<Customer>>((ref) async {
  final customerService = ref.watch(customerServiceProvider);
  final response = await customerService.getDealers();
  return response.dataOrThrow;
});
