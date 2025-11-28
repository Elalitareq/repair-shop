import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/repair.dart';
import '../models/repair_item.dart';
import '../services/repair_service.dart';

/// Repair list state
class RepairListState {
  final bool isLoading;
  final List<Repair> repairs;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;
  final String? priorityFilter;
  final String? searchQuery;

  const RepairListState({
    this.isLoading = false,
    this.repairs = const [],
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
    this.priorityFilter,
    this.searchQuery,
  });

  RepairListState copyWith({
    bool? isLoading,
    List<Repair>? repairs,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
    String? priorityFilter,
    String? searchQuery,
  }) {
    return RepairListState(
      isLoading: isLoading ?? this.isLoading,
      repairs: repairs ?? this.repairs,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter,
      priorityFilter: priorityFilter,
      searchQuery: searchQuery,
    );
  }
}

/// Repair list notifier
class RepairListNotifier extends StateNotifier<RepairListState> {
  final RepairService _repairService;

  RepairListNotifier(this._repairService) : super(const RepairListState());

  /// Load repairs with filters
  Future<void> loadRepairs({
    bool refresh = false,
    String? status,
    String? priority,
    String? search,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        repairs: [],
        currentPage: 1,
        hasMore: true,
        error: null,
        statusFilter: status,
        priorityFilter: priority,
        searchQuery: search,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repairService.getRepairs(
        page: refresh ? 1 : state.currentPage,
        status: status ?? state.statusFilter,
        priority: priority ?? state.priorityFilter,
        search: search ?? state.searchQuery,
      );

      if (response.isSuccess && response.data != null) {
        final newRepairs = response.data!;

        state = state.copyWith(
          isLoading: false,
          repairs: refresh ? newRepairs : [...state.repairs, ...newRepairs],
          currentPage: refresh ? 2 : state.currentPage + 1,
          hasMore: newRepairs.length >= 20, // Assuming 20 is the page size
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh repairs
  Future<void> refresh() async {
    await loadRepairs(
      refresh: true,
      status: state.statusFilter,
      priority: state.priorityFilter,
      search: state.searchQuery,
    );
  }

  /// Load more repairs (pagination)
  Future<void> loadMore() async {
    await loadRepairs();
  }

  /// Filter by status
  Future<void> filterByStatus(String? status) async {
    await loadRepairs(refresh: true, status: status);
  }

  /// Filter by priority
  Future<void> filterByPriority(String? priority) async {
    await loadRepairs(refresh: true, priority: priority);
  }

  /// Search repairs
  Future<void> search(String query) async {
    await loadRepairs(refresh: true, search: query.isEmpty ? null : query);
  }

  /// Clear filters
  Future<void> clearFilters() async {
    await loadRepairs(refresh: true);
  }

  /// Update repair in list
  void updateRepairInList(Repair updatedRepair) {
    final updatedRepairs = state.repairs.map((repair) {
      return repair.id == updatedRepair.id ? updatedRepair : repair;
    }).toList();

    state = state.copyWith(repairs: updatedRepairs);
  }

  /// Remove repair from list
  void removeRepairFromList(int repairId) {
    final updatedRepairs = state.repairs
        .where((repair) => repair.id != repairId)
        .toList();
    state = state.copyWith(repairs: updatedRepairs);
  }

  /// Add repair to list
  void addRepairToList(Repair newRepair) {
    state = state.copyWith(repairs: [newRepair, ...state.repairs]);
  }
}

/// Individual repair state
class RepairDetailState {
  final bool isLoading;
  final Repair? repair;
  final String? error;

  const RepairDetailState({this.isLoading = false, this.repair, this.error});

  RepairDetailState copyWith({bool? isLoading, Repair? repair, String? error}) {
    return RepairDetailState(
      isLoading: isLoading ?? this.isLoading,
      repair: repair,
      error: error,
    );
  }
}

/// Repair detail notifier
class RepairDetailNotifier extends StateNotifier<RepairDetailState> {
  final RepairService _repairService;

  RepairDetailNotifier(this._repairService) : super(const RepairDetailState());

  /// Load repair by ID
  Future<void> loadRepair(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repairService.getRepair(id);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          repair: response.data,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update repair status
  Future<bool> updateStatus({required String status, String? notes}) async {
    if (state.repair == null) return false;

    try {
      final response = await _repairService.updateRepairStatus(
        id: state.repair!.id,
        status: status,
        notes: notes,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(repair: response.data);
        return true;
      } else {
        state = state.copyWith(error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update repair
  Future<bool> updateRepair(Repair updatedRepair) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repairService.updateRepair(
        id: updatedRepair.id,
        customerId: updatedRepair.customerId,
        deviceBrand: updatedRepair.deviceBrand,
        deviceModel: updatedRepair.deviceModel,
        deviceImei: updatedRepair.deviceImei,
        problemDescription: updatedRepair.problemDescription,
        diagnosisNotes: updatedRepair.diagnosisNotes,
        repairNotes: updatedRepair.repairNotes,
        status: updatedRepair.state.name,
        priority: updatedRepair.priority,
        estimatedCost: updatedRepair.estimatedCost,
        finalCost: updatedRepair.finalCost,
        estimatedCompletion: updatedRepair.estimatedCompletion,
        actualCompletion: updatedRepair.actualCompletion,
        warrantyProvided: updatedRepair.warrantyProvided,
        warrantyDays: updatedRepair.warrantyDays,
        items: updatedRepair.items,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          repair: response.data,
          error: null,
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

  /// Clear state
  void clear() {
    state = const RepairDetailState();
  }
}

/// Repair form state
class RepairFormState {
  final bool isLoading;
  final bool isEditing;
  final Repair? repair;
  final String? error;
  final String? successMessage;

  const RepairFormState({
    this.isLoading = false,
    this.isEditing = false,
    this.repair,
    this.error,
    this.successMessage,
  });

  RepairFormState copyWith({
    bool? isLoading,
    bool? isEditing,
    Repair? repair,
    String? error,
    String? successMessage,
  }) {
    return RepairFormState(
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      repair: repair,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Repair form notifier
class RepairFormNotifier extends StateNotifier<RepairFormState> {
  final RepairService _repairService;

  RepairFormNotifier(this._repairService) : super(const RepairFormState());

  /// Initialize form for editing
  void initializeForEdit(Repair repair) {
    state = state.copyWith(
      isEditing: true,
      repair: repair,
      error: null,
      successMessage: null,
    );
  }

  /// Initialize form for creating
  void initializeForCreate() {
    state = const RepairFormState(isEditing: false);
  }

  /// Create new repair
  Future<Repair?> createRepair({
    required int customerId,
    required String deviceBrand,
    required String deviceModel,
    String? deviceImei,
    required String problemDescription,
    String? diagnosisNotes,
    String priority = 'Normal',
    double estimatedCost = 0.0,
    DateTime? estimatedCompletion,
    bool warrantyProvided = false,
    int? warrantyDays,
    List<RepairItem>? items,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _repairService.createRepair(
        customerId: customerId,
        deviceBrand: deviceBrand,
        deviceModel: deviceModel,
        deviceImei: deviceImei,
        problemDescription: problemDescription,
        diagnosisNotes: diagnosisNotes,
        priority: priority,
        estimatedCost: estimatedCost,
        estimatedCompletion: estimatedCompletion,
        warrantyProvided: warrantyProvided,
        warrantyDays: warrantyDays,
        items: items,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          repair: response.data,
          successMessage: 'Repair created successfully',
          error: null,
        );
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

  /// Update existing repair
  Future<bool> updateRepair(Repair updatedRepair) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _repairService.updateRepair(
        id: updatedRepair.id,
        customerId: updatedRepair.customerId,
        deviceBrand: updatedRepair.deviceBrand,
        deviceModel: updatedRepair.deviceModel,
        deviceImei: updatedRepair.deviceImei,
        problemDescription: updatedRepair.problemDescription,
        diagnosisNotes: updatedRepair.diagnosisNotes,
        repairNotes: updatedRepair.repairNotes,
        status: updatedRepair.state.name,
        priority: updatedRepair.priority,
        estimatedCost: updatedRepair.estimatedCost,
        finalCost: updatedRepair.finalCost,
        estimatedCompletion: updatedRepair.estimatedCompletion,
        actualCompletion: updatedRepair.actualCompletion,
        warrantyProvided: updatedRepair.warrantyProvided,
        warrantyDays: updatedRepair.warrantyDays,
        items: updatedRepair.items,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          repair: response.data,
          successMessage: 'Repair updated successfully',
          error: null,
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

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  /// Clear state
  void clear() {
    state = const RepairFormState();
  }
}

/// Repair statistics state
class RepairStatsState {
  final bool isLoading;
  final Map<String, dynamic>? stats;
  final String? error;

  const RepairStatsState({this.isLoading = false, this.stats, this.error});

  RepairStatsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? stats,
    String? error,
  }) {
    return RepairStatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats,
      error: error,
    );
  }
}

/// Repair statistics notifier
class RepairStatsNotifier extends StateNotifier<RepairStatsState> {
  final RepairService _repairService;

  RepairStatsNotifier(this._repairService) : super(const RepairStatsState());

  /// Load repair statistics
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repairService.getRepairStats();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          stats: response.data,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStats();
  }
}

/// Provider instances
final repairListProvider =
    StateNotifierProvider<RepairListNotifier, RepairListState>((ref) {
      final repairService = ref.watch(repairServiceProvider);
      return RepairListNotifier(repairService);
    });

final repairDetailProvider =
    StateNotifierProvider<RepairDetailNotifier, RepairDetailState>((ref) {
      final repairService = ref.watch(repairServiceProvider);
      return RepairDetailNotifier(repairService);
    });

final repairFormProvider =
    StateNotifierProvider<RepairFormNotifier, RepairFormState>((ref) {
      final repairService = ref.watch(repairServiceProvider);
      return RepairFormNotifier(repairService);
    });

final repairStatsProvider =
    StateNotifierProvider<RepairStatsNotifier, RepairStatsState>((ref) {
      final repairService = ref.watch(repairServiceProvider);
      return RepairStatsNotifier(repairService);
    });

/// Convenience providers
final repairsProvider = Provider<List<Repair>>((ref) {
  return ref.watch(repairListProvider).repairs;
});

final pendingRepairsProvider = Provider<List<Repair>>((ref) {
  final repairs = ref.watch(repairsProvider);
  return repairs.where((repair) => repair.state.name == 'Received').toList();
});

final inProgressRepairsProvider = Provider<List<Repair>>((ref) {
  final repairs = ref.watch(repairsProvider);
  return repairs.where((repair) => repair.state.name == 'In Progress').toList();
});

final completedRepairsProvider = Provider<List<Repair>>((ref) {
  final repairs = ref.watch(repairsProvider);
  return repairs.where((repair) => repair.isCompleted).toList();
});

final overdueRepairsProvider = Provider<List<Repair>>((ref) {
  final repairs = ref.watch(repairsProvider);
  final now = DateTime.now();
  return repairs.where((repair) {
    final estimatedCompletion = repair.estimatedCompletion;
    return estimatedCompletion != null &&
        estimatedCompletion.isBefore(now) &&
        !repair.isCompleted;
  }).toList();
});
