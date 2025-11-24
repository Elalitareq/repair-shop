import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/providers/item_provider.dart';
import '../../../../../shared/models/category.dart';
import '../../../../../shared/services/category_service.dart';

class CategoriesSettingsPage extends ConsumerStatefulWidget {
  const CategoriesSettingsPage({super.key});

  @override
  ConsumerState<CategoriesSettingsPage> createState() =>
      _CategoriesSettingsPageState();
}

class _CategoriesSettingsPageState
    extends ConsumerState<CategoriesSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final maxContentWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 32.0 : 16.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(context, category);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(categoriesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first category to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.category, color: Colors.purple),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showCategoryDialog(context, category: category),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, category),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _saveCategory(
                  context,
                  category: category,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isNotEmpty
                      ? descriptionController.text.trim()
                      : null,
                );
              }
            },
            child: Text(category == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(
    BuildContext context, {
    Category? category,
    required String name,
    String? description,
  }) async {
    try {
      final categoryService = ref.read(categoryServiceProvider);

      if (category == null) {
        // Create new category
        final response = await categoryService.createCategory(
          name: name,
          description: description,
        );

        if (!response.isSuccess) {
          throw Exception(response.message);
        }
      } else {
        // Update existing category
        final response = await categoryService.updateCategory(
          id: category.id,
          name: name,
          description: description,
        );

        if (!response.isSuccess) {
          throw Exception(response.message);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              category == null
                  ? 'Category added successfully'
                  : 'Category updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(categoriesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(context, category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, Category category) async {
    try {
      final categoryService = ref.read(categoryServiceProvider);
      final response = await categoryService.deleteCategory(category.id);

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(categoriesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
