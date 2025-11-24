import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';

class BackupService {
  final ApiClient _apiClient;

  BackupService(this._apiClient);

  Future<ApiResponse<Uint8List>> downloadBackup() async {
    final res = await _apiClient.downloadBytes('/backups/download');
    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> restoreBackup(File file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromFileSync(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return await _apiClient.uploadMultipart<Map<String, dynamic>>(
      '/backups/restore',
      formData: formData,
    );
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final client = ref.watch(apiClientProvider);
  return BackupService(client);
});
