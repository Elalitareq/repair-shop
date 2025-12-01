import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/batch_list_page.dart';
import '../../features/inventory/presentation/pages/batch_form_page.dart';
import '../../features/inventory/presentation/pages/item_form_page.dart';
import '../../features/inventory/presentation/pages/item_detail_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/repairs/presentation/pages/repairs_page.dart';
import '../../features/repairs/presentation/pages/repair_detail_page.dart';
import '../../features/repairs/presentation/pages/repair_form_page.dart';
import '../../features/sales/presentation/pages/sales_list_page.dart';
import '../../features/sales/presentation/pages/sale_form_page.dart';
import '../../features/sales/presentation/pages/sale_detail_page.dart';
import '../../features/sales/presentation/pages/barcode_scanner_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/settings/presentation/pages/categories_settings_page.dart';
import '../../features/settings/presentation/pages/conditions_settings_page.dart';
import '../../features/settings/presentation/pages/qualities_settings_page.dart';
import '../../features/settings/presentation/pages/payment_methods_settings_page.dart';
import '../../features/settings/presentation/pages/repair_states_settings_page.dart';
import '../../shared/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  final router = GoRouter(
    initialLocation: authState.isLoading
        ? '/splash'
        : (authState.isAuthenticated ? '/dashboard' : '/login'),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.path == '/splash';

      // If loading, go to splash, saving original location if not splash/login
      if (isLoading && !isSplash) {
        final from = state.uri.toString();
        return '/splash?from=${Uri.encodeComponent(from)}';
      }

      // If not loading and on splash, redirect based on auth
      if (!isLoading && isSplash) {
        final from = state.uri.queryParameters['from'];
        if (isLoggedIn) {
          if (from != null && from.isNotEmpty && from != '/login' && from != '/splash') {
            return from;
          }
          return '/dashboard';
        } else {
          return '/login';
        }
      }

      // If not logged in and not on login page, redirect to login
      if (!isLoading && !isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      return null; // no redirect
    },
    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main App Routes (Protected)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryPage(),
        routes: [
          GoRoute(
            path: 'items/new',
            name: 'item-create',
            builder: (context, state) => const ItemFormPage(),
          ),
          GoRoute(
            path: 'items/:id',
            name: 'item-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ItemDetailPage(itemId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'item-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ItemFormPage(itemId: int.tryParse(id));
                },
              ),
            ],
          ),
          GoRoute(
            path: 'batches',
            name: 'batches',
            builder: (context, state) => const BatchListPage(),
            routes: [
              GoRoute(
                path: 'new/:itemId',
                name: 'batch-create',
                builder: (context, state) {
                  final itemId = int.parse(state.pathParameters['itemId']!);
                  return BatchFormPage(itemId: itemId);
                },
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'batch-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return BatchFormPage(batchId: id);
                },
              ),
              GoRoute(
                path: ':id',
                name: 'batch-detail',
                builder: (context, state) =>
                    Container(), // TODO: Replace with Batch detail page
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'customer-create',
            builder: (context, state) => const CustomerFormPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'customer-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return CustomerDetailPage(customerId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'customer-edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CustomerFormPage(customerId: id);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/repairs',
        name: 'repairs',
        builder: (context, state) => const RepairsPage(),
        routes: [
          // Create new repair
          GoRoute(
            path: 'create',
            name: 'repair-create',
            builder: (context, state) => const RepairFormPage(),
          ),
          // Repair detail
          GoRoute(
            path: ':repairId',
            name: 'repair-detail',
            builder: (context, state) {
              final repairId = state.pathParameters['repairId']!;
              return RepairDetailPage(repairId: repairId);
            },
            routes: [
              // Edit repair
              GoRoute(
                path: 'edit',
                name: 'repair-edit',
                builder: (context, state) {
                  final repairId = state.pathParameters['repairId']!;
                  return RepairFormPage(repairId: repairId);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/sales',
        name: 'sales',
        builder: (context, state) => const SalesListPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'sale-create',
            builder: (context, state) => const SaleFormPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'sale-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return SaleDetailPage(saleId: id);
            },
          ),
          GoRoute(
            path: 'scan',
            name: 'barcode-scan',
            builder: (context, state) => const BarcodeScannerPage(),
          ),
        ],
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'categories',
            name: 'settings-categories',
            builder: (context, state) => const CategoriesSettingsPage(),
          ),
          GoRoute(
            path: 'conditions',
            name: 'settings-conditions',
            builder: (context, state) => const ConditionsSettingsPage(),
          ),
          GoRoute(
            path: 'qualities',
            name: 'settings-qualities',
            builder: (context, state) => const QualitiesSettingsPage(),
          ),
          GoRoute(
            path: 'payment-methods',
            name: 'settings-payment-methods',
            builder: (context, state) => const PaymentMethodsSettingsPage(),
          ),
          GoRoute(
            path: 'repair-states',
            name: 'settings-repair-states',
            builder: (context, state) => const RepairStatesSettingsPage(),
          ),
          // Duplicate "payment-methods" route removed to avoid name collision.
          GoRoute(
            path: 'backup',
            name: 'settings-backup',
            builder: (context, state) => const BackupPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );

  // Debug: route registration complete
  return router;
});
