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
  bool _showCost = false;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(_showCost ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showCost = !_showCost;
              });
            },
            tooltip: _showCost ? 'Hide Costs' : 'Show Costs',
          ),
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${state.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(saleListProvider.notifier)
                            .loadSales(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(saleListProvider.notifier)
                        .loadSales(refresh: true);
                  },
                  child: state.sales.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No sales found')),
                          ],
                        )
                      : ListView.builder(
                          itemCount:
                              state.sales.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.sales.length) {
                              // Load more indicator
                              if (!state.isLoading) {
                                Future.microtask(
                                  () => ref
                                      .read(saleListProvider.notifier)
                                      .loadSales(),
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
                            // Debug prints removed for cleaner production code
                            // but kept the logic same

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title:
                                    Text('Sale #${sale.saleNumber ?? 'N/A'}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer: ${sale.customer?.name ?? 'Walk-in'}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Total: \$${sale.totalAmount.toStringAsFixed(2)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (_showCost) ...[
                                      Text(
                                        'Cost: \$${sale.cogs.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        'Profit: \$${sale.profit.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: sale.profit >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                    Text(
                                      'Status: ${sale.getDisplayStatus()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: _getStatusColor(
                                                  sale.status)),
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
