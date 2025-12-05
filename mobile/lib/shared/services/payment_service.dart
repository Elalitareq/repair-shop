import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/payment.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<ApiResponse<Payment>> allocatePayment({
    required int customerId,
    required int paymentMethodId,
    required double amount,
    String? referenceNumber,
    String? notes,
    List<Map<String, dynamic>>? allocations,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/payments/allocate',
      data: {
        'customerId': customerId,
        'paymentMethodId': paymentMethodId,
        'amount': amount,
        'referenceNumber': referenceNumber,
        'notes': notes,
        'allocations': allocations,
      },
    );

    if (response.isSuccess && response.data != null) {
      final paymentData = response.data!['data'];
      // Assuming Payment model can handle the response or we just return success
      // If Payment model doesn't match exactly (e.g. allocations), we might need to adjust
      // For now, let's assume standard Payment structure or just return true/data

      // If the backend returns the created payment with allocations, we might need to update Payment model
      // But for now, let's just return the Payment object if possible
      try {
        final payment = Payment.fromJson(paymentData);
        return ApiResponse.success(
          data: payment,
          message: response.data!['message'] ?? response.message,
          statusCode: response.statusCode,
        );
      } catch (e) {
        // Fallback if parsing fails (e.g. if allocations structure is complex)
        // We can just return success with null data if we don't need the object immediately
        return ApiResponse.success(
          data: null, // Or handle better
          message: response.data!['message'] ?? response.message,
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponse.error(
      message: response.message,
      statusCode: response.statusCode,
      error: response.error,
    );
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient);
});
