import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import '../../core/database/repository_providers.dart';
import '../../core/services/finance_math_service.dart';
import '../../shared/formatters/money_formatter.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final recentTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchLatest(limit: 5);
});

class CategorySpend {
  const CategorySpend({
    required this.name,
    required this.amountMinor,
    required this.color,
    required this.icon,
  });

  final String name;
  final int amountMinor;
  final int color;
  final String icon;
}

class BudgetAlert {
  const BudgetAlert({
    required this.budgetName,
    required this.overrunMinor,
    required this.percentage,
  });

  final String budgetName;
  final int overrunMinor;
  final double percentage;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalanceMinor,
    required this.monthlyIncomeMinor,
    required this.monthlyExpenseMinor,
    required this.netSavingsMinor,
    required this.recentExpenseTrend,
    required this.insights,
    required this.upcomingSubscriptionCount,
    required this.healthScore,
    required this.topCategories,
    required this.budgetAlerts,
  });

  final int totalBalanceMinor;
  final int monthlyIncomeMinor;
  final int monthlyExpenseMinor;
  final int netSavingsMinor;
  final List<double> recentExpenseTrend;
  final List<String> insights;
  final int upcomingSubscriptionCount;
  final int healthScore;
  final List<CategorySpend> topCategories;
  final List<BudgetAlert> budgetAlerts;
}

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final startOfMonth = selectedMonth;
  final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

  final txRepo = ref.watch(transactionRepositoryProvider);
  final wallets = await ref.watch(walletRepositoryProvider).watchAll().first;
  final transactions = await txRepo.list(limit: 5000);

  final now = DateTime.now();
  final startEpoch = startOfMonth.millisecondsSinceEpoch ~/ 1000;
  final endEpoch = endOfMonth.millisecondsSinceEpoch ~/ 1000;

  var income = 0;
  var expense = 0;

  final last7 = List<DateTime>.generate(
    7,
    (i) => DateTime(endOfMonth.year, endOfMonth.month, endOfMonth.day).subtract(Duration(days: 6 - i)),
    growable: false,
  );
  final expenseByDay = <DateTime, int>{for (final d in last7) d: 0};
  final expByCategory = <String, int>{};

  for (final tx in transactions) {
    if (tx.dateEpochSeconds >= startEpoch && tx.dateEpochSeconds <= endEpoch) {
      if (tx.type == 'income') {
        income += tx.amountMinor;
      } else if (tx.type == 'expense') {
        expense += tx.amountMinor;
        expByCategory[tx.categoryId] =
            (expByCategory[tx.categoryId] ?? 0) + tx.amountMinor;
      }
    }
    if (tx.type == 'expense') {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.dateEpochSeconds * 1000);
      final dayKey = DateTime(date.year, date.month, date.day);
      if (expenseByDay.containsKey(dayKey)) {
        expenseByDay[dayKey] = (expenseByDay[dayKey] ?? 0) + tx.amountMinor;
      }
    }
  }

  final totalBalance = wallets.fold<int>(0, (sum, w) => sum + w.currentBalanceMinor);
  final net = income - expense;

  final insights = <String>[];
  if (income == 0 && expense == 0) {
    insights.add('Bu ay henüz işlem bulunmuyor. İlk işlemini ekleyerek analitiği başlatabilirsin.');
  } else {
    insights.add(
      'Bu ay gelir: ${MoneyFormatter.formatMinor(minor: income, currency: 'TRY')}, gider: ${MoneyFormatter.formatMinor(minor: expense, currency: 'TRY')}.',
    );
    insights.add(
      net >= 0
          ? 'Bu ay ${MoneyFormatter.formatMinor(minor: net, currency: 'TRY')} pozitif dengedesin.'
          : 'Bu ay ${MoneyFormatter.formatMinor(minor: net.abs(), currency: 'TRY')} açık verdin.',
    );
  }

  final db = ref.watch(appDatabaseProvider);
  final upcomingThreshold = now.add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000;
  final nowEpoch = now.millisecondsSinceEpoch ~/ 1000;
  final subQuery = db.select(db.subscriptions)
    ..where((s) => s.deletedAt.isNull() & s.renewalEpochSeconds.isBetweenValues(nowEpoch, upcomingThreshold));
  final upcomingCount = (await subQuery.get()).length;

  final categories = await ref.watch(categoryRepositoryProvider).list();
  final categoryMap = {for (final c in categories) c.id: c};

  final topCategories = (expByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
      .take(5)
      .map((e) {
        final cat = categoryMap[e.key];
        return CategorySpend(
          name: cat?.name ?? 'Diğer',
          amountMinor: e.value,
          color: cat?.color ?? 0xFF64748B,
          icon: cat?.icon ?? 'payments',
        );
      })
      .toList(growable: false);

  final budgets = await ref.watch(budgetRepositoryProvider).watchAll().first;
  final budgetAlerts = <BudgetAlert>[];
  for (final b in budgets) {
    final int spent;
    if (b.categoryId != null) {
      spent = await txRepo.totalByTypeAndCategory(
          'expense', b.categoryId!, startOfMonth, endOfMonth);
    } else {
      spent = await txRepo.totalByType('expense', startOfMonth, endOfMonth);
    }
    if (spent > b.amountMinor && b.amountMinor > 0) {
      budgetAlerts.add(BudgetAlert(
        budgetName: b.name,
        overrunMinor: spent - b.amountMinor,
        percentage: spent / b.amountMinor,
      ));
    }
  }

  final mathService = const FinanceMathService();
  final healthScore = mathService.financialHealthScore(
    incomeMinor: income,
    expenseMinor: expense,
    budgetUsagePercent: income > 0 ? ((expense * 100) ~/ income) : 0,
    subscriptionLoadPercent: 0,
    debtLoadPercent: 0,
  );

  return DashboardSummary(
    totalBalanceMinor: totalBalance,
    monthlyIncomeMinor: income,
    monthlyExpenseMinor: expense,
    netSavingsMinor: net,
    recentExpenseTrend: last7.map((d) => (expenseByDay[d] ?? 0) / 100).toList(growable: false),
    insights: insights,
    upcomingSubscriptionCount: upcomingCount,
    healthScore: healthScore,
    topCategories: topCategories,
    budgetAlerts: budgetAlerts,
  );
});
