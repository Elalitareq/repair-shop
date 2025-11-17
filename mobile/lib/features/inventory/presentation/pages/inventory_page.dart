import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/item.dart';
import '../../../../shared/providers/item_provider.dart';

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
            if (item.imei != null) Text('IMEI: ${item.imei}'),
            Text(
              'Stock: ${item.stockQuantity} • Cost: \$${item.unitCost.toStringAsFixed(2)}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleItemAction(context, item, value),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(
              value: 'adjust_stock',
              child: Text('Adjust Stock'),
            ),
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(
                  value: 'All',
                  child: Text('All Categories'),
                ),
                // Add category items here when categories are loaded
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'All';
                });
              },
            ),

            // Condition filter
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: [
                const DropdownMenuItem(
                  value: 'All',
                  child: Text('All Conditions'),
                ),
                // Add condition items here when conditions are loaded
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value ?? 'All';
                });
              },
            ),

            // Quality filter
            DropdownButtonFormField<String>(
              value: _selectedQuality,
              decoration: const InputDecoration(labelText: 'Quality'),
              items: [
                const DropdownMenuItem(
                  value: 'All',
                  child: Text('All Qualities'),
                ),
                // Add quality items here when qualities are loaded
              ],
              onChanged: (value) {
                setState(() {
                  _selectedQuality = value ?? 'All';
                });
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
      case 'adjust_stock':
        _showAdjustStockDialog(context, item);
        break;
      case 'delete':
        _showDeleteConfirmation(context, item);
        break;
    }
  }

  void _showAdjustStockDialog(BuildContext context, Item item) {
    final TextEditingController quantityController = TextEditingController();
    String adjustmentType = 'add'; // 'add' or 'subtract'

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Stock for ${item.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${item.stockQuantity}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: adjustmentType,
              decoration: const InputDecoration(labelText: 'Adjustment Type'),
              items: const [
                DropdownMenuItem(value: 'add', child: Text('Add to Stock')),
                DropdownMenuItem(
                  value: 'subtract',
                  child: Text('Subtract from Stock'),
                ),
              ],
              onChanged: (value) {
                adjustmentType = value ?? 'add';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity to adjust',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                final newQuantity = adjustmentType == 'add'
                    ? item.stockQuantity + quantity
                    : item.stockQuantity - quantity;

                if (newQuantity >= 0) {
                  final success = await ref
                      .read(itemDetailProvider.notifier)
                      .adjustStock(itemId: item.id, quantity: newQuantity);
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stock adjusted successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to adjust stock')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot reduce stock below zero'),
                    ),
                  );
                }
              }
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
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
