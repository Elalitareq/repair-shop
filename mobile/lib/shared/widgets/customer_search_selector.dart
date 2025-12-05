import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerSearchSelector extends ConsumerStatefulWidget {
  final Customer? selectedCustomer;
  final Function(Customer?) onCustomerSelected;
  final String? labelText;
  final String? hintText;
  final bool showAddButton;
  final String? type; // 'dealer' | 'customer' | null

  const CustomerSearchSelector({
    super.key,
    this.selectedCustomer,
    required this.onCustomerSelected,
    this.labelText = 'Customer',
    this.hintText = 'Search and select a customer',
    this.showAddButton = true,
    this.type,
  });

  @override
  ConsumerState<CustomerSearchSelector> createState() =>
      _CustomerSearchSelectorState();
}

class _CustomerSearchSelectorState
    extends ConsumerState<CustomerSearchSelector> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCustomer != null) {
      _searchController.text = widget.selectedCustomer!.name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomerSearchSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      if (widget.selectedCustomer != null) {
        _searchController.text = widget.selectedCustomer!.name;
      } else {
        _searchController.clear();
      }
    }
  }

  Future<List<Customer>> _searchCustomers(String query) async {
    if (query.length < 2) return [];

    try {
      final customerService = ref.read(customerServiceProvider);
      final response;
      if (widget.type == 'dealer') {
        response = await customerService.getDealers(search: query);
      } else if (widget.type == 'customer') {
        response = await customerService.getRegularCustomers(search: query);
      } else {
        response = await customerService.searchCustomers(query);
      }

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
    return [];
  }

  Future<void> _showAddCustomerDialog() async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );

    if (result != null) {
      widget.onCustomerSelected(result);
      _searchController.text = result.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      widget.onCustomerSelected(null);
                    },
                    tooltip: 'Clear selection',
                  ),
                if (widget.showAddButton)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddCustomerDialog,
                    tooltip: 'Add new customer',
                  ),
              ],
            ),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (_) {
            controller.openView();
          },
          validator: (value) {
            if (widget.selectedCustomer == null) {
              return 'Please select a customer';
            }
            return null;
          },
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
        final query = controller.text;
        final customers = await _searchCustomers(query);

        return [
          if (customers.isEmpty && query.length >= 2)
            const ListTile(title: Text('No customers found')),
          ...customers.map(
            (customer) => ListTile(
              leading: Icon(customer.isDealer ? Icons.business : Icons.person),
              title: Text(customer.name),
              subtitle: Text(customer.phone),
              onTap: () {
                widget.onCustomerSelected(customer);
                controller.closeView(customer.name);
              },
            ),
          ),
          if (widget.showAddButton)
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New Customer'),
              onTap: () {
                // Close the search view first
                controller.closeView(controller.text);
                _showAddCustomerDialog();
              },
            ),
        ];
      },
    );
  }
}

class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();

  String _customerType = 'customer';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customerService = ref.read(customerServiceProvider);
      final customerData = {
        'name': _nameController.text.trim(),
        'companyName': _companyController.text.isEmpty
            ? null
            : _companyController.text.trim(),
        'type': _customerType,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.isEmpty
            ? null
            : _addressController.text.trim(),
        'taxNumber': _taxNumberController.text.isEmpty
            ? null
            : _taxNumberController.text.trim(),
      };


      final response = await customerService.createCustomer(
        name: _nameController.text.trim(),
        companyName: _companyController.text.isEmpty
            ? null
            : _companyController.text.trim(),
        type: _customerType,
        phone: _phoneController.text.trim(),
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text.trim(),
        taxNumber: _taxNumberController.text.isEmpty
            ? null
            : _taxNumberController.text.trim(),
      );

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          Navigator.of(context).pop(response.data);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Customer'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Customer name',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Optional for businesses',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _customerType,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'dealer', child: Text('Dealer')),
                ],
                onChanged: (value) => setState(() => _customerType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Customer phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Customer address',
                ),
                maxLines: 2,
              ),
              if (_customerType == 'dealer') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Number',
                    hintText: 'Business tax number',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCustomer,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
