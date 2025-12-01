import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/payment_method.dart';
import '../../../../../shared/services/reference_service.dart';
import '../../../../../shared/providers/item_provider.dart';

class PaymentMethodsSettingsPage extends ConsumerWidget {
  const PaymentMethodsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final maxContentWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentMethodDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: methodsAsync.when(
            data: (methods) {
              if (methods.isEmpty) return _buildEmptyState(context);
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 32.0 : 16.0,
                ),
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  final method = methods[index];
                  return _buildMethodCard(context, ref, method);
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
                    onPressed: () => ref.invalidate(paymentMethodsProvider),
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
          Icon(Icons.payment, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No payment methods',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first payment method to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.payment, color: Colors.blue),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: method.description != null ? Text(method.description!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  _showPaymentMethodDialog(context, ref, method: method),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, method),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text(
          'Are you sure you want to delete "${method.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final refService = ref.read(referenceServiceProvider);
              final response = await refService.deletePaymentMethod(method.id);
              if (response.isSuccess && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment method deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(paymentMethodsProvider);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete payment method: ${response.message}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(
    BuildContext context,
    WidgetRef ref, {
    PaymentMethod? method,
  }) {
    final nameController = TextEditingController(text: method?.name ?? '');
    final descriptionController = TextEditingController(
      text: method?.description ?? '',
    );
    final feeController = TextEditingController(
      text: method?.feeRate.toString() ?? '0',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          method == null ? 'Add Payment Method' : 'Edit Payment Method',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Payment Method Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: feeController,
                decoration: const InputDecoration(
                  labelText: 'Fee Rate (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameController.text.trim();
              final feeRate = double.tryParse(feeController.text) ?? 0.0;
              final desc = descriptionController.text.trim();
              Navigator.of(context).pop();
              final refService = ref.read(referenceServiceProvider);
              if (method == null) {
                final resp = await refService.createPaymentMethod(
                  name: name,
                  feeRate: feeRate,
                  description: desc.isNotEmpty ? desc : null,
                );
                if (resp.isSuccess && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment method added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(paymentMethodsProvider);
                }
              } else {
                final resp = await refService.updatePaymentMethod(
                  id: method.id,
                  name: name,
                  feeRate: feeRate,
                  description: desc.isNotEmpty ? desc : null,
                );
                if (resp.isSuccess && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment method updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(paymentMethodsProvider);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
