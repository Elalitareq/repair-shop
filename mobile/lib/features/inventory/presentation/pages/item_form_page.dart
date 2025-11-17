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
  final _imeiController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _stockController = TextEditingController();

  int? _categoryId;
  int? _qualityId;
  int? _conditionId;
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _imeiController.dispose();
    _unitCostController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'name': _nameController.text,
      'brand': _brandController.text,
      'model': _modelController.text,
      'imei': _imeiController.text.isNotEmpty ? _imeiController.text : null,
      'unit_cost': double.tryParse(_unitCostController.text) ?? 0.0,
      'stock_quantity': int.tryParse(_stockController.text) ?? 0,
      'category_id': _categoryId,
      'quality_id': _qualityId,
      'condition_id': _conditionId,
    }..removeWhere((key, value) => value == null);

    final success = await ref.read(itemDetailProvider.notifier).createItem(data);

    if (success && _pickedImage != null) {
      final createdItem = ref.read(itemDetailProvider).item;
      if (createdItem != null) {
        final imageService = ref.read(imageServiceProvider);
        await imageService.uploadItemImage(itemId: createdItem.id, filePath: _pickedImage!.path);
      }
    }

    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final qualities = ref.watch(qualitiesProvider);
    final conditions = ref.watch(conditionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Item')),
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
              TextFormField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand')),
              const SizedBox(height: 8),
              TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model')),
              const SizedBox(height: 8),
              TextFormField(controller: _imeiController, decoration: const InputDecoration(labelText: 'IMEI')),
              const SizedBox(height: 8),
              TextFormField(controller: _unitCostController, decoration: const InputDecoration(labelText: 'Unit Cost'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock Quantity'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              categories.when(
                data: (cats) => DropdownButtonFormField<int?>(
                  value: _categoryId,
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('No Category (default)'))
                  ] + cats.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.getFullPath()))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              conditions.when(
                data: (conds) => DropdownButtonFormField<int?>(
                  value: _conditionId,
                    items: [const DropdownMenuItem<int?>(value: null, child: Text('Default'))] +
                      conds.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _conditionId = v),
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              qualities.when(
                data: (qs) => DropdownButtonFormField<int?>(
                  value: _qualityId,
                    items: [const DropdownMenuItem<int?>(value: null, child: Text('Default'))] +
                      qs.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _qualityId = v),
                  decoration: const InputDecoration(labelText: 'Quality'),
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
                    Expanded(child: Image.file(File(_pickedImage!.path), height: 72)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Create Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
