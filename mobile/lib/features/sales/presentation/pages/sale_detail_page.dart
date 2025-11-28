import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/sale_provider.dart';
import '../../../../shared/services/reference_service.dart';
import '../../../../shared/models/models.dart';

class SaleDetailPage extends ConsumerStatefulWidget {
  final int saleId;

  const SaleDetailPage({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends ConsumerState<SaleDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(saleDetailProvider.notifier).loadSale(widget.saleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleDetailProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/sales'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: saleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : saleState.error != null
          ? Center(child: Text('Error: ${saleState.error}'))
          : saleState.sale == null
          ? const Center(child: Text('Sale not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale #${saleState.sale!.saleNumber ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Customer Information
                  if (saleState.sale!.customer != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Customer',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              saleState.sale!.customer!.displayName,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Phone: ${saleState.sale!.customer!.phone}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.person_off, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Walk-in Customer',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status and Actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Status: ${saleState.sale!.getDisplayStatus()}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showStatusUpdateDialog(
                          context,
                          saleState.sale!.id,
                        ),
                        child: const Text('Update Status'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sale Items
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Items (${saleState.sale!.saleItems?.length ?? 0})',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (saleState.sale!.saleItems != null &&
                              saleState.sale!.saleItems!.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: saleState.sale!.saleItems!.length,
                              itemBuilder: (context, index) {
                                final item = saleState.sale!.saleItems![index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.item?.name ??
                                                    'Unknown Item',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Quantity: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                              if (item.discount > 0)
                                                Text(
                                                  'Discount: \$${item.discount.toStringAsFixed(2)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.green,
                                                      ),
                                                ),
                                              Text(
                                                'Total: \$${item.total.toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No items in this sale'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Totals
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:'),
                              Text(
                                '\$${saleState.sale!.totalAmount.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount Paid:'),
                              Text(
                                '\$${saleState.sale!.totalPaid.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: saleState.sale!.totalPaid > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Remaining Balance:'),
                              Text(
                                '\$${saleState.sale!.remainingBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: saleState.sale!.remainingBalance > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Payments
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.payment, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Payments',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showAddPaymentDialog(
                                  context,
                                  saleState.sale!.id,
                                  saleState.sale!.remainingBalance,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Payment'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (saleState.sale!.payments != null &&
                              saleState.sale!.payments!.isNotEmpty)
                            ...saleState.sale!.payments!.map(
                              (payment) => ListTile(
                                title: Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                ),
                                subtitle: Text(
                                  '${payment.paymentMethodDisplay} • ${payment.paymentDate.toLocal().toString().split(' ')[0]}',
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('No payments recorded'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  if (saleState.sale!.notes != null &&
                      saleState.sale!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(saleState.sale!.notes!),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Edit Button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditNotImplementedDialog(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Sale'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, int saleId) {
    final currentSale = ref.read(saleDetailProvider).sale;
    if (currentSale == null) return;

    String selectedStatus = currentSale.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Sale Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select new status:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(
                        value: 'confirmed',
                        child: Text('Confirmed'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('Cancelled'),
                      ),
                      DropdownMenuItem(
                        value: 'refunded',
                        child: Text('Refunded'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStatus == currentSale.status
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          navigator.pop();
                          final success = await ref
                              .read(saleDetailProvider.notifier)
                              .updateSaleStatus(saleId, selectedStatus);
                          if (success && mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sale status updated to ${selectedStatus[0].toUpperCase()}${selectedStatus.substring(1)}',
                                ),
                              ),
                            );
                            // Reload the sale details
                            ref
                                .read(saleDetailProvider.notifier)
                                .loadSale(saleId);
                          }
                        },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNotImplementedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Sale'),
          content: const Text(
            'Sale editing functionality is not yet implemented. This feature will allow you to modify sale items, customer, and other details.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    int saleId,
    double remainingBalance,
  ) {
    final _formKey = GlobalKey<FormState>();
    int? selectedMethodId;
    double amount = remainingBalance > 0 ? remainingBalance : 0;
    final _refController = TextEditingController(text: '');
    final _notesController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final referenceService = ref.read(referenceServiceProvider);
            return FutureBuilder(
              future: referenceService.getPaymentMethods(),
              builder: (context, snapshot) {
                final rawMethods = snapshot.hasData && snapshot.data!.isSuccess
                    ? snapshot.data!.data!
                    : <PaymentMethod>[];
                // Only allow Cash and Whish Money (or Wish Money), others can be added in settings
                final methods = rawMethods
                    .where(
                      (m) => [
                        'cash',
                        'whish money',
                        'wish money',
                      ].contains(m.name.toLowerCase()),
                    )
                    .toList();

                if (methods.isEmpty) {
                  // No allowed methods - show message
                  return AlertDialog(
                    title: const Text('Add Payment'),
                    content: const Text(
                      'No payment methods configured. Please add payment methods in settings.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }

                // Default to first method if not selected
                selectedMethodId ??= methods.first.id;

                return AlertDialog(
                  title: const Text('Add Payment'),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            value: selectedMethodId,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                            ),
                            items: methods
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text(m.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => selectedMethodId = value,
                            validator: (v) => v == null
                                ? 'Please select a payment method'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: amount.toStringAsFixed(2),
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) =>
                                v == null ||
                                    double.tryParse(v) == null ||
                                    double.parse(v) <= 0
                                ? 'Enter valid amount'
                                : null,
                            onSaved: (v) =>
                                amount = double.tryParse(v ?? '0') ?? 0,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _refController,
                            decoration: const InputDecoration(
                              labelText: 'Reference Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
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
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();
                        final success = await ref
                            .read(saleDetailProvider.notifier)
                            .addPayment(
                              saleId,
                              paymentMethodId: selectedMethodId!,
                              amount: amount,
                              referenceNumber: _refController.text.isNotEmpty
                                  ? _refController.text
                                  : null,
                              paymentDate: paymentDate,
                              notes: _notesController.text.isNotEmpty
                                  ? _notesController.text
                                  : null,
                            );

                        Navigator.of(context).pop();
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment added successfully'),
                            ),
                          );
                          ref
                              .read(saleDetailProvider.notifier)
                              .loadSale(saleId);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
