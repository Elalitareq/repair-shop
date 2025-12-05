import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/payment_method.dart';
import '../../../../shared/models/sale.dart';
import '../../../../shared/models/repair.dart';
import '../../../../shared/services/reference_service.dart';
import '../../../../shared/services/payment_service.dart';
import '../../../../shared/services/repair_service.dart';
import '../../../../shared/providers/sale_provider.dart';
import '../../../../shared/providers/customer_provider.dart';

class PaymentAllocationDialog extends ConsumerStatefulWidget {
  final int customerId;

  const PaymentAllocationDialog({super.key, required this.customerId});

  @override
  ConsumerState<PaymentAllocationDialog> createState() =>
      _PaymentAllocationDialogState();
}

class _PaymentAllocationDialogState
    extends ConsumerState<PaymentAllocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  List<Sale> _unpaidSales = [];
  List<Repair> _unpaidRepairs = [];

  // Map to store allocation amounts: key is 'sale_ID' or 'repair_ID'
  final Map<String, double> _allocations = {};
  final Map<String, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final saleService = ref.read(saleServiceProvider);
      final repairService = ref.read(repairServiceProvider);
      final referenceService = ref.read(referenceServiceProvider);

      // Fetch payment methods
      final methodsResp = await referenceService.getPaymentMethods();
      if (!methodsResp.isSuccess) throw Exception(methodsResp.message);

      // Fetch sales (fetch all and filter for now as backend might not support paymentStatus filter yet)
      final salesResp = await saleService.getSales(
        customerId: widget.customerId,
        limit: 100,
      );
      if (!salesResp.isSuccess) throw Exception(salesResp.message);

      // Fetch repairs
      final repairsResp = await repairService.getRepairs(
        customerId: widget.customerId,
        limit: 100,
      );
      if (!repairsResp.isSuccess) throw Exception(repairsResp.message);

      if (mounted) {
        setState(() {
          _paymentMethods = methodsResp.data ?? [];
          if (_paymentMethods.isNotEmpty) {
            _selectedPaymentMethod = _paymentMethods.first;
          }

          // Filter for unpaid/partial items
          _unpaidSales = (salesResp.data ?? [])
              .where((s) => s.paymentStatus != 'paid')
              .toList();

          _unpaidRepairs = (repairsResp.data ?? [])
              .where((r) => r.paymentStatus != 'paid')
              .toList();

          _isLoading = false;

          // Calculate total outstanding and auto-fill
          double totalOutstanding = 0.0;
          for (final sale in _unpaidSales) {
            totalOutstanding += sale.totalAmount - _calculatePaid(sale);
          }
          for (final repair in _unpaidRepairs) {
            totalOutstanding +=
                _calculateRepairTotal(repair) - _calculateRepairPaid(repair);
          }

          // Pre-fill amount and auto-allocate
          if (totalOutstanding > 0) {
            _amountController.text = totalOutstanding.toStringAsFixed(2);
            // Trigger auto-allocation after a brief delay to ensure UI is ready
            Future.microtask(() => _autoAllocate());
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _autoAllocate() {
    double remaining = double.tryParse(_amountController.text) ?? 0.0;
    if (remaining <= 0) return;

    setState(() {
      _allocations.clear();
      _selectedItems.clear();

      // Prioritize oldest debts? Or just list order. Let's do list order (which is usually date desc, maybe should be asc for payment)
      // Let's combine and sort by date
      final allItems = [
        ..._unpaidSales.map(
          (s) => {
            'type': 'sale',
            'date': s.createdAt,
            'obj': s,
            'id': s.id,
            'total': s.totalAmount,
            'paid': _calculatePaid(s),
          },
        ),
        ..._unpaidRepairs.map(
          (r) => {
            'type': 'repair',
            'date': r.receivedDate,
            'obj': r,
            'id': r.id,
            'total': _calculateRepairTotal(r),
            'paid': _calculateRepairPaid(r),
          },
        ),
      ];

      // Sort by date ascending (pay oldest first)
      allItems.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );

      for (final item in allItems) {
        if (remaining <= 0.01) break;

        final total = (item['total'] as num).toDouble();
        final paid = (item['paid'] as num).toDouble();
        final due = total - paid;

        if (due > 0) {
          final key = '${item['type']}_${item['id']}';
          _selectedItems[key] = true;

          if (remaining >= due) {
            _allocations[key] = due;
            remaining -= due;
          } else {
            _allocations[key] = remaining;
            remaining = 0;
          }
        }
      }
    });
  }

  double _calculatePaid(Sale sale) {
    // This is a rough estimate if we don't have exact paid amount from API
    // Ideally API should return 'amountPaid' or 'balance'
    // For now, if partial, we assume 0 or we need to fetch payments.
    // The Sale model might not have amountPaid.
    // If it's 'pending', 0. If 'paid', total. If 'partial', unknown without payments.
    // Let's assume the user knows or we default to full amount due.
    // Actually, let's just use totalAmount for now and assume 0 paid if pending/partial to keep it simple,
    // as fetching all payments for all sales is expensive.
    // TODO: Improve by fetching actual balance.
    return 0.0;
  }

  double _calculateRepairTotal(Repair repair) {
    final itemsCost = repair.items.fold<double>(
      0.0,
      (sum, item) => sum + (item.totalPrice ?? 0.0),
    );
    return (repair.serviceCharge ?? 0.0) + itemsCost;
  }

  double _calculateRepairPaid(Repair repair) {
    return 0.0; // Same assumption as sales
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) return;

    final amount = double.parse(_amountController.text);

    // Validate allocations match amount
    double allocatedSum = 0;
    final allocationsList = <Map<String, dynamic>>[];

    _allocations.forEach((key, value) {
      if (_selectedItems[key] == true && value > 0) {
        allocatedSum += value;
        final parts = key.split('_');
        final type = parts[0];
        final id = int.parse(parts[1]);

        allocationsList.add({
          if (type == 'sale') 'saleId': id,
          if (type == 'repair') 'repairId': id,
          'amount': value,
        });
      }
    });

    if ((allocatedSum - amount).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Allocated amount ($allocatedSum) does not match total payment ($amount)',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final response = await paymentService.allocatePayment(
        customerId: widget.customerId,
        paymentMethodId: _selectedPaymentMethod!.id,
        amount: amount,
        referenceNumber: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        allocations: allocationsList,
      );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          // Refresh customer data
          ref
              .read(customerDetailProvider.notifier)
              .loadCustomer(widget.customerId);
          ref
              .read(customerDetailProvider.notifier)
              .loadLedger(widget.customerId);
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Text('Error: $_error', style: const TextStyle(color: Colors.red))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Payment Details
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              return null;
                            },
                            onChanged: (_) => _autoAllocate(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<PaymentMethod>(
                            value: _selectedPaymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Method',
                            ),
                            items: _paymentMethods.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(m.name),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedPaymentMethod = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference (Optional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allocation List
                    const Text(
                      'Allocate to:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ..._unpaidSales.map(
                            (s) => _buildAllocationItem(
                              'sale_${s.id}',
                              'Sale #${s.saleNumber}',
                              s.totalAmount,
                              s.createdAt,
                            ),
                          ),
                          ..._unpaidRepairs.map(
                            (r) => _buildAllocationItem(
                              'repair_${r.id}',
                              'Repair #${r.repairNumber}',
                              _calculateRepairTotal(r),
                              r.receivedDate,
                            ),
                          ),
                          if (_unpaidSales.isEmpty && _unpaidRepairs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No unpaid items found.'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text('Submit Payment'),
        ),
      ],
    );
  }

  Widget _buildAllocationItem(
    String key,
    String title,
    double total,
    DateTime date,
  ) {
    final isSelected = _selectedItems[key] ?? false;
    final allocation = _allocations[key] ?? 0.0;

    return CheckboxListTile(
      value: isSelected,
      onChanged: (v) {
        setState(() {
          _selectedItems[key] = v ?? false;
          if (v == true && allocation == 0) {
            // Auto-fill with remaining amount or full amount
            double currentTotal = double.tryParse(_amountController.text) ?? 0;
            double currentAllocated = _allocations.values.fold(
              0,
              (sum, val) => sum + val,
            );
            double remaining = currentTotal - currentAllocated;
            _allocations[key] = remaining > 0
                ? (remaining > total ? total : remaining)
                : 0;
          } else if (v == false) {
            _allocations[key] = 0;
          }
        });
      },
      title: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            DateFormat.MMMd().format(date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text('Total: \$${total.toStringAsFixed(2)}'),
          const SizedBox(width: 16),
          if (isSelected)
            SizedBox(
              width: 100,
              child: TextFormField(
                key: ValueKey('$key-$allocation'),
                initialValue: allocation.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixText: '\$',
                ),
                onChanged: (v) {
                  setState(() {
                    _allocations[key] = double.tryParse(v) ?? 0.0;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
