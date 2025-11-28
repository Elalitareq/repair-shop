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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Customer> _searchResults = [];
  bool _isSearching = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

    // Initialize with selected customer name
    if (widget.selectedCustomer != null) {
      _searchController.text = widget.selectedCustomer!.name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomerSearchSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text when selected customer changes externally
    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      if (widget.selectedCustomer != null) {
        _searchController.text = widget.selectedCustomer!.name;
      } else {
        _searchController.clear();
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      _removeOverlay();
      return;
    }

    _performSearch(query);
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _showSearchResults();
    } else {
      _removeOverlay();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return; // Minimum 2 characters

    setState(() => _isSearching = true);

    try {
      final customerService = ref.read(customerServiceProvider);
      print('Searching for customers with query: $query type: ${widget.type}');
      final response;
      if (widget.type == 'dealer') {
        response = await customerService.getDealers(search: query);
      } else if (widget.type == 'customer') {
        response = await customerService.getRegularCustomers(search: query);
      } else {
        response = await customerService.searchCustomers(query);
      }

      if (response.isSuccess && response.data != null) {
        print('Search returned ${response.data!.length} results');
        setState(() {
          _searchResults = response.data!;
          _isSearching = false;
        });

        if (_searchResults.isNotEmpty) {
          _showSearchResults();
        } else {
          _removeOverlay();
        }
      } else {
        print('Search failed: ${response.message}');
        setState(() => _isSearching = false);
        _removeOverlay();
      }
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
      _removeOverlay();
    }
  }

  void _showSearchResults() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _searchResults.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No customers found'),
                        if (widget.showAddButton) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showAddCustomerDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Customer'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        _searchResults.length + (widget.showAddButton ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _searchResults.length) {
                        // Add new customer button
                        return ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Add New Customer'),
                          onTap: _showAddCustomerDialog,
                        );
                      }

                      final customer = _searchResults[index];
                      return ListTile(
                        leading: Icon(
                          customer.isDealer ? Icons.business : Icons.person,
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone),
                        onTap: () {
                          _selectCustomer(customer);
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectCustomer(Customer customer) {
    _searchController.text = customer.name;
    widget.onCustomerSelected(customer);
    _removeOverlay();
    _searchFocusNode.unfocus();
  }

  void _clearSelection() {
    _searchController.clear();
    widget.onCustomerSelected(null);
    _removeOverlay();
  }

  Future<void> _showAddCustomerDialog() async {
    _removeOverlay();

    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => AddCustomerDialog(),
    );

    if (result != null) {
      _selectCustomer(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSelection,
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
          validator: (value) {
            if (widget.selectedCustomer == null) {
              return 'Please select a customer';
            }
            return null;
          },
        ),
      ],
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

      print('Creating customer with data: $customerData');

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
        print('Customer created successfully: ${response.data!.name}');
        if (mounted) {
          Navigator.of(context).pop(response.data);
        }
      } else {
        print('Failed to create customer: ${response.message}');
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
      print('Error creating customer: $e');
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
