import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/sale_provider.dart';
import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/models/models.dart';

class SaleFormPage extends ConsumerStatefulWidget {
  const SaleFormPage({super.key});

  @override
  ConsumerState<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends ConsumerState<SaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<SaleItemData> _saleItems = [];
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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemListProvider);
    final formState = ref.watch(saleFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
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
            TextButton(onPressed: _submitSale, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                  Text(
                    'Price: \$${item.unitPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              final item = availableItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'Stock: ${item.stockQuantity} • Price: \$${item.sellingPrice}',
                ),
                onTap: () {
                  _addItem(item);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addItem(Item item) {
    final existingIndex = _saleItems.indexWhere((si) => si.item.id == item.id);
    if (existingIndex >= 0) {
      _updateItemQuantity(
        _saleItems[existingIndex],
        _saleItems[existingIndex].quantity + 1,
      );
    } else {
      setState(() {
        _saleItems.add(
          SaleItemData(
            item: item,
            quantity: 1,
            unitPrice: item.sellingPrice ?? 0.0,
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
            'item_id': item.item.id,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
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
        );

    if (sale != null) {
      if (mounted) {
        Navigator.of(context).pop(); // Go back to sales list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale ${sale.saleNumber} created successfully'),
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
