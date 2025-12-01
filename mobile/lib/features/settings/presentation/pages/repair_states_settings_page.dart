import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/providers/item_provider.dart';
import '../../../../../shared/models/repair.dart';
import '../../../../../shared/services/reference_service.dart';

class RepairStatesSettingsPage extends ConsumerWidget {
  const RepairStatesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statesAsync = ref.watch(repairStatesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final maxContentWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Repair States'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Repair State'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: statesAsync.when(
            data: (states) {
              if (states.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 32.0 : 16.0,
                ),
                itemCount: states.length,
                itemBuilder: (context, index) {
                  final state = states[index];
                  return _buildStateCard(context, ref, state);
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
                    onPressed: () => ref.invalidate(repairStatesProvider),
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
          Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No repair states yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first state to represent the workflow',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard(
    BuildContext context,
    WidgetRef ref,
    RepairState state,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_circle, color: Colors.blue),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                state.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Order: ${state.order}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: state.description != null
            ? Text(
                state.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showStateDialog(context, ref, state: state),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, state),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _showStateDialog(
    BuildContext context,
    WidgetRef ref, {
    RepairState? state,
  }) {
    final nameController = TextEditingController(text: state?.name ?? '');
    final descriptionController = TextEditingController(
      text: state?.description ?? '',
    );
    final orderController = TextEditingController(
      text: state?.order.toString() ?? '0',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(state == null ? 'Add Repair State' : 'Edit Repair State'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'State Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: orderController,
                decoration: const InputDecoration(
                  labelText: 'Order',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null)
                    ? 'Enter a valid integer'
                    : null,
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);

              final referenceService = ref.read(referenceServiceProvider);
              final String name = nameController.text.trim();
              final String description = descriptionController.text.trim();
              final int order = int.tryParse(orderController.text.trim()) ?? 0;

              try {
                if (state == null) {
                  final response = await referenceService.createRepairState(
                    name: name,
                    description: description.isNotEmpty ? description : null,
                    order: order,
                  );
                  if (!context.mounted) return;
                  if (response.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Repair state added'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    ref.invalidate(repairStatesProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add: ${response.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  final response = await referenceService.updateRepairState(
                    id: state.id,
                    name: name,
                    description: description.isNotEmpty ? description : null,
                    order: order,
                  );
                  if (!context.mounted) return;
                  if (response.isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Repair state updated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    ref.invalidate(repairStatesProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: ${response.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(state == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, RepairState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete State'),
        content: Text(
          'Are you sure you want to delete "${state.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final referenceService = ref.read(referenceServiceProvider);
              try {
                final response = await referenceService.deleteRepairState(
                  state.id,
                );
                if (!context.mounted) return;
                if (response.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Repair state deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(repairStatesProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: ${response.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
