import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/serial_provider.dart';

class SerialListPage extends ConsumerStatefulWidget {
  final int? itemId;
  final int? batchId;

  const SerialListPage({super.key, this.itemId, this.batchId});

  @override
  ConsumerState<SerialListPage> createState() => _SerialListPageState();
}

class _SerialListPageState extends ConsumerState<SerialListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(serialListProvider.notifier)
          .loadSerials(
            itemId: widget.itemId,
            batchId: widget.batchId,
            refresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serialListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Numbers'),
        actions: [
          if (widget.itemId != null || widget.batchId != null)
            IconButton(
              icon: const Icon(Icons.filter_list_off),
              onPressed: () {
                ref
                    .read(serialListProvider.notifier)
                    .loadSerials(refresh: true);
              },
              tooltip: 'Show all serials',
            ),
        ],
      ),
      body: state.isLoading && state.serials.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(serialListProvider.notifier)
                    .loadSerials(
                      itemId: widget.itemId,
                      batchId: widget.batchId,
                      refresh: true,
                    );
              },
              child: ListView.builder(
                itemCount: state.serials.length,
                itemBuilder: (context, index) {
                  final serial = state.serials[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(serial.imei),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Item ID: ${serial.itemId}'),
                          Text('Batch ID: ${serial.batchId}'),
                          Text(
                            'Status: ${serial.status}',
                            style: TextStyle(
                              color: _getStatusColor(serial.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        _getStatusIcon(serial.status),
                        color: _getStatusColor(serial.status),
                      ),
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed('/inventory/serials/${serial.id}'),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/inventory/serials/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.blue;
      case 'damaged':
        return Colors.red;
      case 'lost':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'sold':
        return Icons.shopping_cart;
      case 'damaged':
        return Icons.warning;
      case 'lost':
        return Icons.location_off;
      default:
        return Icons.help;
    }
  }
}
