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
  String? _selectedStatus;
  String? _selectedPriority;

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
        backgroundColor: Colors.blue,
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
                        label: Text('Status: ${_selectedStatus!}'),
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
                        label: Text('Priority: ${_selectedPriority!}'),
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
            DropdownButtonFormField<String?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All'),
                ),
                const DropdownMenuItem(
                  value: 'Received',
                  child: Text('Received'),
                ),
                const DropdownMenuItem(
                  value: 'Diagnosed',
                  child: Text('Diagnosed'),
                ),
                const DropdownMenuItem(
                  value: 'In Progress',
                  child: Text('In Progress'),
                ),
                const DropdownMenuItem(
                  value: 'Waiting Parts',
                  child: Text('Waiting Parts'),
                ),
                const DropdownMenuItem(
                  value: 'Completed',
                  child: Text('Completed'),
                ),
                const DropdownMenuItem(
                  value: 'Ready for Pickup',
                  child: Text('Ready for Pickup'),
                ),
                const DropdownMenuItem(
                  value: 'Delivered',
                  child: Text('Delivered'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            const Text('Priority:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All'),
                ),
                const DropdownMenuItem(value: 'Low', child: Text('Low')),
                const DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                const DropdownMenuItem(value: 'High', child: Text('High')),
                const DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
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
                  Text(
                    repair.repairNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _StatusChip(status: repair.state.name),
                ],
              ),
              const SizedBox(height: 8),

              // Device info
              Text(
                '${repair.deviceBrand} - ${repair.deviceModel}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),

              // Customer info
              Text(
                'Customer: ${repair.customer.name}',
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
              const SizedBox(height: 8),

              // Cost breakdown
              Row(
                children: [
                  const Icon(Icons.miscellaneous_services,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Service: \$${(repair.serviceCharge ?? 0.0).toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.inventory_2_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Parts: \$${repair.items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0)).toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
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
                      color: Colors.blue,
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
      case 'Low':
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case 'Normal':
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case 'High':
        color = Colors.orange;
        icon = Icons.keyboard_arrow_up;
        break;
      case 'Urgent':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
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
