import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:repair_shop_mobile/shared/models/item.dart';
import 'package:repair_shop_mobile/shared/providers/item_provider.dart';

import '../../../../shared/models/repair.dart';
import '../../../../shared/providers/repair_provider.dart';
import '../../../../shared/services/reference_service.dart';
import '../../../../shared/services/repair_service.dart';
import '../../../../shared/providers/issue_type_provider.dart';
import '../../../../shared/providers/pdf_provider.dart';
import '../../../../shared/models/payment_method.dart';

class RepairDetailPage extends ConsumerStatefulWidget {
  final String repairId;

  const RepairDetailPage({super.key, required this.repairId});

  @override
  ConsumerState<RepairDetailPage> createState() => _RepairDetailPageState();
}

class _RepairDetailPageState extends ConsumerState<RepairDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load repair details when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(repairDetailProvider.notifier)
          .loadRepair(int.tryParse(widget.repairId)!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repairDetailState = ref.watch(repairDetailProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Case #${repairDetailState.repair?.id ?? widget.repairId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/repairs'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (repairDetailState.repair != null)
            IconButton(
              onPressed: () => ref
                  .read(pdfServiceProvider)
                  .printRepairInvoice(repairDetailState.repair!),
              icon: const Icon(Icons.print),
              tooltip: 'Print Invoice',
            ),
          if (repairDetailState.repair != null &&
              repairDetailState.repair!.state.name != 'Delivered')
            IconButton(
              onPressed: () => context.go('/repairs/${widget.repairId}/edit'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Repair',
            ),
          if (repairDetailState.repair != null)
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(
                context,
                repairDetailState.repair!.id,
              ),
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Repair',
              color: Colors.red,
            ),
        ],
      ),
      body: repairDetailState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : repairDetailState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading repair',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(repairDetailState.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final id = int.tryParse(widget.repairId);
                      if (id != null) {
                        ref.read(repairDetailProvider.notifier).loadRepair(id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : repairDetailState.repair == null
          ? const Center(child: Text('Repair not found'))
          : _buildRepairDetails(repairDetailState.repair!),
      floatingActionButton: null,
    );
  }

  Widget _buildRepairDetails(Repair repair) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Priority Card
          _buildStatusCard(repair),
          const SizedBox(height: 16),

          // Device Information Card
          _buildDeviceCard(repair),
          const SizedBox(height: 16),

          // Customer Information Card
          ...[_buildCustomerCard(repair.customer), const SizedBox(height: 16)],

          // Problem Description Card
          _buildProblemCard(repair),
          const SizedBox(height: 16),

          // Issues Card
          if (repair.issues.isNotEmpty) ...[
            _buildIssuesCard(
              repair.issues,
              ref.watch(issueTypesProvider).value?.data ?? [],
            ),
            const SizedBox(height: 16),
          ],

          // Notes Cards
          ...[_buildNotesCard(repair), const SizedBox(height: 16)],

          // Cost Information Card
          _buildCostCard(repair),
          const SizedBox(height: 16),

          // Timeline Card
          _buildTimelineCard(repair),
          const SizedBox(height: 16),

          // Payments Card
          _buildPaymentsCard(repair),
          const SizedBox(height: 16),

          // Items/Parts Card
          _buildItemsCard(repair.items),
          const SizedBox(height: 16),

          // Warranty Information Card
          if (repair.warrantyProvided) ...[
            _buildWarrantyCard(repair),
            const SizedBox(height: 16),
          ],

          // Status History Card
          if (repair.statusHistory.isNotEmpty) ...[
            _buildStatusHistoryCard(repair.statusHistory),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Status & Priority',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusChip(status: repair.state.name),
                          const SizedBox(width: 8),
                          if (repair.state.name != 'Delivered')
                            ElevatedButton.icon(
                              onPressed: () => _showUpdateStatusDialog(repair),
                              icon: const Icon(Icons.autorenew),
                              label: const Text('Update Status'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      _PriorityIndicator(priority: repair.priority),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateStatusDialog(Repair repair) async {
    final referenceService = ref.read(referenceServiceProvider);
    final repairDetailNotifier = ref.read(repairDetailProvider.notifier);

    // Load states
    final statesResponse = await referenceService.getRepairStates();
    if (!statesResponse.isSuccess || statesResponse.data == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(statesResponse.message)));
      }
      return;
    }

    final states = statesResponse.data!;
    int? selectedStateId = repair.stateId;
    final notesController = TextEditingController();
    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Repair Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...states.map((s) {
                    return RadioListTile<int>(
                      title: Text(s.name),
                      value: s.id,
                      groupValue: selectedStateId,
                      onChanged: (value) =>
                          setState(() => selectedStateId = value),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUpdating || selectedStateId == null
                      ? null
                      : () async {
                          setState(() => isUpdating = true);
                          final selectedState = states.firstWhere(
                            (s) => s.id == selectedStateId,
                          );
                          final success = await repairDetailNotifier
                              .updateStatus(
                                status: selectedState.name,
                                notes: notesController.text.isEmpty
                                    ? null
                                    : notesController.text,
                              );
                          setState(() => isUpdating = false);
                          if (success) {
                            Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Status updated successfully'),
                                ),
                              );
                            }
                            // Refresh repair details
                            await repairDetailNotifier.loadRepair(repair.id);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ref.read(repairDetailProvider).error ??
                                        'Failed to update status',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Device Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Type', repair.deviceBrand),
            _buildInfoRow('Model', repair.deviceModel),
            if (repair.deviceImei != null && repair.deviceImei!.isNotEmpty)
              _buildInfoRow('Serial Number', repair.deviceImei!),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', customer.name),
            if (customer.phone != null) _buildInfoRow('Phone', customer.phone!),
            if (customer.address != null)
              _buildInfoRow('Address', customer.address!),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Problem Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              repair.problemDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesCard(
    List<RepairIssue> issues,
    List<IssueType> issueTypes,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Identified Issues',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: issues.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final issue = issues[index];
                final type = issueTypes.firstWhere(
                  (t) => t.id == issue.issueTypeId,
                  orElse: () =>
                      IssueType(id: issue.issueTypeId, name: 'Unknown Issue'),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (issue.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        issue.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...[
              const Text(
                'Diagnosis Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(repair.diagnosisNotes ?? ""),
              const SizedBox(height: 12),
            ],
            if (repair.repairNotes != null) ...[
              const Text(
                'Repair Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(repair.repairNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Cost Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Estimated Cost',
              '\$${repair.estimatedCost?.toStringAsFixed(2) ?? '0.00'}',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      'Service Charge',
                      '\$${repair.serviceCharge?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showUpdateServiceChargeDialog(repair),
                    tooltip: 'Update Service Charge',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            if (repair.finalCost != null)
              _buildInfoRow(
                'Final Cost',
                '\$${repair.finalCost!.toStringAsFixed(2)}',
              ),
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${repair.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(Repair repair) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Created', dateFormat.format(repair.createdAt)),
            if (repair.estimatedCompletion != null)
              _buildInfoRow(
                'Estimated Completion',
                dateFormat.format(repair.estimatedCompletion!),
              ),
            if (repair.actualCompletion != null)
              _buildInfoRow(
                'Actual Completion',
                dateFormat.format(repair.actualCompletion!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(List items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Parts & Labor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () => _showAddItemDialog(
                    ref.read(repairDetailProvider).repair!,
                  ),
                  tooltip: 'Add Item',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (item.isLabor)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LABOR',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Qty: ${item.quantity.toStringAsFixed(item.quantity == item.quantity.toInt() ? 0 : 2)}',
                        ),
                        const Text(' × '),
                        Text('\$${item.unitPrice.toStringAsFixed(2)}'),
                        const Spacer(),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Parts & Labor:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0)).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.payment, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Payments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(context, repair),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if ((repair.payments.isNotEmpty) ||
                (repair.paymentAllocations.isNotEmpty)) ...[
              ...repair.paymentAllocations.map(
                (allocation) => ListTile(
                  title: Text('\$${allocation.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${allocation.payment?.paymentMethodDisplay ?? 'Unknown'} • ${allocation.payment?.paymentDate.toLocal().toString().split(' ')[0] ?? ''}',
                  ),
                  trailing: const Chip(label: Text('Allocated')),
                ),
              ),
              ...repair.payments.map(
                (payment) => ListTile(
                  title: Text('\$${payment.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    '${payment.paymentMethodDisplay} • ${payment.paymentDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Chip(label: Text('Direct')),
                ),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('No payments recorded'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Warranty Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Warranty Provided', 'Yes'),
            if (repair.warrantyDays != null)
              _buildInfoRow('Warranty Period', '${repair.warrantyDays} days'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistoryCard(List statusHistory) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Status History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final history = statusHistory[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusChip(status: history.status),
                        const Spacer(),
                        Text(
                          dateFormat.format(history.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (history.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(history.notes!),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Updated by: ${history.updatedBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateServiceChargeDialog(Repair repair) async {
    final controller = TextEditingController(
      text: repair.serviceCharge?.toStringAsFixed(2) ?? '0.00',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Service Charge'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Service Charge',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              print("before new value");

              final newValue = double.tryParse(controller.text);
              print("after new value");
              if (newValue != null) {
                final success = await ref
                    .read(repairDetailProvider.notifier)
                    .updateServiceCharge(repair.id, newValue);
                print("after request");
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service charge updated')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update service charge'),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(Repair repair) async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add Item'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showAddCustomItemDialog(repair);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Add Custom Item/Labor'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showStockItemPicker(repair);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Select from Stock'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomItemDialog(Repair repair) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    bool isLabor = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Custom Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Is Labor?'),
                  value: isLabor,
                  onChanged: (val) => setState(() => isLabor = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty)
                  return;

                final qty = double.tryParse(qtyController.text) ?? 1;
                final price = double.tryParse(priceController.text) ?? 0;

                final success = await ref
                    .read(repairDetailProvider.notifier)
                    .addRepairItem(
                      repairId: repair.id,
                      itemName: nameController.text,
                      description: descController.text,
                      quantity: qty,
                      unitPrice: price,
                      isLabor: isLabor,
                    );

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Item added')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add item')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStockItemPicker(Repair repair) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // Load items
    final response = await ref.read(itemServiceProvider).getItems();

    if (mounted) {
      Navigator.pop(context); // Close loading

      if (!response.isSuccess || response.data == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        return;
      }

      final items = response.data!;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select Stock Item'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    'Stock: ${item.stockQuantity} - Price: \$${item.sellingPrice}',
                  ),
                  enabled: item.stockQuantity > 0,
                  onTap: item.stockQuantity > 0
                      ? () {
                          Navigator.pop(context);
                          _showAddStockItemQuantityDialog(repair, item);
                        }
                      : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showAddStockItemQuantityDialog(Repair repair, Item item) async {
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: (item.sellingPrice ?? 0.0).toStringAsFixed(2),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Stock: ${item.stockQuantity}'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final qty = double.tryParse(qtyController.text);
              final price = double.tryParse(priceController.text);

              if (qty == null || qty <= 0) {
                return;
              }

              if (qty > item.stockQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insufficient stock')),
                );
                return;
              }

              final repairState = ref.read(repairDetailProvider);
              if (repairState.repair == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Repair not loaded')),
                );
                return;
              }

              final success = await ref
                  .read(repairDetailProvider.notifier)
                  .addRepairItem(
                    repairId: repair.id,
                    itemName: item.name,
                    description: item.description,
                    quantity: qty,
                    unitPrice: price ?? item.sellingPrice ?? 0.0,
                    isLabor: false,
                    itemId: item.id,
                  );

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stock item added')),
                  );
                } else {
                  final error = ref.read(repairDetailProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item: $error')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentDialog(
    BuildContext context,
    Repair repair,
  ) async {
    final _formKey = GlobalKey<FormState>();
    int? selectedMethodId;
    // Calculate remaining balance
    double totalPaid =
        repair.payments.fold(0.0, (sum, p) => sum + p.amount) +
        repair.paymentAllocations.fold(0.0, (sum, a) => sum + a.amount);
    double remainingBalance = repair.totalCost - totalPaid;
    if (remainingBalance < 0) remainingBalance = 0;

    double amount = remainingBalance;
    final _refController = TextEditingController(text: '');
    final _notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final referenceService = ref.read(referenceServiceProvider);
            return FutureBuilder(
              future: referenceService.getPaymentMethods(),
              builder: (context, snapshot) {
                final rawMethods = snapshot.hasData && snapshot.data!.isSuccess
                    ? snapshot.data!.data!
                    : <PaymentMethod>[];
                // Only allow Cash and Whish Money (or Wish Money), others can be added in settings
                final methods = rawMethods
                    .where(
                      (m) => [
                        'cash',
                        'whish money',
                        'wish money',
                      ].contains(m.name.toLowerCase()),
                    )
                    .toList();

                if (methods.isEmpty) {
                  return AlertDialog(
                    title: const Text('Add Payment'),
                    content: const Text(
                      'No payment methods configured. Please add payment methods in settings.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }

                selectedMethodId ??= methods.first.id;

                return AlertDialog(
                  title: const Text('Add Payment'),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            value: selectedMethodId,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                            ),
                            items: methods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text(m.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => selectedMethodId = value,
                            validator: (v) => v == null
                                ? 'Please select a payment method'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: amount.toStringAsFixed(2),
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) =>
                                v == null ||
                                    double.tryParse(v) == null ||
                                    double.parse(v) <= 0
                                ? 'Enter valid amount'
                                : null,
                            onSaved: (v) =>
                                amount = double.tryParse(v ?? '0') ?? 0,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _refController,
                            decoration: const InputDecoration(
                              labelText: 'Reference Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        final success = await ref
                            .read(repairDetailProvider.notifier)
                            .addPayment(
                              repair.id,
                              paymentMethodId: selectedMethodId!,
                              amount: amount,
                              referenceNumber: _refController.text.isNotEmpty
                                  ? _refController.text
                                  : null,
                              paymentDate: paymentDate,
                              notes: _notesController.text.isNotEmpty
                                  ? _notesController.text
                                  : null,
                            );

                        if (mounted) {
                          Navigator.of(context).pop();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment added successfully'),
                              ),
                            );
                            // Refresh repair details
                            ref
                                .read(repairDetailProvider.notifier)
                                .loadRepair(repair.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add payment'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    int repairId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Repair'),
        content: const Text(
          'Are you sure you want to delete this repair? This action cannot be undone and will return items to stock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(repairDetailProvider.notifier)
          .deleteRepair(repairId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Repair deleted successfully')),
          );
          context.go('/repairs');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete repair')),
          );
        }
      }
    }
  }
}

// Reuse the status chip and priority indicator from the repairs page
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case 'Received':
        backgroundColor = Colors.orange;
        break;
      case 'Diagnosed':
        backgroundColor = Colors.yellow;
        break;
      case 'In Progress':
        backgroundColor = Colors.blue;
        break;
      case 'Waiting Parts':
        backgroundColor = Colors.purple;
        break;
      case 'Completed':
        backgroundColor = Colors.green;
        break;
      case 'Ready for Pickup':
        backgroundColor = Colors.teal;
        break;
      case 'Delivered':
        backgroundColor = Colors.grey;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final String priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case 'low':
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case 'normal':
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case 'high':
        color = Colors.orange;
        icon = Icons.keyboard_arrow_up;
        break;
      case 'urgent':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 2),
        Text(
          priority.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
