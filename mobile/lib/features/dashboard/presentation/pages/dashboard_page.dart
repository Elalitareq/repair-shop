import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';

// class _StatData {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   _StatData(this.title, this.value, this.icon, this.color);
// }

class _ActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionData(this.title, this.icon, this.color, this.onTap);
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQueryData = MediaQuery.of(context);
    final screenWidth = mediaQueryData.size.width;

    // Responsive breakpoints
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    // Calculate responsive values
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    // final statCardsPerRow = isDesktop ? 4 : (isTablet ? 2 : 2);
    final actionCardsPerRow = isDesktop ? 4 : (isTablet ? 3 : 2);
    final maxContentWidth = isDesktop ? 1400.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isDesktop ? 32.0 : 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Section
                // Text(
                //   'Overview',
                //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: isDesktop ? 24 : 16),
                // _buildStatsGrid(
                //   context,
                //   crossAxisCount: statCardsPerRow,
                //   childAspectRatio: isDesktop ? 2.5 : (isTablet ? 2.0 : 1.5),
                // ),
                SizedBox(height: isDesktop ? 48 : 32),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                _buildActionsGrid(
                  context,
                  crossAxisCount: actionCardsPerRow,
                  childAspectRatio: isDesktop ? 1.2 : 1.0,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildStatsGrid(
  //   BuildContext context, {
  //   required int crossAxisCount,
  //   required double childAspectRatio,
  // }) {
  //   final stats = [
  //     _StatData('Pending Repairs', '15', Icons.build, Colors.orange),
  //     _StatData('Completed Today', '8', Icons.check_circle, Colors.green),
  //     _StatData('Low Stock Items', '3', Icons.inventory, Colors.red),
  //     _StatData('Total Customers', '247', Icons.people, Colors.blue),
  //   ];

  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: crossAxisCount,
  //       crossAxisSpacing: 16,
  //       mainAxisSpacing: 16,
  //       childAspectRatio: childAspectRatio,
  //     ),
  //     itemCount: stats.length,
  //     itemBuilder: (context, index) {
  //       final stat = stats[index];
  //       return _buildStatCard(
  //         context,
  //         stat.title,
  //         stat.value,
  //         stat.icon,
  //         stat.color,
  //       );
  //     },
  //   );
  // }

  Widget _buildActionsGrid(
    BuildContext context, {
    required int crossAxisCount,
    required double childAspectRatio,
  }) {
    final actions = [
      _ActionData(
        'Inventory',
        Icons.inventory_2,
        Colors.purple,
        () => context.go('/inventory'),
      ),
      _ActionData(
        'Repairs',
        Icons.build_circle,
        Colors.orange,
        () => context.go('/repairs'),
      ),
      _ActionData(
        'Sales',
        Icons.point_of_sale,
        Colors.green,
        () => context.go('/sales'),
      ),
      _ActionData(
        'Customers',
        Icons.people,
        Colors.blue,
        () => context.go('/customers'),
      ),
      _ActionData('Reports', Icons.analytics, Colors.green, () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reports coming soon')));
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          context,
          action.title,
          action.icon,
          action.color,
          action.onTap,
        );
      },
    );
  }

  // Widget _buildStatCard(
  //   BuildContext context,
  //   String title,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Icon(icon, color: color, size: 32),
  //               Text(
  //                 value,
  //                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  //                   color: color,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text(title, style: Theme.of(context).textTheme.bodyMedium),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
