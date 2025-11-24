import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/item.dart';
import '../../../../shared/providers/item_provider.dart';
import 'batch_form_page.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _selectedQuality = 'All';
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    // Load items when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemListProvider.notifier).loadItems(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemListState = ref.watch(itemListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => context.go('/inventory/batches'),
            icon: const Icon(Icons.view_list),
            tooltip: 'Batches',
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
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: _performSearch,
            ),
          ),

          // Low stock toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Show low stock only'),
                const Spacer(),
                Switch(
                  value: _showLowStockOnly,
                  onChanged: (value) {
                    setState(() {
                      _showLowStockOnly = value;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: itemListState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : itemListState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${itemListState.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(itemListProvider.notifier)
                              .loadItems(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : itemListState.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No items found'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(itemListProvider.notifier)
                        .loadItems(refresh: true),
                    child: ListView.builder(
                      itemCount: itemListState.items.length,
                      itemBuilder: (context, index) {
                        final item = itemListState.items[index];
                        return _buildItemCard(context, item);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/inventory/items/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final isLowStock = item.isLowStock;
    final isOutOfStock = item.isOutOfStock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOutOfStock
              ? Colors.red
              : isLowStock
              ? Colors.orange
              : Colors.green,
          child: Text(
            item.stockQuantity.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(
          item.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.category?.name ?? 'No Category'} • ${item.condition?.name ?? 'No Condition'}',
            ),
            Text('Quality: ${item.quality?.name ?? 'No Quality'}'),
            if (item.brand != null || item.model != null)
              Text('${item.brand ?? ''} ${item.model ?? ''}'.trim()),
            // IMEI moved to Serial model - we display serials on item details
            Text(
              'Stock: ${item.stockQuantity} • Price: \$${item.sellingPrice?.toStringAsFixed(2) ?? "N/A"}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleItemAction(context, item, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'add_batch', child: Text('Add Batch')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => context.go('/inventory/items/${item.id}'),
      ),
    );
  }

  void _performSearch(String query) {
    ref.read(itemListProvider.notifier).searchItems(query);
  }

  void _applyFilters() {
    ref
        .read(itemListProvider.notifier)
        .loadItems(
          categoryId: _selectedCategory != 'All'
              ? int.tryParse(_selectedCategory)
              : null,
          lowStock: _showLowStockOnly,
          refresh: true,
        );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category filter
            Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(categoriesProvider);
                return categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(
                          value: c.id.toString(),
                          child: Text(c.getFullPath()),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'All';
                      });
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'All';
                      });
                    },
                  ),
                );
              },
            ),

            // Condition filter
            Consumer(
              builder: (context, ref, _) {
                final condAsync = ref.watch(conditionsProvider);
                return condAsync.when(
                  data: (conds) => DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: const InputDecoration(labelText: 'Condition'),
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Conditions'),
                      ),
                      ...conds.map(
                        (c) => DropdownMenuItem(
                          value: c.id.toString(),
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value ?? 'All';
                      });
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: const InputDecoration(labelText: 'Condition'),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Conditions'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value ?? 'All';
                      });
                    },
                  ),
                );
              },
            ),

            // Quality filter
            Consumer(
              builder: (context, ref, _) {
                final qualsAsync = ref.watch(qualitiesProvider);
                return qualsAsync.when(
                  data: (quals) => DropdownButtonFormField<String>(
                    value: _selectedQuality,
                    decoration: const InputDecoration(labelText: 'Quality'),
                    items: [
                      const DropdownMenuItem(
                        value: 'All',
                        child: Text('All Qualities'),
                      ),
                      ...quals.map(
                        (q) => DropdownMenuItem(
                          value: q.id.toString(),
                          child: Text(q.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedQuality = value ?? 'All';
                      });
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => DropdownButtonFormField<String>(
                    value: _selectedQuality,
                    decoration: const InputDecoration(labelText: 'Quality'),
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All Qualities'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedQuality = value ?? 'All';
                      });
                    },
                  ),
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
            onPressed: () {
              _applyFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _handleItemAction(BuildContext context, Item item, String action) {
    switch (action) {
      case 'edit':
        context.go('/inventory/items/${item.id}/edit');
        break;
      case 'view':
        context.go('/inventory/items/${item.id}');
        break;
      case 'add_batch':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BatchFormPage(itemId: item.id),
          ),
        ).then((result) {
          if (result == true) {
            ref.read(itemListProvider.notifier).loadItems(refresh: true);
          }
        });
        break;
      case 'delete':
        _showDeleteConfirmation(context, item);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.displayName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await ref
                  .read(itemDetailProvider.notifier)
                  .deleteItem(item.id);
              Navigator.of(context).pop();
              if (success) {
                // Reload the item list after deletion
                ref.read(itemListProvider.notifier).loadItems(refresh: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete item')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
