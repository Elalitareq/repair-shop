import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/customer_provider.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  final int? customerId;

  const CustomerFormPage({super.key, this.customerId});

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _locationLinkController = TextEditingController();

  String _type = 'customer';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(customerDetailProvider.notifier)
            .loadCustomer(widget.customerId!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _locationLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(customerDetailProvider);
    final customer = detailState.customer;

    // Populate form when customer is loaded for editing
    if (customer != null &&
        widget.customerId != null &&
        _nameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _nameController.text = customer.name;
          _companyNameController.text = customer.companyName ?? '';
          _phoneController.text = customer.phone;
          _addressController.text = customer.address ?? "";
          _taxNumberController.text = customer.taxNumber ?? '';
          _locationLinkController.text = customer.locationLink ?? '';
          _type = customer.type;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customerId == null ? 'Add Customer' : 'Edit Customer',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: detailState.isLoading && customer == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selection
                    const Text(
                      'Customer Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Customer'),
                            value: 'customer',
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() => _type = value!);
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Dealer'),
                            value: 'dealer',
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() => _type = value!);
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Basic Information
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Enter full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        hintText: 'Enter company name (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        hintText: 'Enter phone number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Address Information
                    const Text(
                      'Address Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter full address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Location Link',
                        hintText: 'Google Maps link (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Business Information (for dealers)
                    if (_type == 'dealer') ...[
                      const Text(
                        'Business Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _taxNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Number',
                          hintText: 'Enter tax number (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.customerId == null
                                    ? 'Create Customer'
                                    : 'Update Customer',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
 
    final data = {
      'name': _nameController.text,
      'companyName': _companyNameController.text.isEmpty
          ? null
          : _companyNameController.text,
      'type': _type,
      'phone': _phoneController.text,
      'address': _addressController.text.isEmpty
          ? null
          : _addressController.text,
      'taxNumber': _taxNumberController.text.isEmpty
          ? null
          : _taxNumberController.text,
      'locationLink': _locationLinkController.text.isEmpty
          ? null
          : _locationLinkController.text,
    };

    final success = widget.customerId == null
        ? await ref.read(customerDetailProvider.notifier).createCustomer(data)
        : await ref
              .read(customerDetailProvider.notifier)
              .updateCustomer(widget.customerId!, data);

    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Customer ${widget.customerId == null ? 'created' : 'updated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the customer list
        ref.invalidate(customerListProvider);
        context.go('/customers');
      }
    } else {
      final error = ref.read(customerDetailProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  'Failed to ${widget.customerId == null ? 'create' : 'update'} customer',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
