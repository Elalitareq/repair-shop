import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/repair.dart';
import '../../../../shared/providers/repair_provider.dart';

class RepairsPage extends ConsumerStatefulWidget {
  const RepairsPage({super.key});

  @override
  ConsumerState<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends ConsumerState<RepairsPage> {
  final _searchController = TextEditingController();
  RepairStatus? _selectedStatus;
  RepairPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    // Load repairs when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repairListProvider.notifier).loadRepairs(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repairListState = ref.watch(repairListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairs'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search repairs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(repairListProvider.notifier).search('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                ref.read(repairListProvider.notifier).search(value);
              },
            ),
          ),

          // Filter chips
          if (_selectedStatus != null || _selectedPriority != null)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Status: ${_selectedStatus!.name}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          ref
                              .read(repairListProvider.notifier)
                              .filterByStatus(null);
                        },
                      ),
                    ),
                  if (_selectedPriority != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Priority: ${_selectedPriority!.name}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedPriority = null);
                          ref
                              .read(repairListProvider.notifier)
                              .filterByPriority(null);
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Repairs list
          Expanded(
            child: repairListState.isLoading && repairListState.repairs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : repairListState.error != null &&
                      repairListState.repairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading repairs',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(repairListState.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(repairListProvider.notifier).refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : repairListState.repairs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No repairs found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Create your first repair to get started'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(repairListProvider.notifier).refresh(),
                    child: ListView.builder(
                      itemCount:
                          repairListState.repairs.length +
                          (repairListState.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == repairListState.repairs.length) {
                          // Load more indicator
                          if (repairListState.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else {
                            // Load more button
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                onPressed: () => ref
                                    .read(repairListProvider.notifier)
                                    .loadMore(),
                                child: const Text('Load More'),
                              ),
                            );
                          }
                        }

                        final repair = repairListState.repairs[index];
                        return _RepairCard(
                          repair: repair,
                          onTap: () => context.go('/repairs/${repair.id}'),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/repairs/create'),
        child: const Icon(Icons.add),
        tooltip: 'Create Repair',
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Repairs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepairStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<RepairStatus?>(
                  value: null,
                  child: Text('All'),
                ),
                ...RepairStatus.values.map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status.name)),
                ),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            const Text('Priority:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepairPriority?>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<RepairPriority?>(
                  value: null,
                  child: Text('All'),
                ),
                ...RepairPriority.values.map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedPriority = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedPriority = null;
              });
              ref.read(repairListProvider.notifier).clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(repairListProvider.notifier)
                  .loadRepairs(
                    refresh: true,
                    status: _selectedStatus,
                    priority: _selectedPriority,
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _RepairCard extends StatelessWidget {
  final Repair repair;
  final VoidCallback onTap;

  const _RepairCard({required this.repair, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ticket #${repair.ticketNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: repair.status),
                ],
              ),
              const SizedBox(height: 8),

              // Device info
              Text(
                '${repair.deviceType} - ${repair.deviceModel}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),

              // Customer info
              if (repair.customer != null)
                Text(
                  'Customer: ${repair.customer!.name}',
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),

              // Problem description
              Text(
                repair.problemDescription,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Priority indicator
                  _PriorityIndicator(priority: repair.priority),
                  const SizedBox(width: 12),

                  // Cost
                  Text(
                    '\$${repair.totalCost.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  // Date
                  Text(
                    DateFormat('MMM dd, yyyy').format(repair.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
