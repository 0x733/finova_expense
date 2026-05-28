import 'package:finova_expense/core/database/app_database.dart';
import 'package:finova_expense/features/categories/categories_controller.dart';
import 'package:finova_expense/features/dashboard/dashboard_controller.dart';
import 'package:finova_expense/features/dashboard/dashboard_page.dart';
import 'package:finova_expense/features/transactions/transactions_controller.dart';
import 'package:finova_expense/features/transactions/transactions_page.dart';
import 'package:finova_expense/features/wallets/wallets_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard render', (tester) async {
    const stubSummary = DashboardSummary(
      totalBalanceMinor: 0,
      monthlyIncomeMinor: 0,
      monthlyExpenseMinor: 0,
      netSavingsMinor: 0,
      recentExpenseTrend: [],
      insights: [],
      upcomingSubscriptionCount: 0,
      healthScore: 0,
      topCategories: [],
      budgetAlerts: [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith((ref) async => stubSummary),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
  });

  testWidgets('Empty state görünümü', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWith((ref) => Stream<List<Transaction>>.value(const [])),
        ],
        child: const MaterialApp(home: TransactionsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Henüz işlem yok'), findsOneWidget);
  });

  testWidgets('Transaction form validation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletsProvider.overrideWith((ref) => Stream<List<Wallet>>.value(const [])),
          categoriesProvider.overrideWith((ref) => Stream<List<Category>>.value(const [])),
          transactionsProvider.overrideWith((ref) => Stream<List<Transaction>>.value(const [])),
        ],
        child: const MaterialApp(home: TransactionsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('İşlem Ekle'));
    await tester.pumpAndSettle();
    expect(find.text('İşlem eklemek için önce en az bir cüzdan ve kategori oluşturmalısın.'), findsOneWidget);
  });
}
