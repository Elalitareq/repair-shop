import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/item_form_page.dart';
import '../../features/inventory/presentation/pages/item_detail_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/repairs/presentation/pages/repairs_page.dart';
import '../../features/repairs/presentation/pages/repair_detail_page.dart';
import '../../features/repairs/presentation/pages/repair_form_page.dart';
import '../../shared/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/dashboard' : '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and on login page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      return null; // no redirect
    },
    routes: [
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
          GoRoute(path: 'items/new', name: 'item-create', builder: (context, state) => const ItemFormPage()),
          GoRoute(
            path: 'items/:id',
            name: 'item-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ItemDetailPage(itemId: id);
            },
            routes: [
              GoRoute(path: 'edit', name: 'item-edit', builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ItemFormPage(itemId: int.tryParse(id));
              }),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
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
});
