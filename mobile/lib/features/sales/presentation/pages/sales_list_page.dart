import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/sale_provider.dart';

class SalesListPage extends ConsumerStatefulWidget {
  const SalesListPage({super.key});

  @override
  ConsumerState<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends ConsumerState<SalesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(saleListProvider.notifier).loadSales(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter dialog
            },
          ),
        ],
      ),
      body: state.isLoading && state.sales.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(saleListProvider.notifier)
                    .loadSales(refresh: true);
              },
              child: ListView.builder(
                itemCount: state.sales.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.sales.length) {
                    // Load more indicator
                    if (!state.isLoading) {
                      Future.microtask(
                        () => ref.read(saleListProvider.notifier).loadSales(),
                      );
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final sale = state.sales[index];
                  print(
                    '🔍 SalesListPage - Building sale item $index: ${sale.toString()}',
                  );
                  print(
                    '🔍 SalesListPage - Sale ID: ${sale.id}, saleNumber: ${sale.saleNumber}, customer: ${sale.customer?.name ?? 'null'}',
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text('Sale #${sale.saleNumber ?? 'N/A'}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer: ${sale.customer?.name ?? 'Walk-in'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Total: \$${sale.totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Status: ${sale.getDisplayStatus()}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: _getStatusColor(sale.status)),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        _getStatusIcon(sale.status),
                        color: _getStatusColor(sale.status),
                      ),
                      onTap: () => context.go('/sales/${sale.id}'),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/sales/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    print('🔍 SalesListPage._getStatusColor - status: $status');
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    print('🔍 SalesListPage._getStatusIcon - status: $status');
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }
}
