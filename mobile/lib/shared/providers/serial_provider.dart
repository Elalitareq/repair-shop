import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/serial.dart';
import '../services/serial_service.dart';
import '../../core/network/api_client.dart';

// Serial Service Provider
final serialServiceProvider = Provider<SerialService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SerialService(apiClient);
});

// Serial List Provider
class SerialListState {
  final List<Serial> serials;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const SerialListState({
    this.serials = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  SerialListState copyWith({
    List<Serial>? serials,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return SerialListState(
      serials: serials ?? this.serials,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class SerialListNotifier extends StateNotifier<SerialListState> {
  final SerialService _serialService;

  SerialListNotifier(this._serialService) : super(const SerialListState());

  Future<void> loadSerials({
    int? itemId,
    int? batchId,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const SerialListState();
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _serialService.getSerials(
        itemId: itemId,
        batchId: batchId,
      );

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(serials: response.data!, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final serialListProvider =
    StateNotifierProvider<SerialListNotifier, SerialListState>((ref) {
      final serialService = ref.watch(serialServiceProvider);
      return SerialListNotifier(serialService);
    });

// Serial Form Provider
class SerialFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SerialFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SerialFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return SerialFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SerialFormNotifier extends StateNotifier<SerialFormState> {
  final SerialService _serialService;

  SerialFormNotifier(this._serialService) : super(const SerialFormState());

  Future<Serial?> createSerial({
    required String imei,
    required int itemId,
    required int batchId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await _serialService.createSerial({
        'imei': imei,
        'itemId': itemId,
        'batchId': batchId,
      });

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

  Future<bool> deleteSerial(int id) async {
    try {
      final response = await _serialService.deleteSerial(id);

      if (response.isSuccess) {
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const SerialFormState();
  }
}

final serialFormProvider =
    StateNotifierProvider<SerialFormNotifier, SerialFormState>((ref) {
      final serialService = ref.watch(serialServiceProvider);
      return SerialFormNotifier(serialService);
    });
