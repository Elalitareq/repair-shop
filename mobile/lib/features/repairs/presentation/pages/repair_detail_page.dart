import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/repair.dart';
import '../../../../shared/providers/repair_provider.dart';

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
      final id = int.tryParse(widget.repairId);
      if (id != null) {
        ref.read(repairDetailProvider.notifier).loadRepair(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repairDetailState = ref.watch(repairDetailProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Repair #${repairDetailState.repair?.ticketNumber ?? widget.repairId}',
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/repairs'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (repairDetailState.repair != null &&
              repairDetailState.repair!.canBeEdited)
            IconButton(
              onPressed: () => context.go('/repairs/${widget.repairId}/edit'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Repair',
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
      floatingActionButton:
          repairDetailState.repair != null &&
              !repairDetailState.repair!.isCompleted
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showStatusUpdateDialog(repairDetailState.repair!),
              icon: const Icon(Icons.update),
              label: const Text('Update Status'),
            )
          : null,
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
          if (repair.customer != null) ...[
            _buildCustomerCard(repair.customer!),
            const SizedBox(height: 16),
          ],

          // Problem Description Card
          _buildProblemCard(repair),
          const SizedBox(height: 16),

          // Notes Cards
          if (repair.diagnosisNotes != null || repair.repairNotes != null) ...[
            _buildNotesCard(repair),
            const SizedBox(height: 16),
          ],

          // Cost Information Card
          _buildCostCard(repair),
          const SizedBox(height: 16),

          // Timeline Card
          _buildTimelineCard(repair),
          const SizedBox(height: 16),

          // Items/Parts Card
          if (repair.items != null && repair.items!.isNotEmpty) ...[
            _buildItemsCard(repair.items!),
            const SizedBox(height: 16),
          ],

          // Warranty Information Card
          if (repair.warrantyProvided) ...[
            _buildWarrantyCard(repair),
            const SizedBox(height: 16),
          ],

          // Status History Card
          if (repair.statusHistory != null &&
              repair.statusHistory!.isNotEmpty) ...[
            _buildStatusHistoryCard(repair.statusHistory!),
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
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                      _StatusChip(status: repair.status),
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

  Widget _buildDeviceCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
            _buildInfoRow('Type', repair.deviceType),
            _buildInfoRow('Model', repair.deviceModel),
            if (repair.deviceSerial.isNotEmpty)
              _buildInfoRow('Serial Number', repair.deviceSerial),
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
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
            if (customer.phoneNumber != null)
              _buildInfoRow('Phone', customer.phoneNumber!),
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
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

  Widget _buildNotesCard(Repair repair) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
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
            if (repair.diagnosisNotes != null) ...[
              const Text(
                'Diagnosis Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(repair.diagnosisNotes!),
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
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
              '\$${repair.estimatedCost.toStringAsFixed(2)}',
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
                    color: Theme.of(context).colorScheme.primary,
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
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
            _buildInfoRow(
              'Created',
              dateFormat.format(repair.createdAt ?? DateTime.now()),
            ),
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
            if (repair.deliveredAt != null)
              _buildInfoRow(
                'Delivered',
                dateFormat.format(repair.deliveredAt!),
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
                Icon(
                  Icons.inventory,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Parts & Labor',
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
                              color: Colors.blue.withOpacity(0.1),
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
                Icon(
                  Icons.verified_user,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

  void _showStatusUpdateDialog(Repair repair) {
    RepairStatus? selectedStatus = repair.status;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<RepairStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: RepairStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
              const SizedBox(height: 16),
              const Text('Notes (optional):'),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this status change...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != null
                  ? () async {
                      final success = await ref
                          .read(repairDetailProvider.notifier)
                          .updateStatus(
                            status: selectedStatus!,
                            notes: notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status updated successfully'),
                            ),
                          );
                          // Update the repair list as well
                          final updatedRepair = ref
                              .read(repairDetailProvider)
                              .repair;
                          if (updatedRepair != null) {
                            ref
                                .read(repairListProvider.notifier)
                                .updateRepairInList(updatedRepair);
                          }
                        } else {
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
                    }
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse the status chip and priority indicator from the repairs page
class _StatusChip extends StatelessWidget {
  final RepairStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case RepairStatus.pending:
        backgroundColor = Colors.orange;
        break;
      case RepairStatus.inProgress:
        backgroundColor = Colors.blue;
        break;
      case RepairStatus.waitingParts:
        backgroundColor = Colors.purple;
        break;
      case RepairStatus.completed:
        backgroundColor = Colors.green;
        break;
      case RepairStatus.delivered:
        backgroundColor = Colors.teal;
        break;
      case RepairStatus.cancelled:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
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
  final RepairPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (priority) {
      case RepairPriority.low:
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case RepairPriority.normal:
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case RepairPriority.high:
        color = Colors.orange;
        icon = Icons.keyboard_arrow_up;
        break;
      case RepairPriority.urgent:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 2),
        Text(
          priority.name.toUpperCase(),
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
