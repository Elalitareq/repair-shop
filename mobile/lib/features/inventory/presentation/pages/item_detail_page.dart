import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/services/serial_service.dart';
import 'batch_form_page.dart';
// Serial model used by provider in item_provider.dart

class ItemDetailPage extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends ConsumerState<ItemDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.itemId);
      if (id != null) {
        ref.read(itemDetailProvider.notifier).loadItem(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemDetailProvider);

    if (state.isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    final item = state.item;
    if (item == null)
      return const Scaffold(body: Center(child: Text('Item not found')));

    return Scaffold(
      appBar: AppBar(title: Text(item.displayName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Name'),
              subtitle: Text(item.displayName),
            ),
            ListTile(
              title: const Text('Brand'),
              subtitle: Text(item.brand ?? ''),
            ),
            ListTile(
              title: const Text('Model'),
              subtitle: Text(item.model ?? ''),
            ),
            const SizedBox.shrink(),
            // Show serials associated with item
            Consumer(
              builder: (context, ref, _) {
                final serialsAsync = ref.watch(serialsForItemProvider(item.id));
                return serialsAsync.when(
                  data: (serials) => ExpansionTile(
                    title: const Text('Serials'),
                    children: serials
                        .map(
                          (s) => ListTile(
                            title: Text(s.imei),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (s.batch != null)
                                  Text('Batch: ${s.batch?.batchNumber ?? ''}'),
                                Text('Status: ${s.status}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final service = ref.read(serialServiceProvider);
                                final resp = await service.deleteSerial(s.id);
                                if (resp.isSuccess) {
                                  ref.invalidate(
                                    serialsForItemProvider(item.id),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(resp.message)),
                                  );
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BatchFormPage(itemId: item.id),
                  ),
                );
                if (result == true) {
                  // Refresh item details and serials
                  ref.read(itemDetailProvider.notifier).loadItem(item.id);
                  ref.invalidate(serialsForItemProvider(item.id));
                }
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('Add Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final imeiAndBatch = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) {
                    final _controller = TextEditingController();
                    int? selectedBatchId;

                    return AlertDialog(
                      title: const Text('Add Serial (IMEI)'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(hintText: 'IMEI'),
                          ),
                          const SizedBox(height: 12),
                          Consumer(
                            builder: (context, ref, _) {
                              final batchesAsync = ref.watch(batchesProvider);
                              return batchesAsync.when(
                                data: (batches) =>
                                    DropdownButtonFormField<int?>(
                                      value: selectedBatchId,
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text(
                                            'Select a Batch (required)',
                                          ),
                                        ),
                                        ...batches
                                            .map(
                                              (b) => DropdownMenuItem<int?>(
                                                value: b.batch.id,
                                                child: Text(
                                                  b.batch.batchNumber,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ],
                                      onChanged: (v) => selectedBatchId = v,
                                      decoration: const InputDecoration(
                                        labelText: 'Batch',
                                      ),
                                    ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop({
                            'imei': _controller.text,
                            'batchId': selectedBatchId,
                          }),
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );

                final imei = imeiAndBatch?['imei'] as String?;
                final batchIdSelected = imeiAndBatch?['batchId'] as int?;

                if (imei != null &&
                    imei.isNotEmpty &&
                    batchIdSelected != null) {
                  final service = ref.read(serialServiceProvider);
                  final resp = await service.createSerial({
                    'imei': imei,
                    'itemId': item.id,
                    'batchId': batchIdSelected,
                  });

                  if (resp.isSuccess) {
                    // refresh serial list
                    ref.invalidate(serialsForItemProvider(item.id));
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(resp.message)));
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Serial'),
            ),
            ListTile(
              title: const Text('Stock'),
              subtitle: Text(item.stockQuantity.toString()),
            ),
            // TODO: show images and actions
          ],
        ),
      ),
    );
  }
}
