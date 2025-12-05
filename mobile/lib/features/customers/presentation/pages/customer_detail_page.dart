import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../shared/models/customer.dart';
import '../../../../shared/providers/customer_provider.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/payment_allocation_dialog.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  final int customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerDetailProvider.notifier).loadCustomer(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(customerDetailProvider);
    final customer = detailState.customer;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INFO'),
              Tab(text: 'LEDGER'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
          actions: [
            if (customer != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/customers/${customer.id}/edit'),
              ),
            if (customer != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(context),
              ),
          ],
        ),
        body: detailState.isLoading && customer == null
            ? const Center(child: CircularProgressIndicator())
            : detailState.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading customer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detailState.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(customerDetailProvider.notifier)
                          .loadCustomer(widget.customerId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : customer == null
            ? const Center(child: Text('Customer not found'))
            : TabBarView(
                children: [
                  _buildInfoTab(context, customer, detailState),
                  _buildLedgerTab(context, detailState),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    Customer customer,
    CustomerDetailState detailState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (customer.companyName != null &&
                                customer.companyName!.isNotEmpty)
                              Text(
                                customer.companyName!,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                customer.type == 'dealer'
                                    ? 'Dealer'
                                    : 'Customer',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: customer.type == 'dealer'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone Number'),
                    subtitle: Text(customer.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => _launchPhone(customer.phone),
                    ),
                  ),
                  if (customer.email != null && customer.email!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(customer.email!),
                      trailing: IconButton(
                        icon: const Icon(Icons.mail),
                        onPressed: () => _launchUrl('mailto:${customer.email}'),
                      ),
                    ),
                  if (customer.address != null && customer.address!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(customer.address ?? ""),
                      trailing:
                          customer.locationLink != null &&
                              customer.locationLink!.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () =>
                                  _launchUrl(customer.locationLink!),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Business Information (for dealers)
          if (customer.type == 'dealer' &&
              (customer.taxNumber != null && customer.taxNumber!.isNotEmpty))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Tax Number'),
                      subtitle: Text(customer.taxNumber!),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Statistics placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Repairs',
                          (detailState.stats != null &&
                                  detailState.stats!['totalRepairs'] != null)
                              ? detailState.stats!['totalRepairs'].toString()
                              : '0',
                          Icons.build,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Spent',
                          detailState.stats != null &&
                                  detailState.stats!['totalSpent'] != null
                              ? NumberFormat.simpleCurrency(
                                  locale: 'en_US',
                                ).format(detailState.stats!['totalSpent'])
                              : NumberFormat.simpleCurrency(
                                  locale: 'en_US',
                                ).format(0),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Activity placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (detailState.recentRepairs != null &&
                      detailState.recentRepairs!.isNotEmpty)
                    Column(
                      children: detailState.recentRepairs!.map((repair) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${repair.repairNumber} - ${repair.deviceModel}',
                          ),
                          subtitle: Text(repair.problemDescription),
                          trailing: Text(
                            NumberFormat.simpleCurrency(
                              locale: 'en_US',
                            ).format(repair.totalCost),
                          ),
                          onTap: () => context.go('/repairs/${repair.id}'),
                        );
                      }).toList(),
                    )
                  else
                    const Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab(
    BuildContext context,
    CustomerDetailState detailState,
  ) {
    if (detailState.ledger == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final ledger = detailState.ledger!['data'] as List<dynamic>;
    final summary = detailState.ledger!['summary'] as Map<String, dynamic>;

    return Column(
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLedgerSummaryItem(
                context,
                'Total Debits',
                summary['totalDebit'],
                Colors.red,
              ),
              _buildLedgerSummaryItem(
                context,
                'Total Credits',
                summary['totalCredit'],
                Colors.green,
              ),
              _buildLedgerSummaryItem(
                context,
                'Balance',
                summary['finalBalance'],
                summary['finalBalance'] > 0 ? Colors.red : Colors.green,
                isBold: true,
              ),
            ],
          ),
        ),

        // Date Filter (Simple placeholder for now)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      // Set end date to end of day (23:59:59)
                      final endDate = picked.end
                          .add(const Duration(days: 1))
                          .subtract(const Duration(seconds: 1));

                      ref
                          .read(customerDetailProvider.notifier)
                          .loadLedger(
                            widget.customerId,
                            startDate: picked.start,
                            endDate: endDate,
                          );
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Filter by Date Range'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  ref
                      .read(customerDetailProvider.notifier)
                      .loadLedger(widget.customerId);
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        PaymentAllocationDialog(customerId: widget.customerId),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text('Add Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Ledger List
        Expanded(
          child: ledger.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                  itemCount: ledger.length,
                  itemBuilder: (context, index) {
                    final item = ledger[index];
                    final date = DateTime.parse(item['date']);
                    final isDebit = item['debit'] > 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDebit
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          child: Icon(
                            item['type'] == 'Repair'
                                ? Icons.build
                                : item['type'] == 'Sale'
                                ? Icons.shopping_cart
                                : Icons.payment,
                            color: isDebit ? Colors.red : Colors.green,
                            size: 20,
                          ),
                        ),
                        title: Text(item['description']),
                        subtitle: Text(
                          '${DateFormat.yMMMd().format(date)} • ${item['reference'] ?? "N/A"}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isDebit
                                  ? '+${NumberFormat.simpleCurrency(locale: 'en_US').format(item['debit'])}'
                                  : '-${NumberFormat.simpleCurrency(locale: 'en_US').format(item['credit'])}',
                              style: TextStyle(
                                color: isDebit ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bal: ${NumberFormat.simpleCurrency(locale: 'en_US').format(item['balance'])}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLedgerSummaryItem(
    BuildContext context,
    String label,
    dynamic value,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          NumberFormat.simpleCurrency(locale: 'en_US').format(value),
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final customer = ref.read(customerDetailProvider).customer;
    if (customer == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteCustomer(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    Navigator.of(context).pop(); // Close dialog

    final messenger = ScaffoldMessenger.of(context);
    final router = ref.read(appRouterProvider);
    final success = await ref
        .read(customerDetailProvider.notifier)
        .deleteCustomer(widget.customerId);

    if (success) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the customer list and go back
        ref.invalidate(customerListProvider);
        router.go('/customers');
      });
    } else {
      final error = ref.read(customerDetailProvider).error;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete customer'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
