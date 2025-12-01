import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/services/batch_service.dart';

class BatchListPage extends ConsumerStatefulWidget {
  const BatchListPage({super.key});

  @override
  ConsumerState<BatchListPage> createState() => _BatchListPageState();
}

class _BatchListPageState extends ConsumerState<BatchListPage> {
  bool _isSelectionMode = false;
  Set<int> _selectedBatches = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedBatches.clear();
      }
    });
  }

  void _toggleBatchSelection(int batchId) {
    setState(() {
      if (_selectedBatches.contains(batchId)) {
        _selectedBatches.remove(batchId);
      } else {
        _selectedBatches.add(batchId);
      }
    });
  }

  void _selectAllBatches(List batches) {
    setState(() {
      if (_selectedBatches.length == batches.length) {
        _selectedBatches.clear();
      } else {
        _selectedBatches = batches.map<int>((b) => b.batch.id).toSet();
      }
    });
  }

  Future<void> _deleteSelectedBatches() async {
    if (_selectedBatches.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Batches'),
        content: Text(
          'Are you sure you want to delete ${_selectedBatches.length} batch(es)?\n\nNote: Batches with sold items or associated serials cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final batchService = ref.read(batchServiceProvider);
      int successCount = 0;
      int failureCount = 0;

      for (final batchId in _selectedBatches) {
        try {
          await batchService.deleteBatch(batchId);
          successCount++;
        } catch (e) {
          failureCount++;
        }
      }

      ref.invalidate(batchListProvider);
      _toggleSelectionMode(); // Exit selection mode

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted $successCount batch(es)${failureCount > 0 ? ', $failureCount failed' : ''}',
            ),
            backgroundColor: failureCount > 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(batchListProvider.notifier).loadBatches(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode 
            ? '${_selectedBatches.length} Selected' 
            : 'Batches'),
        actions: [
          if (!_isSelectionMode && state.batches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist_outlined),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: () => _selectAllBatches(state.batches),
              child: Text(
                _selectedBatches.length == state.batches.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
            if (_selectedBatches.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedBatches,
                tooltip: 'Delete Selected',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
                tooltip: 'Cancel Selection',
              ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : ListView.builder(
              itemCount: state.batches.length,
              itemBuilder: (context, index) {
                final batchData = state.batches[index];
                final b = batchData.batch;
                final remainingStock = batchData.remainingStock;
                final isLowStock = batchData.isLowStock;
                final isOutOfStock = batchData.isOutOfStock;

                return Dismissible(
                  key: Key('batch_${b.id}'),
                  direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Batch'),
                          content: Text(
                            'Are you sure you want to delete batch "${b.batchNumber}"?\n\nThis action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                    return false;
                  },
                  onDismissed: (direction) async {
                    final batchService = ref.read(batchServiceProvider);
                    try {
                      await batchService.deleteBatch(b.id);
                      ref.invalidate(batchListProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Batch deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to delete batch: ${e.toString()}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: _selectedBatches.contains(b.id),
                            onChanged: (value) {
                              _toggleBatchSelection(b.id);
                            },
                          )
                        : null,
                    title: Row(
                      children: [
                        Expanded(child: Text(b.batchNumber)),
                        const SizedBox(width: 8),
                        if (isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Low Stock',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qty: $remainingStock/${b.totalQuantity} • Cost: \$${b.totalCost}',
                        ),
                        Builder(
                          builder: (context) {
                            final formatted = DateFormat(
                              'yyyy-MM-dd',
                            ).format(b.purchaseDate);
                            return Text(
                              'Purchased: $formatted',
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: _isSelectionMode
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamed('/inventory/batches/edit/${b.id}'),
                          ),
                    onTap: _isSelectionMode
                        ? () => _toggleBatchSelection(b.id)
                        : () => Navigator.of(
                            context,
                          ).pushNamed('/inventory/batches/${b.id}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/inventory/batches/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
