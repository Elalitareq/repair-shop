import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/repair.dart';
import '../../../../shared/models/customer.dart';
import '../../../../shared/providers/repair_provider.dart';
import '../../../../shared/providers/item_provider.dart';
import '../../../../shared/providers/issue_type_provider.dart';
import '../../../../shared/services/repair_service.dart';
import '../../../../shared/widgets/customer_search_selector.dart';

class RepairFormPage extends ConsumerStatefulWidget {
  final String? repairId;

  const RepairFormPage({super.key, this.repairId});

  bool get isEditing => repairId != null;

  @override
  ConsumerState<RepairFormPage> createState() => _RepairFormPageState();
}

class _RepairFormPageState extends ConsumerState<RepairFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _deviceTypeController = TextEditingController();
  final _deviceModelController = TextEditingController();
  final _deviceSerialController = TextEditingController();
  final _problemDescriptionController = TextEditingController();
  final _diagnosisNotesController = TextEditingController();
  final _repairNotesController = TextEditingController();
  final _estimatedCostController = TextEditingController(text: '0.00');
  final _serviceChargeController = TextEditingController(text: '0.00');
  final _finalCostController = TextEditingController();
  final _warrantyDaysController = TextEditingController();

  Customer? _selectedCustomer;
  String _selectedPriority = 'normal';
  int? _selectedStateId;
  DateTime? _estimatedCompletion;
  DateTime? _actualCompletion;
  bool _warrantyProvided = false;
  
  // Issues management
  List<RepairIssue> _selectedIssues = [];
  final Map<int, TextEditingController> _issueDescriptionControllers = {};

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final id = int.tryParse(widget.repairId!);
        if (id != null) {
          ref.read(repairDetailProvider.notifier).loadRepair(id);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(repairFormProvider.notifier).initializeForCreate();
      });
    }
  }

  @override
  void dispose() {
    _deviceTypeController.dispose();
    _deviceModelController.dispose();
    _deviceSerialController.dispose();
    _problemDescriptionController.dispose();
    _diagnosisNotesController.dispose();
    _repairNotesController.dispose();
    _estimatedCostController.dispose();
    _serviceChargeController.dispose();
    _finalCostController.dispose();
    _warrantyDaysController.dispose();
    super.dispose();
  }

  void _populateForm(Repair repair) {
    _deviceTypeController.text = repair.deviceBrand;
    _deviceModelController.text = repair.deviceModel;
    _deviceSerialController.text = repair.deviceImei ?? '';
    _problemDescriptionController.text = repair.problemDescription;
    _diagnosisNotesController.text = repair.diagnosisNotes ?? "";
    _repairNotesController.text = repair.repairNotes ?? '';
    _estimatedCostController.text =
        repair.estimatedCost?.toStringAsFixed(2) ?? '0.00';
    _serviceChargeController.text =
        repair.serviceCharge?.toStringAsFixed(2) ?? '0.00';
    _finalCostController.text = repair.finalCost?.toStringAsFixed(2) ?? '';
    _warrantyDaysController.text = repair.warrantyDays?.toString() ?? '';

    setState(() {
      _selectedCustomer = repair.customer;
      final priority = repair.priority.toLowerCase();
      _selectedPriority = ['low', 'normal', 'high', 'urgent'].contains(priority)
          ? priority
          : 'normal';
      _selectedStateId = repair.stateId;
      _estimatedCompletion = repair.estimatedCompletion;
      _actualCompletion = repair.actualCompletion;
      _warrantyProvided = repair.warrantyProvided;
      
      // Populate issues
      _selectedIssues = List.from(repair.issues);
      _issueDescriptionControllers.clear();
      for (final issue in _selectedIssues) {
        _issueDescriptionControllers[issue.issueTypeId] = TextEditingController(text: issue.description);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repairFormState = ref.watch(repairFormProvider);
    final repairDetailState = ref.watch(repairDetailProvider);

    // Populate form when editing and repair data is loaded
    if (widget.isEditing &&
        repairDetailState.repair != null &&
        !repairFormState.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(repairFormProvider.notifier)
            .initializeForEdit(repairDetailState.repair!);
        _populateForm(repairDetailState.repair!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Repair' : 'Create Repair'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (widget.isEditing) {
              context.go('/repairs/${widget.repairId}');
            } else {
              context.go('/repairs');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: repairDetailState.isLoading && widget.isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Selection
                    _buildCustomerSection(),
                    const SizedBox(height: 24),

                    // Device Information
                    _buildDeviceSection(),
                    const SizedBox(height: 24),

                    // Problem Description
                    _buildProblemSection(),
                    const SizedBox(height: 24),

                    // Issues Section
                    _buildIssuesSection(),
                    const SizedBox(height: 24),

                    // Status and Priority (only for editing)
                    if (widget.isEditing) ...[
                      _buildStatusSection(),
                      const SizedBox(height: 24),
                    ],

                    // Notes Section
                    _buildNotesSection(),
                    const SizedBox(height: 24),

                    // Cost Information
                    _buildCostSection(),
                    const SizedBox(height: 24),

                    // Timeline
                    _buildTimelineSection(),
                    const SizedBox(height: 24),

                    // Warranty Information
                    _buildWarrantySection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: repairFormState.isLoading
                            ? null
                            : _submitForm,
                        child: repairFormState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Update Repair'
                                    : 'Create Repair',
                              ),
                      ),
                    ),

                    // Error Message
                    if (repairFormState.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(child: Text(repairFormState.error!)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomerSearchSelector(
          selectedCustomer: _selectedCustomer,
          onCustomerSelected: (customer) =>
              setState(() => _selectedCustomer = customer),
          labelText: 'Customer *',
          hintText: 'Search and select a customer',
          showAddButton: true,
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deviceTypeController,
          decoration: const InputDecoration(
            labelText: 'Device Type *',
            border: OutlineInputBorder(),
            hintText: 'e.g., Smartphone, Laptop, Tablet',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter device type' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deviceModelController,
          decoration: const InputDecoration(
            labelText: 'Device Model *',
            border: OutlineInputBorder(),
            hintText: 'e.g., iPhone 14 Pro, MacBook Air M2',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter device model' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deviceSerialController,
          decoration: const InputDecoration(
            labelText: 'Serial Number',
            border: OutlineInputBorder(),
            hintText: 'Device serial number (optional)',
          ),
        ),
      ],
    );
  }

  Widget _buildProblemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problem Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _problemDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Problem Description *',
            border: OutlineInputBorder(),
            hintText: 'Describe the issue with the device...',
          ),
          maxLines: 4,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please describe the problem' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
          ),
          items: ['low', 'normal', 'high', 'urgent']
              .map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(
                    priority[0].toUpperCase() + priority.substring(1),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedPriority = value!),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    final statesAsync = ref.watch(repairStatesProvider);

    // For now, fallback to an empty list while loading/error
    // fallback empty list if needed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        statesAsync.when(
          data: (dataStates) {
            // Deduplicate states by ID
            final uniqueStates = <int, RepairState>{};
            for (final state in dataStates) {
              uniqueStates[state.id] = state;
            }
            final dedupedStates = uniqueStates.values.toList();

            // Calculate valid ID
            final isValid = _selectedStateId != null &&
                dedupedStates.any((s) => s.id == _selectedStateId);
            
            final dropdownValue = isValid ? _selectedStateId : null;

            return DropdownButtonFormField<int>(
              key: ValueKey('status_dropdown_${dropdownValue ?? 'null'}'),
              value: dropdownValue,
              decoration: const InputDecoration(
                labelText: 'Repair Status',
                border: OutlineInputBorder(),
              ),
              items: dedupedStates
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStateId = value),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => DropdownButtonFormField<int>(
            value: null,
            decoration: const InputDecoration(
              labelText: 'Repair Status',
              border: OutlineInputBorder(),
            ),
            items: const [],
            onChanged: null,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _diagnosisNotesController,
          decoration: const InputDecoration(
            labelText: 'Diagnosis Notes',
            border: OutlineInputBorder(),
            hintText: 'Initial diagnosis and findings...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        if (widget.isEditing)
          TextFormField(
            controller: _repairNotesController,
            decoration: const InputDecoration(
              labelText: 'Repair Notes',
              border: OutlineInputBorder(),
              hintText: 'Details about the repair work performed...',
            ),
            maxLines: 3,
          ),
      ],
    );
  }

  Widget _buildCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cost Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _estimatedCostController,
          decoration: const InputDecoration(
            labelText: 'Estimated Cost',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter estimated cost';
            if (double.tryParse(value!) == null)
              return 'Please enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _serviceChargeController,
          decoration: const InputDecoration(
            labelText: 'Service Charge',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter service charge';
            if (double.tryParse(value!) == null)
              return 'Please enter a valid number';
            return null;
          },
        ),
        if (widget.isEditing) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _finalCostController,
            decoration: const InputDecoration(
              labelText: 'Final Cost',
              border: OutlineInputBorder(),
              prefixText: '\$',
              hintText: 'Leave empty if not finalized',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isNotEmpty ?? false) {
                if (double.tryParse(value!) == null)
                  return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineSection() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context, 'estimated'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Completion',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _estimatedCompletion != null
                            ? dateFormat.format(_estimatedCompletion!)
                            : 'Select date (optional)',
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        if (widget.isEditing) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, 'actual'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actual Completion',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _actualCompletion != null
                              ? dateFormat.format(_actualCompletion!)
                              : 'Select date (optional)',
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWarrantySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warranty Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Warranty Provided'),
          value: _warrantyProvided,
          onChanged: (value) => setState(() => _warrantyProvided = value),
          contentPadding: EdgeInsets.zero,
        ),
        if (_warrantyProvided) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _warrantyDaysController,
            decoration: const InputDecoration(
              labelText: 'Warranty Period (days)',
              border: OutlineInputBorder(),
              hintText: 'e.g., 30, 90, 365',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_warrantyProvided && (value?.isEmpty ?? true)) {
                return 'Please enter warranty period';
              }
              if (value?.isNotEmpty ?? false) {
                if (int.tryParse(value!) == null)
                  return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildIssuesSection() {
    final issueTypesAsync = ref.watch(issueTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issues',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        issueTypesAsync.when(
          data: (response) {
            if (!response.isSuccess) {
              return Text(
                'Error loading issue types',
                style: const TextStyle(color: Colors.red),
              );
            }

            final issueTypes = response.data ?? [];
            // Deduplicate issue types by ID
            final uniqueIssueTypes = <int, IssueType>{};
            for (final type in issueTypes) {
              uniqueIssueTypes[type.id] = type;
            }
            final dedupedIssueTypes = uniqueIssueTypes.values.toList();

            final availableTypes = dedupedIssueTypes
                .where(
                  (type) =>
                      !_selectedIssues.any((i) => i.issueTypeId == type.id),
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (availableTypes.isNotEmpty)
                  DropdownButtonFormField<int>(
                    key: ValueKey('issue_dropdown_${_selectedIssues.length}'),
                    decoration: const InputDecoration(
                      labelText: 'Add Issue',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bug_report),
                    ),
                    value: null,
                    items: availableTypes.map((type) {
                      return DropdownMenuItem(
                        value: type.id,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (selectedTypeId) {
                      if (selectedTypeId != null) {
                        final selectedType = issueTypes.firstWhere(
                          (t) => t.id == selectedTypeId,
                        );
                        setState(() {
                          final newIssue = RepairIssue(
                            id: 0,
                            repairId: int.tryParse(widget.repairId ?? '0') ?? 0,
                            issueTypeId: selectedType.id,
                            description: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          _selectedIssues.add(newIssue);
                          _issueDescriptionControllers[selectedType.id] =
                              TextEditingController();
                        });
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (_selectedIssues.isEmpty)
                  const Text(
                    'No issues added.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ..._selectedIssues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final issue = entry.value;
                  final type = issueTypes.firstWhere(
                    (t) => t.id == issue.issueTypeId,
                    orElse:
                        () => IssueType(id: issue.issueTypeId, name: 'Unknown'),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  type.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedIssues.removeAt(index);
                                    _issueDescriptionControllers.remove(
                                      issue.issueTypeId,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          TextFormField(
                            controller:
                                _issueDescriptionControllers[issue.issueTypeId],
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Failed to load issue types'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: type == 'estimated'
          ? _estimatedCompletion ?? DateTime.now().add(const Duration(days: 7))
          : _actualCompletion ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (type == 'estimated') {
          _estimatedCompletion = picked;
        } else {
          _actualCompletion = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final estimatedCost = double.tryParse(_estimatedCostController.text) ?? 0.0;
    final serviceCharge = double.tryParse(_serviceChargeController.text) ?? 0.0;
    final finalCost = _finalCostController.text.isEmpty
        ? null
        : double.tryParse(_finalCostController.text);
    final warrantyDays =
        _warrantyProvided && _warrantyDaysController.text.isNotEmpty
        ? int.tryParse(_warrantyDaysController.text)
        : null;

    // Sync issues descriptions
    final issuesToSubmit = _selectedIssues.map((issue) {
      final controller = _issueDescriptionControllers[issue.issueTypeId];
      return issue.copyWith(description: controller?.text ?? issue.description);
    }).toList();

    if (widget.isEditing) {
      // Update existing repair
      final currentRepair = ref.read(repairDetailProvider).repair;
      if (currentRepair == null) return;

      final updatedRepair = currentRepair.copyWith(
        customerId: _selectedCustomer!.id,
        deviceBrand: _deviceTypeController.text,
        deviceModel: _deviceModelController.text,
        deviceImei: _deviceSerialController.text,
        problemDescription: _problemDescriptionController.text,
        diagnosisNotes: _diagnosisNotesController.text.isEmpty
            ? null
            : _diagnosisNotesController.text,
        repairNotes: _repairNotesController.text.isEmpty
            ? null
            : _repairNotesController.text,
        stateId: _selectedStateId,
        priority: _selectedPriority,
        estimatedCost: estimatedCost,
        finalCost: finalCost,
        serviceCharge: serviceCharge,
        estimatedCompletion: _estimatedCompletion,
        actualCompletion: _actualCompletion,
        warrantyProvided: _warrantyProvided,
        warrantyDays: warrantyDays,
        issues: issuesToSubmit,
      );

      final success = await ref
          .read(repairFormProvider.notifier)
          .updateRepair(updatedRepair);

      if (success && mounted) {
        // Update the detail provider as well
        ref.read(repairDetailProvider.notifier).clear();
        ref.read(repairDetailProvider.notifier).loadRepair(updatedRepair.id);

        // Update the list provider
        final updatedRepairFromService = ref.read(repairFormProvider).repair;
        if (updatedRepairFromService != null) {
          ref
              .read(repairListProvider.notifier)
              .updateRepairInList(updatedRepairFromService);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair updated successfully')),
        );
        context.go('/repairs/${widget.repairId}');
      }
    } else {
      // Create new repair
      final newRepair = await ref
          .read(repairFormProvider.notifier)
          .createRepair(
            customerId: _selectedCustomer!.id,
            deviceBrand: _deviceTypeController.text,
            deviceModel: _deviceModelController.text,
            deviceImei: _deviceSerialController.text.isEmpty
                ? null
                : _deviceSerialController.text,
            problemDescription: _problemDescriptionController.text,
            diagnosisNotes: _diagnosisNotesController.text.isEmpty
                ? null
                : _diagnosisNotesController.text,
            priority: _selectedPriority,
            estimatedCost: estimatedCost,
            serviceCharge: serviceCharge,
            estimatedCompletion: _estimatedCompletion,
            warrantyProvided: _warrantyProvided,
            warrantyDays: warrantyDays,
            issues: issuesToSubmit,
          );

      if (newRepair != null && mounted) {
        // Add to list provider
        ref.read(repairListProvider.notifier).addRepairToList(newRepair);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair created successfully')),
        );
        context.go('/repairs/${newRepair.id}');
      }
    }
  }
}
