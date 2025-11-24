import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/services/serial_service.dart';

class BatchFormPage extends ConsumerStatefulWidget {
  final int? itemId; // null when editing existing batch
  final int? batchId; // null for create, not null for edit

  const BatchFormPage({super.key, this.itemId, this.batchId});

  @override
  ConsumerState<BatchFormPage> createState() => _BatchFormPageState();
}

class _BatchFormPageState extends ConsumerState<BatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _totalQuantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  bool _isSubmitting = false;

  // Product type will be loaded from item
  String? _productType;

  // Serial numbers list
  final List<String> _serialNumbers = [];
  final _serialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load item to get its type only when creating (itemId is provided)
    if (widget.itemId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(itemDetailProvider.notifier).loadItem(widget.itemId!);
      });
    }

    // If editing, load the batch
    if (widget.batchId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(batchDetailProvider.notifier).loadBatch(widget.batchId!);
      });
    }
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _supplierIdController.dispose();
    _totalQuantityController.dispose();
    _unitCostController.dispose();
    _notesController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _addSerial() {
    if (_serialController.text.isNotEmpty) {
      setState(() {
        _serialNumbers.add(_serialController.text);
        _serialController.clear();
      });
    }
  }

  void _removeSerial(int index) {
    setState(() {
      _serialNumbers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalQuantity = int.tryParse(_totalQuantityController.text) ?? 0;

    // Validate serial numbers match quantity only for phones and only when creating
    if (_productType == 'phone' &&
        widget.batchId == null &&
        _serialNumbers.length != totalQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add $totalQuantity serial numbers (currently ${_serialNumbers.length})',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final unitCost = double.tryParse(_unitCostController.text) ?? 0.0;
    final totalCost = totalQuantity * unitCost;

    final data = {
      'batch_number': _batchNumberController.text,
      'supplier_id': int.tryParse(_supplierIdController.text) ?? 1,
      'purchase_date': _purchaseDate.toIso8601String(),
      'total_quantity': totalQuantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
    };

    final success = widget.batchId == null
        ? await ref.read(batchDetailProvider.notifier).createBatch(data)
        : await ref
              .read(batchDetailProvider.notifier)
              .updateBatch(widget.batchId!, data);

    if (success) {
      // Get the created/updated batch
      final batch = ref.read(batchDetailProvider).batch;

      if (batch != null && _productType == 'phone' && widget.batchId == null) {
        // Create serials for phones only when creating
        final serialService = ref.read(serialServiceProvider);
        int successCount = 0;

        for (final imei in _serialNumbers) {
          final result = await serialService.createSerial({
            'imei': imei,
            'item_id': widget.itemId ?? 0, // This shouldn't happen for editing
            'batch_id': batch.batch.id,
            'status': 'available',
          });
          if (result.isSuccess) successCount++;
        }

        setState(() => _isSubmitting = false);

        // Refresh item list to show updated stock
        ref.invalidate(itemListProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Batch ${widget.batchId == null ? 'created' : 'updated'} with $successCount/${_serialNumbers.length} serials',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => _isSubmitting = false);
        // Refresh item list to show updated stock
        ref.invalidate(itemListProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Batch ${widget.batchId == null ? 'created' : 'updated'} successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } else {
      setState(() => _isSubmitting = false);
      final error = ref.read(batchDetailProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ??
                  'Failed to ${widget.batchId == null ? 'create' : 'update'} batch',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemDetailProvider);
    final batchState = ref.watch(batchDetailProvider);
    final item = itemState.item;
    final batch = batchState.batch;

    // Set product type from item when loaded (for creating)
    if (item != null && _productType == null && widget.batchId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _productType = item.itemType;
        });
      });
    }

    // Set product type from batch when loaded (for editing)
    if (batch != null && _productType == null && widget.batchId != null) {
      // For editing, we need to get the item type from the batch's item
      // Since we don't have the item loaded, we'll assume it's available in the batch data
      // For now, let's check if the batch has serials to determine if it's a phone
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _productType =
              batch.batch.serials != null && batch.batch.serials!.isNotEmpty
              ? 'phone'
              : 'other';
        });
      });
    }

    // Populate form fields when batch is loaded for editing
    if (batch != null &&
        widget.batchId != null &&
        _batchNumberController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _batchNumberController.text = batch.batch.batchNumber;
          _supplierIdController.text = batch.batch.supplierId.toString();
          _purchaseDate = batch.batch.purchaseDate;
          _totalQuantityController.text = batch.batch.totalQuantity.toString();
          _unitCostController.text = batch.batch.costPerUnit.toStringAsFixed(2);
          _notesController.text = batch.batch.notes ?? '';
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batchId == null ? 'Add Batch' : 'Edit Batch'),
      ),
      body: _productType == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Show item type info
                    Card(
                      color: _productType == 'phone'
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              _productType == 'phone'
                                  ? Icons.phone_android
                                  : Icons.inventory_2,
                              color: _productType == 'phone'
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _productType == 'phone'
                                    ? 'Phone Item - Serial numbers required'
                                    : 'Other Item - Serial numbers not required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _productType == 'phone'
                                      ? Colors.blue.shade900
                                      : Colors.grey.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number',
                        hintText: 'e.g., BATCH-001',
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Batch number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _supplierIdController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier ID',
                        hintText: 'Enter supplier ID',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Supplier ID is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Purchase Date'),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(_purchaseDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Total Quantity',
                        hintText: 'Number of items in this batch',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Quantity is required';
                        if (int.tryParse(v) == null || int.parse(v) <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitCostController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Cost',
                        hintText: 'Cost per unit',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Unit cost is required';
                        if (double.tryParse(v) == null ||
                            double.parse(v) <= 0) {
                          return 'Enter a valid cost';
                        }
                        return null;
                      },
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    if (_totalQuantityController.text.isNotEmpty &&
                        _unitCostController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Total Cost: \$${((int.tryParse(_totalQuantityController.text) ?? 0) * (double.tryParse(_unitCostController.text) ?? 0.0)).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Additional information about this batch',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    // Hide serial section when editing
                    if (_productType == 'phone' && widget.batchId == null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Serial Numbers (IMEIs)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add ${_totalQuantityController.text.isEmpty ? "0" : _totalQuantityController.text} serial numbers (${_serialNumbers.length} added)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              _serialNumbers.length ==
                                  (int.tryParse(
                                        _totalQuantityController.text,
                                      ) ??
                                      0)
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _serialController,
                              decoration: const InputDecoration(
                                labelText: 'Serial Number / IMEI',
                                hintText: 'Enter IMEI',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addSerial(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _addSerial,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_serialNumbers.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _serialNumbers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(_serialNumbers[index]),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeSerial(index),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.batchId == null
                                  ? 'Create Batch'
                                  : 'Update Batch',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
