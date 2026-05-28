import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/repository_providers.dart';
import '../dashboard/dashboard_controller.dart';

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.name,
    required this.icon,
    required this.color,
    required this.amountMinor,
    required this.percent,
  });

  final String name;
  final String icon;
  final int color;
  final int amountMinor;
  final double percent;
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.monthlyIncomeSpots,
    required this.monthlyExpenseSpots,
    required this.categoryExpenseSections,
    required this.categoryBreakdowns,
    required this.incomeBreakdowns,
    required this.dailyExpenseGroups,
    required this.avgDailyExpenseMinor,
    required this.savingsRatePercent,
    required this.totalExpenseMinor,
    required this.totalIncomeMinor,
  });

  final List<FlSpot> monthlyIncomeSpots;
  final List<FlSpot> monthlyExpenseSpots;
  final List<PieChartSectionData> categoryExpenseSections;
  final List<CategoryBreakdown> categoryBreakdowns;
  final List<CategoryBreakdown> incomeBreakdowns;
  final List<BarChartGroupData> dailyExpenseGroups;
  final int avgDailyExpenseMinor;
  final int savingsRatePercent;
  final int totalExpenseMinor;
  final int totalIncomeMinor;
}

final analyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final startOfMonth = selectedMonth;
  final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

  final transactions = await ref.watch(transactionRepositoryProvider).list(limit: 5000);
  final categories = await ref.watch(categoryRepositoryProvider).list();
  final categoryMap = {for (final c in categories) c.id: c};

  final monthStarts = List<DateTime>.generate(
    6,
    (i) => DateTime(selectedMonth.year, selectedMonth.month - (5 - i), 1),
    growable: false,
  );
  final incomeByMonth = <DateTime, int>{for (final m in monthStarts) m: 0};
  final expenseByMonth = <DateTime, int>{for (final m in monthStarts) m: 0};

  final last14 = List<DateTime>.generate(
    14,
    (i) => DateTime(endOfMonth.year, endOfMonth.month, endOfMonth.day)
        .subtract(Duration(days: 13 - i)),
    growable: false,
  );
  final dayExpense = <DateTime, int>{for (final d in last14) d: 0};

  final expByCategory = <String, int>{};
  final incByCategory = <String, int>{};
  var totalIncome = 0;
  var totalExpense = 0;

  final startEpoch = startOfMonth.millisecondsSinceEpoch ~/ 1000;
  final endEpoch = endOfMonth.millisecondsSinceEpoch ~/ 1000;

  for (final tx in transactions) {
    final date = DateTime.fromMillisecondsSinceEpoch(tx.dateEpochSeconds * 1000);
    final monthKey = DateTime(date.year, date.month, 1);

    if (incomeByMonth.containsKey(monthKey)) {
      if (tx.type == 'income') incomeByMonth[monthKey] = (incomeByMonth[monthKey] ?? 0) + tx.amountMinor;
    }
    if (expenseByMonth.containsKey(monthKey)) {
      if (tx.type == 'expense') expenseByMonth[monthKey] = (expenseByMonth[monthKey] ?? 0) + tx.amountMinor;
    }

    if (tx.type == 'expense') {
      final dayKey = DateTime(date.year, date.month, date.day);
      if (dayExpense.containsKey(dayKey)) {
        dayExpense[dayKey] = (dayExpense[dayKey] ?? 0) + tx.amountMinor;
      }
    }

    if (tx.dateEpochSeconds >= startEpoch && tx.dateEpochSeconds <= endEpoch) {
      if (tx.type == 'expense') {
        expByCategory[tx.categoryId] = (expByCategory[tx.categoryId] ?? 0) + tx.amountMinor;
        totalExpense += tx.amountMinor;
      } else if (tx.type == 'income') {
        incByCategory[tx.categoryId] = (incByCategory[tx.categoryId] ?? 0) + tx.amountMinor;
        totalIncome += tx.amountMinor;
      }
    }
  }

  final monthlyIncomeSpots = <FlSpot>[
    for (var i = 0; i < monthStarts.length; i++)
      FlSpot(i.toDouble(), (incomeByMonth[monthStarts[i]] ?? 0) / 100),
  ];
  final monthlyExpenseSpots = <FlSpot>[
    for (var i = 0; i < monthStarts.length; i++)
      FlSpot(i.toDouble(), (expenseByMonth[monthStarts[i]] ?? 0) / 100),
  ];

  final sortedExpense = (expByCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)));

  final categoryBreakdowns = sortedExpense.map((e) {
    final cat = categoryMap[e.key];
    return CategoryBreakdown(
      name: cat?.name ?? 'Diğer',
      icon: cat?.icon ?? 'payments',
      color: cat?.color ?? 0xFF64748B,
      amountMinor: e.value,
      percent: totalExpense == 0 ? 0.0 : e.value * 100.0 / totalExpense,
    );
  }).toList(growable: false);

  final incomeBreakdowns = (incByCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)))
    .map((e) {
      final cat = categoryMap[e.key];
      final totalInc = incByCategory.values.fold(0, (a, b) => a + b);
      return CategoryBreakdown(
        name: cat?.name ?? 'Diğer',
        icon: cat?.icon ?? 'payments',
        color: cat?.color ?? 0xFF1D4ED8,
        amountMinor: e.value,
        percent: totalInc == 0 ? 0.0 : e.value * 100.0 / totalInc,
      );
    }).toList(growable: false);

  const pieColors = [
    Color(0xFF1D4ED8), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF06B6D4),
  ];
  final sections = <PieChartSectionData>[];
  for (var i = 0; i < categoryBreakdowns.take(6).length; i++) {
    final bd = categoryBreakdowns[i];
    sections.add(PieChartSectionData(
      value: bd.percent,
      title: '',
      color: pieColors[i % pieColors.length],
      radius: 54,
    ));
  }

  final barGroups = <BarChartGroupData>[
    for (var i = 0; i < last14.length; i++)
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (dayExpense[last14[i]] ?? 0) / 100,
            color: const Color(0xFF6366F1),
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
  ];

  final nonZeroDays = dayExpense.values.where((v) => v > 0).length;
  final avgDaily = nonZeroDays == 0
      ? 0
      : dayExpense.values.fold<int>(0, (a, b) => a + b) ~/ nonZeroDays;
  final savingsRate = totalIncome == 0
      ? 0
      : ((totalIncome - totalExpense) * 100 ~/ totalIncome).clamp(-999, 100);

  return AnalyticsSummary(
    monthlyIncomeSpots: monthlyIncomeSpots,
    monthlyExpenseSpots: monthlyExpenseSpots,
    categoryExpenseSections: sections,
    categoryBreakdowns: categoryBreakdowns,
    incomeBreakdowns: incomeBreakdowns,
    dailyExpenseGroups: barGroups,
    avgDailyExpenseMinor: avgDaily,
    savingsRatePercent: savingsRate,
    totalExpenseMinor: totalExpense,
    totalIncomeMinor: totalIncome,
  );
});
