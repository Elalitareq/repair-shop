import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/item_provider.dart';

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

    if (state.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    final item = state.item;
    if (item == null) return const Scaffold(body: Center(child: Text('Item not found')));

    return Scaffold(
      appBar: AppBar(title: Text(item.displayName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(title: const Text('Name'), subtitle: Text(item.displayName)),
            ListTile(title: const Text('Brand'), subtitle: Text(item.brand ?? '')), 
            ListTile(title: const Text('Model'), subtitle: Text(item.model ?? '')),
            ListTile(title: const Text('IMEI'), subtitle: Text(item.imei ?? '')),
            ListTile(title: const Text('Stock'), subtitle: Text(item.stockQuantity.toString())),
            // TODO: show images and actions
          ],
        ),
      ),
    );
  }
}
