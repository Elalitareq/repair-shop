import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/customer_provider.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerListProvider.notifier).loadCustomers(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(customerListProvider.notifier)
                                  .loadCustomers(refresh: true);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      ref
                          .read(customerListProvider.notifier)
                          .searchCustomers(value);
                    } else {
                      ref
                          .read(customerListProvider.notifier)
                          .loadCustomers(refresh: true);
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Type filter
                Row(
                  children: [
                    const Text(
                      'Filter:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setState(() => _selectedType = null);
                        ref
                            .read(customerListProvider.notifier)
                            .loadCustomers(refresh: true);
                      },
                      backgroundColor: Colors.white.withOpacity(0.2),
                      selectedColor: Colors.white,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Customers'),
                      selected: _selectedType == 'customer',
                      onSelected: (selected) {
                        setState(
                          () => _selectedType = selected ? 'customer' : null,
                        );
                        ref
                            .read(customerListProvider.notifier)
                            .filterByType(selected ? 'customer' : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.2),
                      selectedColor: Colors.white,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Dealers'),
                      selected: _selectedType == 'dealer',
                      onSelected: (selected) {
                        setState(
                          () => _selectedType = selected ? 'dealer' : null,
                        );
                        ref
                            .read(customerListProvider.notifier)
                            .filterByType(selected ? 'dealer' : null);
                      },
                      backgroundColor: Colors.white.withOpacity(0.2),
                      selectedColor: Colors.white,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading && state.customers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(customerListProvider.notifier)
                        .loadCustomers(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(customerListProvider.notifier)
                    .loadCustomers(refresh: true);
              },
              child: ListView.builder(
                itemCount: state.customers.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.customers.length) {
                    // Load more indicator
                    if (!state.isLoading) {
                      ref.read(customerListProvider.notifier).loadCustomers();
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final customer = state.customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: customer.isDealer
                            ? Colors.orange
                            : Colors.blue,
                        child: Icon(
                          customer.isDealer ? Icons.business : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        customer.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.phoneNumber),
                          if (customer.address != null &&
                              customer.address!.isNotEmpty)
                            Text(
                              customer.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: customer.isDealer
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              customer.isDealer ? 'Dealer' : 'Customer',
                              style: TextStyle(
                                color: customer.isDealer
                                    ? Colors.orange.shade800
                                    : Colors.blue.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.go('/customers/${customer.id}/edit'),
                      ),
                      onTap: () => context.go('/customers/${customer.id}'),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/customers/new'),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
