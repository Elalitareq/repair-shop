import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/item_provider.dart';

class BatchListPage extends ConsumerStatefulWidget {
  const BatchListPage({super.key});

  @override
  ConsumerState<BatchListPage> createState() => _BatchListPageState();
}

class _BatchListPageState extends ConsumerState<BatchListPage> {
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
      appBar: AppBar(title: const Text('Batches')),
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
                  direction: DismissDirection.endToStart,
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
                    final success = await ref
                        .read(batchDetailProvider.notifier)
                        .deleteBatch(b.id);

                    if (success) {
                      ref.invalidate(batchListProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Batch deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      final error = ref.read(batchDetailProvider).error;
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error?.toString() ?? 'Failed to delete batch',
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
                    title: Row(
                      children: [
                        Text(b.batchNumber),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed('/inventory/batches/edit/${b.id}'),
                    ),
                    onTap: () => Navigator.of(
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
