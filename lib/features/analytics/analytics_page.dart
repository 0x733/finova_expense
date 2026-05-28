import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_nav_bar.dart';
import 'analytics_controller.dart';

IconData _analyticsIcon(String? name) {
  const map = <String, IconData>{
    'shopping_cart': Icons.shopping_cart_outlined,
    'restaurant': Icons.restaurant_outlined,
    'directions_bus': Icons.directions_bus_outlined,
    'receipt': Icons.receipt_outlined,
    'celebration': Icons.celebration_outlined,
    'local_hospital': Icons.local_hospital_outlined,
    'shopping_bag': Icons.shopping_bag_outlined,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'trending_up': Icons.trending_up_rounded,
    'payments': Icons.payments_outlined,
    'home': Icons.home_outlined,
    'directions_car': Icons.directions_car_outlined,
    'flight': Icons.flight_outlined,
    'fitness_center': Icons.fitness_center_outlined,
    'school': Icons.school_outlined,
    'pets': Icons.pets_outlined,
    'coffee': Icons.coffee_outlined,
    'movie': Icons.movie_outlined,
    'music_note': Icons.music_note_outlined,
    'sports_soccer': Icons.sports_soccer_outlined,
    'child_care': Icons.child_care_outlined,
    'work': Icons.work_outlined,
    'laptop': Icons.laptop_outlined,
    'phone_android': Icons.phone_android_outlined,
    'wifi': Icons.wifi_outlined,
    'bolt': Icons.bolt_outlined,
    'water_drop': Icons.water_drop_outlined,
    'local_gas_station': Icons.local_gas_station_outlined,
    'park': Icons.park_outlined,
    'attach_money': Icons.attach_money_rounded,
    'account_balance': Icons.account_balance_outlined,
    'credit_card': Icons.credit_card_outlined,
    'savings': Icons.savings_outlined,
  };
  return map[name] ?? Icons.label_outline_rounded;
}

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(analyticsSummaryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Scaffold(
      appBar: AppBar(title: const Text('Analitik')),
      bottomNavigationBar: const DashboardNavBar(selectedIndex: 2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1),
                ),
                Text(
                  _monthLabel(selectedMonth),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: isCurrentMonth
                      ? null
                      : () => ref.read(selectedMonthProvider.notifier).state =
                          DateTime(selectedMonth.year, selectedMonth.month + 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Analiz verisi yüklenemedi')),
              data: (data) {
                final hasData = data.categoryBreakdowns.isNotEmpty || data.totalIncomeMinor > 0;
                if (!hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: EmptyStateCard(
                        title: 'Bu ay için analiz verisi yok',
                        description: 'İşlemler eklendikçe grafikler burada görünür.',
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(analyticsSummaryProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _StatsRow(
                        totalIncome: data.totalIncomeMinor,
                        totalExpense: data.totalExpenseMinor,
                        savingsRate: data.savingsRatePercent,
                        avgDaily: data.avgDailyExpenseMinor,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(title: 'Son 6 Ay Gelir & Gider'),
                      SizedBox(
                        height: 200,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: data.monthlyIncomeSpots,
                                    isCurved: true,
                                    barWidth: 2.5,
                                    color: const Color(0xFF10B981),
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [const Color(0xFF10B981).withValues(alpha: 0.15), Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots: data.monthlyExpenseSpots,
                                    isCurved: true,
                                    barWidth: 2.5,
                                    color: const Color(0xFFEF4444),
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [const Color(0xFFEF4444).withValues(alpha: 0.1), Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                              ),
                              duration: const Duration(milliseconds: 650),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendDot(color: const Color(0xFF10B981), label: 'Gelir'),
                            const SizedBox(width: 16),
                            _LegendDot(color: const Color(0xFFEF4444), label: 'Gider'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(title: 'Son 14 Gün Günlük Gider'),
                      SizedBox(
                        height: 180,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                            child: BarChart(
                              BarChartData(
                                barGroups: data.dailyExpenseGroups,
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                                      '₺${rod.toY.toStringAsFixed(0)}',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              duration: const Duration(milliseconds: 650),
                            ),
                          ),
                        ),
                      ),
                      if (data.categoryExpenseSections.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionTitle(title: 'Gider Kategori Dağılımı'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: PieChart(
                                    PieChartData(
                                      sections: data.categoryExpenseSections,
                                      centerSpaceRadius: 44,
                                      sectionsSpace: 2,
                                    ),
                                    duration: const Duration(milliseconds: 650),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: data.categoryBreakdowns.take(6).toList().asMap().entries.map((e) {
                                    const pieColors = [
                                      Color(0xFF1D4ED8), Color(0xFF10B981), Color(0xFFF59E0B),
                                      Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF06B6D4),
                                    ];
                                    return _LegendDot(
                                      color: pieColors[e.key % pieColors.length],
                                      label: '${e.value.name} ${e.value.percent.toStringAsFixed(0)}%',
                                    );
                                  }).toList(growable: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (data.categoryBreakdowns.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionTitle(title: 'Kategoriye Göre Harcama'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: data.categoryBreakdowns
                                  .map((bd) => _CategoryRow(breakdown: bd))
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                      ],
                      if (data.incomeBreakdowns.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionTitle(title: 'Gelir Kaynakları'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: data.incomeBreakdowns
                                  .map((bd) => _CategoryRow(breakdown: bd))
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.breakdown});

  final CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(breakdown.color),
            child: Icon(_analyticsIcon(breakdown.icon), color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      breakdown.name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    Text(
                      MoneyFormatter.formatMinor(minor: breakdown.amountMinor, currency: 'TRY'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (breakdown.percent / 100).clamp(0.0, 1.0),
                    backgroundColor: Color(breakdown.color).withValues(alpha: 0.15),
                    color: Color(breakdown.color),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${breakdown.percent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
    required this.avgDaily,
  });

  final int totalIncome;
  final int totalExpense;
  final int savingsRate;
  final int avgDaily;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _StatCard(
          label: 'Toplam Gelir',
          value: MoneyFormatter.formatMinor(minor: totalIncome, currency: 'TRY'),
          color: const Color(0xFF10B981),
        ),
        _StatCard(
          label: 'Toplam Gider',
          value: MoneyFormatter.formatMinor(minor: totalExpense, currency: 'TRY'),
          color: const Color(0xFFEF4444),
        ),
        _StatCard(
          label: 'Tasarruf Oranı',
          value: '$savingsRate%',
          color: savingsRate >= 20
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
        ),
        _StatCard(
          label: 'Ort. Günlük Gider',
          value: MoneyFormatter.formatMinor(minor: avgDaily, currency: 'TRY'),
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
