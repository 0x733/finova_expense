import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_providers.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/budgets/budgets_page.dart';
import '../../features/categories/categories_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/debts/debts_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/savings/savings_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/subscriptions/subscriptions_page.dart';
import '../../features/transactions/transactions_page.dart';
import '../../features/wallets/wallets_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) async {
      if (state.matchedLocation == '/onboarding') return null;
      final db = ref.read(appDatabaseProvider);
      final settings = await (db.select(db.appSettings)
            ..where((s) => s.id.equals('default-settings')))
          .getSingleOrNull();
      if (settings == null || !settings.onboardingCompleted) {
        return '/onboarding';
      }
      return null;
    },
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/transactions', builder: (_, __) => const TransactionsPage()),
      GoRoute(path: '/budgets', builder: (_, __) => const BudgetsPage()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
      GoRoute(path: '/wallets', builder: (_, __) => const WalletsPage()),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsPage()),
      GoRoute(path: '/subscriptions', builder: (_, __) => const SubscriptionsPage()),
      GoRoute(path: '/debts', builder: (_, __) => const DebtsPage()),
      GoRoute(path: '/savings', builder: (_, __) => const SavingsPage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
