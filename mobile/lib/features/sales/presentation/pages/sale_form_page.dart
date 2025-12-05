import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/sale_provider.dart';
import '../../../../shared/widgets/customer_search_selector.dart';
import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/models/models.dart';

class SaleFormPage extends ConsumerStatefulWidget {
  const SaleFormPage({super.key});

  @override
  ConsumerState<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends ConsumerState<SaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _barcodeFocusNode = FocusNode();
  final List<SaleItemData> _saleItems = [];
  Customer? _selectedCustomer;
  String? _discountType;
  double? _discountValue;
  double? _taxRate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemListProvider.notifier).loadItems(refresh: true);
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeSubmit(String value) async {
    if (value.isEmpty) return;

    // Show loading?
    final response = await ref.read(itemServiceProvider).searchItems(value);

    if (response.isSuccess &&
        response.data != null &&
        response.data!.isNotEmpty) {
      final items = response.data!;
      // Ideally exact match for barcode/IMEI should be first or unique
      // For now, take the first one
      final item = items.first;
      _addItem(item);
      _barcodeController.clear();
      // Keep focus for next scan
      _barcodeFocusNode.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item not found for: $value'),
          backgroundColor: Colors.orange,
        ),
      );
      // Keep focus even on error to allow retry
      _barcodeFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemListProvider);
    final formState = ref.watch(saleFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/sales'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (formState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitSale,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Barcode Scanner Input
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _barcodeController,
                  focusNode: _barcodeFocusNode,
                  autofocus: true, // Auto-focus for scanning
                  decoration: const InputDecoration(
                    labelText: 'Scan Barcode / IMEI',
                    hintText: 'Scan item to add to cart',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _handleBarcodeSubmit,
                  textInputAction: TextInputAction.go,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Customer selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomerSearchSelector(
                  selectedCustomer: _selectedCustomer,
                  onCustomerSelected: (c) =>
                      setState(() => _selectedCustomer = c),
                  showAddButton: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Items Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddItemDialog(itemState.items),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_saleItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No items added yet'),
                        ),
                      )
                    else
                      ..._saleItems.map((item) => _buildSaleItemTile(item)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Discount and Tax
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discount & Tax',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _discountType,
                            decoration: const InputDecoration(
                              labelText: 'Discount Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'percentage',
                                child: Text('Percentage'),
                              ),
                              DropdownMenuItem(
                                value: 'fixed',
                                child: Text('Fixed Amount'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _discountType = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: _discountType == 'percentage'
                                  ? '%'
                                  : '\$',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(
                                () => _discountValue = double.tryParse(value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tax Rate (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() => _taxRate = double.tryParse(value));
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total Summary
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', _calculateSubtotal()),
                    if (_discountValue != null) ...[
                      _buildTotalRow('Discount', -_calculateDiscount()),
                    ],
                    if (_taxRate != null) ...[
                      _buildTotalRow('Tax', _calculateTax()),
                    ],
                    const Divider(),
                    _buildTotalRow('Total', _calculateTotal(), isBold: true),
                  ],
                ),
              ),
            ),

            if (formState.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    formState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaleItemTile(SaleItemData item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => _showEditPriceDialog(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Price: \$${item.unitPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: item.quantity > 1
                      ? () => _updateItemQuantity(item, item.quantity - 1)
                      : null,
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateItemQuantity(item, item.quantity + 1),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(List<Item> availableItems) {
    showDialog(
      context: context,
      builder: (context) {
        bool showCost = false;
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredItems = availableItems.where((item) {
              final query = searchQuery.toLowerCase();
              return (item.name.toLowerCase().contains(query)) ||
                  (item.brand.toLowerCase().contains(query)) ||
                  (item.model.toLowerCase().contains(query));
            }).toList();

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Item'),
                  IconButton(
                    icon: Icon(
                      showCost ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        showCost = !showCost;
                      });
                    },
                    tooltip: showCost ? 'Hide Costs' : 'Show Costs',
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400, // Increased height for search field
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Items',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final price = item.sellingPrice ?? 0.0;
                          final cost = item.lastBatchPrice;
                          final profit = price - cost;

                          return ListTile(
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock: ${item.stockQuantity} • Price: \$${price.toStringAsFixed(2)}',
                                ),
                                if (showCost) ...[
                                  Text(
                                    'Cost: \$${cost.toStringAsFixed(2)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Profit: \$${profit.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: profit >= 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showItemDetailsDialog(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showItemDetailsDialog(Item item) {
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: (item.sellingPrice ?? 0.0).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
              final qty = int.tryParse(quantityController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 0.0;

              _addItem(item, quantity: qty, price: price);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem(Item item, {int quantity = 1, double? price}) {
    final existingIndex = _saleItems.indexWhere((si) => si.item.id == item.id);
    if (existingIndex >= 0) {
      // If item exists, just update quantity (keep existing price or update it?)
      // User might want to add more with different price?
      // Usually in a simple cart, we just update quantity.
      // If price is different, maybe we should update the price to the new one?
      // Let's update both.
      _saleItems[existingIndex] = _saleItems[existingIndex].copyWith(
        quantity: _saleItems[existingIndex].quantity + quantity,
        unitPrice: price ?? _saleItems[existingIndex].unitPrice,
      );
      setState(() {});
    } else {
      setState(() {
        _saleItems.add(
          SaleItemData(
            item: item,
            quantity: quantity,
            unitPrice: price ?? item.sellingPrice ?? 0.0,
            discount: 0,
          ),
        );
      });
    }
  }

  void _updateItemQuantity(SaleItemData item, int quantity) {
    setState(() {
      final index = _saleItems.indexOf(item);
      if (index >= 0) {
        _saleItems[index] = item.copyWith(quantity: quantity);
      }
    });
  }

  void _updateItemPrice(SaleItemData item, double price) {
    setState(() {
      final index = _saleItems.indexOf(item);
      if (index >= 0) {
        _saleItems[index] = item.copyWith(unitPrice: price);
      }
    });
  }

  void _showEditPriceDialog(SaleItemData item) {
    final priceController = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Price: ${item.item.name}'),
        content: TextField(
          controller: priceController,
          decoration: const InputDecoration(
            labelText: 'New Unit Price',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price >= 0) {
                _updateItemPrice(item, price);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _removeItem(SaleItemData item) {
    setState(() {
      _saleItems.remove(item);
    });
  }

  double _calculateSubtotal() {
    return _saleItems.fold(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  double _calculateDiscount() {
    if (_discountType == null || _discountValue == null) return 0;
    final subtotal = _calculateSubtotal();
    return _discountType == 'percentage'
        ? subtotal * (_discountValue! / 100)
        : _discountValue!;
  }

  double _calculateTax() {
    if (_taxRate == null) return 0;
    final subtotal = _calculateSubtotal();
    final discount = _calculateDiscount();
    return (subtotal - discount) * (_taxRate! / 100);
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final discount = _calculateDiscount();
    final tax = _calculateTax();
    return subtotal - discount + tax;
  }

  void _submitSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final items = _saleItems
        .map(
          (item) => {
            'itemId': item.item.id,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'discount': item.discount,
          },
        )
        .toList();

    final sale = await ref
        .read(saleFormProvider.notifier)
        .createSale(
          items: items,
          discountType: _discountType,
          discountValue: _discountValue,
          taxRate: _taxRate,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          customerId: _selectedCustomer?.id,
        );

    if (sale != null) {
      if (mounted) {
        context.go('/sales'); // Go back to sales list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale ${sale.saleNumber ?? 'N/A'} created successfully',
            ),
          ),
        );
      }
    }
  }
}

// Helper class for sale form data
class SaleItemData {
  final Item item;
  final int quantity;
  final double unitPrice;
  final double discount;

  const SaleItemData({
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });

  SaleItemData copyWith({
    Item? item,
    int? quantity,
    double? unitPrice,
    double? discount,
  }) {
    return SaleItemData(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }
}
