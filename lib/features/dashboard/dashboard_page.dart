import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/charts/spending_trend_chart.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/balance_card.dart';
import '../../shared/widgets/health_score_card.dart';
import '../../shared/widgets/insight_tile.dart';
import '../categories/categories_controller.dart';
import '../wallets/wallets_controller.dart';
import 'dashboard_controller.dart';
import 'dashboard_nav_bar.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Günaydın';
  if (h < 18) return 'İyi günler';
  return 'İyi akşamlar';
}

IconData _txIconData(String? iconName) {
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
    'work': Icons.work_outlined,
    'account_balance': Icons.account_balance_outlined,
    'credit_card': Icons.credit_card_outlined,
    'savings': Icons.savings_outlined,
    'attach_money': Icons.attach_money_rounded,
  };
  return map[iconName] ?? Icons.label_outline_rounded;
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final recentTx = ref.watch(recentTransactionsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Finova',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        toolbarHeight: 60,
      ),
      bottomNavigationBar: const DashboardNavBar(selectedIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('İşlem Ekle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(selectedMonth.year, selectedMonth.month - 1);
                  },
                ),
                Text(
                  _monthLabel(selectedMonth),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: isCurrentMonth
                      ? null
                      : () {
                          ref.read(selectedMonthProvider.notifier).state =
                              DateTime(selectedMonth.year, selectedMonth.month + 1);
                        },
                ),
              ],
            ),
          ),
          Expanded(
            child: summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Dashboard yüklenemedi')),
              data: (data) {
                final categories = categoriesAsync.valueOrNull ?? [];
                final wallets = walletsAsync.valueOrNull ?? [];
                final categoryMap = {for (final c in categories) c.id: c};
                final walletMap = {for (final w in wallets) w.id: w};

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      BalanceCard(
                        totalBalanceMinor: data.totalBalanceMinor,
                        currency: 'TRY',
                        monthlyIncomeMinor: data.monthlyIncomeMinor,
                        monthlyExpenseMinor: data.monthlyExpenseMinor,
                        netSavingsMinor: data.netSavingsMinor,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickChip(label: 'Cüzdanlar', icon: Icons.account_balance_wallet_outlined, onTap: () => context.push('/wallets')),
                            const SizedBox(width: 8),
                            _QuickChip(label: 'Kategoriler', icon: Icons.category_outlined, onTap: () => context.push('/categories')),
                            const SizedBox(width: 8),
                            _QuickChip(label: 'Bütçeler', icon: Icons.donut_small_outlined, onTap: () => context.push('/budgets')),
                            const SizedBox(width: 8),
                            _QuickChip(label: 'Analiz', icon: Icons.bar_chart_rounded, onTap: () => context.push('/analytics')),
                            const SizedBox(width: 8),
                            _QuickChip(label: 'Abonelikler', icon: Icons.subscriptions_outlined, onTap: () => context.push('/subscriptions')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      HealthScoreCard(score: data.healthScore),
                      if (data.budgetAlerts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...data.budgetAlerts.take(3).map((alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: ListTile(
                              leading: Icon(Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.onErrorContainer),
                              title: Text(
                                '${alert.budgetName} bütçesi aşıldı',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${(alert.percentage * 100 - 100).round()}% fazla harcandı',
                                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                              ),
                            ),
                          ),
                        )),
                      ],
                      if (data.topCategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Bu Ay En Fazla Harcama', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 88,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.topCategories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = data.topCategories[i];
                              return Container(
                                width: 108,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(cat.color).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Color(cat.color).withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(_txIconData(cat.icon), color: Color(cat.color), size: 18),
                                    const SizedBox(height: 4),
                                    Text(cat.name,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                      '₺${(cat.amountMinor / 100).toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(cat.color)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(height: 170, child: SpendingTrendChart(values: data.recentExpenseTrend)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Son İşlemler', style: Theme.of(context).textTheme.titleSmall),
                          TextButton(
                            onPressed: () => context.push('/transactions'),
                            child: const Text('Tümünü Gör'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      recentTx.when(
                        loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (txList) {
                          if (txList.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Henüz işlem yok.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: txList.map((tx) {
                              final cat = categoryMap[tx.categoryId];
                              final wallet = walletMap[tx.walletId];
                              final isIncome = tx.type == 'income';
                              final isTransfer = tx.type == 'transfer';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: cat != null ? Color(cat.color) : Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(_txIconData(cat?.icon), color: Colors.white, size: 14),
                                  ),
                                  title: Text(
                                    tx.note?.isNotEmpty == true ? tx.note! : (cat?.name ?? tx.type),
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    wallet?.name ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Text(
                                    '${isIncome ? '+' : isTransfer ? '' : '-'}${MoneyFormatter.formatMinor(minor: tx.amountMinor, currency: wallet?.currency ?? 'TRY')}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isIncome
                                          ? const Color(0xFF10B981)
                                          : isTransfer
                                              ? null
                                              : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(growable: false),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ...data.insights.map((insight) => InsightTile(text: insight)),
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

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
