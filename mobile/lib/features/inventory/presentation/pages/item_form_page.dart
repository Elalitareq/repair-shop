import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/services/image_service.dart';

class ItemFormPage extends ConsumerStatefulWidget {
  final int? itemId;

  const ItemFormPage({super.key, this.itemId});

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockLevelController = TextEditingController(text: '5');

  int? _categoryId;
  int? _qualityId;
  int? _conditionId;
  String _itemType = 'other'; // 'phone' or 'other'
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // If editing, load the item
    if (widget.itemId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(itemDetailProvider.notifier).loadItem(widget.itemId!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockLevelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_categoryId == null || _conditionId == null || _qualityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Category, Condition, and Quality'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'name': _nameController.text,
      'brand': _brandController.text.isEmpty ? null : _brandController.text,
      'model': _modelController.text.isEmpty ? null : _modelController.text,
      'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0.0,
      'stockQuantity': int.tryParse(_stockController.text) ?? 0,
      'minStockLevel': int.tryParse(_minStockLevelController.text) ?? 5,
      'itemType': _itemType,
      'qualityId': _qualityId,
      'conditionId': _conditionId,
      'categoryId': _categoryId,
    }..removeWhere((key, value) => value == null);

    final success = widget.itemId == null
        ? await ref.read(itemDetailProvider.notifier).createItem(data)
        : await ref
              .read(itemDetailProvider.notifier)
              .updateItem(widget.itemId!, data);

    if (success && _pickedImage != null) {
      final updatedItem = ref.read(itemDetailProvider).item;
      if (updatedItem != null) {
        final imageService = ref.read(imageServiceProvider);
        await imageService.uploadItemImage(
          itemId: updatedItem.id,
          filePath: _pickedImage!.path,
        );
      }
    }

    setState(() => _isSubmitting = false);

    // Refetch item list so calling pages show the newly created/updated item
    if (success) {
      // Refresh the list explicitly to update UI immediately
      ref.read(itemListProvider.notifier).loadItems(refresh: true);
    }

    if (success) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      final errorMessage =
          ref.read(itemDetailProvider).error ??
          'Failed to ${widget.itemId == null ? 'create' : 'update'} item';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final qualities = ref.watch(qualitiesProvider);
    final conditions = ref.watch(conditionsProvider);
    final itemState = ref.watch(itemDetailProvider);
    final item = itemState.item;

    // Populate form fields when item is loaded for editing
    if (item != null && widget.itemId != null && _nameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _nameController.text = item.name;
          _brandController.text = item.brand;
          _modelController.text = item.model;
          _sellingPriceController.text = item.sellingPrice.toString();
          _stockController.text = item.stockQuantity.toString();
          _minStockLevelController.text = item.minStockLevel.toString();
          _itemType = item.itemType;
          _categoryId = item.categoryId;
          _qualityId = item.qualityId;
          _conditionId = item.conditionId;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId == null ? 'Create Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'Selling Price'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _minStockLevelController,
                decoration: const InputDecoration(
                  labelText: 'Low Stock Alert Level',
                  hintText: 'Alert when stock falls below this',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _itemType,
                decoration: const InputDecoration(
                  labelText: 'Item Type *',
                  helperText:
                      'Phones require serial numbers when adding batches',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'phone',
                    child: Text('Phone (requires serials)'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Other (no serials)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _itemType = value ?? 'other';
                  });
                },
              ),
              const SizedBox(height: 8),
              categories.when(
                data: (cats) => DropdownButtonFormField<int?>(
                  value: _categoryId,
                  items: cats
                      .map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.getFullPath()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    hintText: 'Select a category',
                  ),
                  validator: (v) =>
                      v == null ? 'Please select a category' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              conditions.when(
                data: (conds) => DropdownButtonFormField<int?>(
                  value: _conditionId,
                  items: conds
                      .map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _conditionId = v),
                  decoration: const InputDecoration(
                    labelText: 'Condition *',
                    hintText: 'Select a condition',
                  ),
                  validator: (v) =>
                      v == null ? 'Please select a condition' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              qualities.when(
                data: (qs) => DropdownButtonFormField<int?>(
                  value: _qualityId,
                  items: qs
                      .map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _qualityId = v),
                  decoration: const InputDecoration(
                    labelText: 'Quality *',
                    hintText: 'Select a quality',
                  ),
                  validator: (v) =>
                      v == null ? 'Please select a quality' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                  const SizedBox(width: 16),
                  if (_pickedImage != null)
                    Expanded(
                      child: Image.file(File(_pickedImage!.path), height: 72),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.itemId == null ? 'Create Item' : 'Update Item',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
