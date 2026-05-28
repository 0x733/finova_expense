import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../categories/categories_controller.dart';
import '../dashboard/dashboard_nav_bar.dart';
import 'budgets_controller.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsWithProgressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bütçeler')),
      bottomNavigationBar: const DashboardNavBar(selectedIndex: 3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Bütçe Ekle'),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Bütçeler yüklenemedi')),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Bütçe bulunamadı',
                description:
                    'Aylık veya kategori bazlı bütçe oluşturarak harcamanı kontrol et.',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.budget.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                onDismissed: (_) =>
                    ref.read(budgetActionsProvider).softDelete(item.budget.id),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.budget.name,
                                style: Theme.of(context).textTheme.titleSmall),
                            if (item.isOverBudget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .errorContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Aşıldı',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                        fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 8,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                            color: _progressColor(item.progress),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Harcanan: ${MoneyFormatter.formatMinor(minor: item.spentMinor, currency: 'TRY')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Bütçe: ${MoneyFormatter.formatMinor(minor: item.budget.amountMinor, currency: 'TRY')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (!item.isOverBudget)
                          Text(
                            'Kalan: ${MoneyFormatter.formatMinor(minor: item.remainingMinor, currency: 'TRY')}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: const Color(0xFF10B981)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFFEF4444);
    if (progress >= 0.9) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddBudgetSheet(ref: ref),
    );
  }
}

class _AddBudgetSheet extends StatefulWidget {
  const _AddBudgetSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _period = 'monthly';
  String? _categoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.ref.watch(categoriesProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yeni Bütçe', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Bütçe adı'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Bütçe tutarı (₺)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Tutar boş olamaz';
                final parsed = MoneyFormatter.parseTryToMinor(v);
                if (parsed == null || parsed <= 0) return 'Geçerli bir tutar gir';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _period,
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Aylık')),
                DropdownMenuItem(value: 'weekly', child: Text('Haftalık')),
              ],
              onChanged: (v) => setState(() => _period = v ?? 'monthly'),
              decoration: const InputDecoration(labelText: 'Periyot'),
            ),
            const SizedBox(height: 12),
            categories.when(
              data: (cats) {
                final expenseCats =
                    cats.where((c) => c.type == 'expense').toList(growable: false);
                return DropdownButtonFormField<String?>(
                  initialValue: _categoryId,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Tüm harcamalar')),
                    ...expenseCats.map((c) =>
                        DropdownMenuItem<String?>(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration:
                      const InputDecoration(labelText: 'Kategori (opsiyonel)'),
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final amount =
                      MoneyFormatter.parseTryToMinor(_amountController.text);
                  if (amount == null) return;
                  await widget.ref.read(budgetActionsProvider).create(
                    name: _nameController.text.trim(),
                    amountMinor: amount,
                    period: _period,
                    categoryId: _categoryId,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
