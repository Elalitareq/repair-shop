import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/providers/issue_type_provider.dart';
import '../../../../../shared/services/repair_service.dart'; // For IssueType model
import '../../../../../shared/services/reference_service.dart';

class IssueTypesSettingsPage extends ConsumerWidget {
  const IssueTypesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueTypesAsync = ref.watch(issueTypesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final maxContentWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Issue Types'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIssueTypeDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Issue Type'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: issueTypesAsync.when(
            data: (response) {
              final issueTypes = response.data ?? [];
              if (issueTypes.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 32.0 : 16.0,
                ),
                itemCount: issueTypes.length,
                itemBuilder: (context, index) {
                  final issueType = issueTypes[index];
                  return _buildIssueTypeCard(context, ref, issueType);
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
                    onPressed: () => ref.invalidate(issueTypesProvider),
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
          Icon(Icons.bug_report_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No issue types yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first issue type to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeCard(
    BuildContext context,
    WidgetRef ref,
    IssueType issueType,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.bug_report, color: Colors.red),
        ),
        title: Text(
          issueType.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: issueType.description != null
            ? Text(
                issueType.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  _showIssueTypeDialog(context, ref, issueType: issueType),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, issueType),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _showIssueTypeDialog(
    BuildContext context,
    WidgetRef ref, {
    IssueType? issueType,
  }) {
    final nameController = TextEditingController(text: issueType?.name ?? '');
    final descriptionController = TextEditingController(
      text: issueType?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(issueType == null ? 'Add Issue Type' : 'Edit Issue Type'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Issue Type Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);

                final referenceService = ref.read(referenceServiceProvider);
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                try {
                  if (issueType == null) {
                    // Create new issue type
                    final response = await referenceService.createIssueType(
                      name: name,
                      description: description.isNotEmpty ? description : null,
                    );

                    if (!context.mounted) return;

                    if (response.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Issue type added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      ref.invalidate(issueTypesProvider);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add issue type: ${response.message}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    // Update existing issue type
                    final response = await referenceService.updateIssueType(
                      id: issueType.id,
                      name: name,
                      description: description.isNotEmpty ? description : null,
                    );

                    if (!context.mounted) return;

                    if (response.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Issue type updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      ref.invalidate(issueTypesProvider);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update issue type: ${response.message}',
                          ),
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
              }
            },
            child: Text(issueType == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    IssueType issueType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Issue Type'),
        content: Text(
          'Are you sure you want to delete "${issueType.name}"?\n\nThis action cannot be undone.',
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
                final response = await referenceService.deleteIssueType(
                  issueType.id,
                );

                if (!context.mounted) return;

                if (response.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue type deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.invalidate(issueTypesProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete issue type: ${response.message}',
                      ),
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
}
