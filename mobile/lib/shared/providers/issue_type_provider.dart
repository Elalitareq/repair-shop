import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_response.dart';
import '../services/repair_service.dart';

/// Provider for issue types
final issueTypesProvider = FutureProvider<ApiResponse<List<IssueType>>>((ref) async {
  final repairService = ref.watch(repairServiceProvider);
  return await repairService.getIssueTypes();
});
