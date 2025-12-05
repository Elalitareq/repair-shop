import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final maxContentWidth = isDesktop ? 1200.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Categories Section
                _buildSettingsSection(
                  context,
                  title: 'Categories',
                  description: 'Manage item categories and subcategories',
                  icon: Icons.category,
                  color: Colors.purple,
                  onTap: () => context.push('/settings/categories'),
                ),
                const SizedBox(height: 16),

                // Conditions Section
                _buildSettingsSection(
                  context,
                  title: 'Conditions',
                  description: 'Manage item condition types',
                  icon: Icons.star_rate,
                  color: Colors.orange,
                  onTap: () => context.push('/settings/conditions'),
                ),
                const SizedBox(height: 16),

                // Qualities Section
                _buildSettingsSection(
                  context,
                  title: 'Qualities',
                  description: 'Manage item quality grades',
                  icon: Icons.grade,
                  color: Colors.amber,
                  onTap: () => context.push('/settings/qualities'),
                ),
                const SizedBox(height: 16),

                // Payment Methods Section
                _buildSettingsSection(
                  context,
                  title: 'Payment Methods',
                  description: 'Manage available payment methods',
                  icon: Icons.payment,
                  color: Colors.indigo,
                  onTap: () => context.push('/settings/payment-methods'),
                ),
                const SizedBox(height: 16),

                // Repair Status Section
                _buildSettingsSection(
                  context,
                  title: 'Repair Status',
                  description: 'Manage repair workflow statuses',
                  icon: Icons.build_circle,
                  color: Colors.blue,
                  onTap: () => context.push('/settings/repair-states'),
                ),
                const SizedBox(height: 16),

                // Issue Types Section
                _buildSettingsSection(
                  context,
                  title: 'Issue Types',
                  description: 'Manage repair issue types',
                  icon: Icons.bug_report,
                  color: Colors.red,
                  onTap: () => context.push('/settings/issue-types'),
                ),
                const SizedBox(height: 32),

                // System Settings Header
                Text(
                  'System Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // User Management
                _buildSettingsSection(
                  context,
                  title: 'Users & Permissions',
                  description: 'Manage user accounts and roles',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Backup & Sync
                _buildSettingsSection(
                  context,
                  title: 'Backup & Sync',
                  description: 'Configure data backup and synchronization',
                  icon: Icons.cloud_sync,
                  color: Colors.teal,
                  onTap: () => context.push('/settings/backup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
