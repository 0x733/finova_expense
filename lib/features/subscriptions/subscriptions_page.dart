import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/formatters/date_formatter.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../categories/categories_controller.dart';
import 'subscriptions_controller.dart';

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Abonelikler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Abonelik Ekle'),
      ),
      body: subscriptions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Abonelikler yüklenemedi')),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Abonelik kaydı yok',
                description:
                    'Netflix, Spotify veya diğer aboneliklerini buradan takip et.',
              ),
            );
          }
          final monthlyTotal =
              items.fold<int>(0, (sum, item) => sum + item.amountMinor);
          final yearlyTotal = monthlyTotal * 12;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Toplam Maliyet',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _CostChip(
                              label: 'Aylık',
                              amount: MoneyFormatter.formatMinor(
                                  minor: monthlyTotal, currency: 'TRY'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CostChip(
                              label: 'Yıllık',
                              amount: MoneyFormatter.formatMinor(
                                  minor: yearlyTotal, currency: 'TRY'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final renewalDate = DateTime.fromMillisecondsSinceEpoch(
                    item.renewalEpochSeconds * 1000);
                final daysLeft =
                    renewalDate.difference(DateTime.now()).inDays;
                return Dismissible(
                  key: ValueKey(item.id),
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
                      ref.read(subscriptionActionsProvider).softDelete(item.id),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6366F1),
                        child: Icon(Icons.subscriptions_outlined,
                            color: Colors.white, size: 18),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                          'Yenileme: ${DateFormatter.short(renewalDate)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            MoneyFormatter.formatMinor(
                                minor: item.amountMinor, currency: 'TRY'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            daysLeft <= 0
                                ? 'Bugün!'
                                : daysLeft == 1
                                    ? 'Yarın'
                                    : '$daysLeft gün kaldı',
                            style: TextStyle(
                              fontSize: 11,
                              color: daysLeft <= 3
                                  ? const Color(0xFFEF4444)
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddSubscriptionSheet(ref: ref),
    );
  }
}

class _CostChip extends StatelessWidget {
  const _CostChip({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(amount,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AddSubscriptionSheet extends StatefulWidget {
  const _AddSubscriptionSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _period = 'monthly';
  DateTime _renewalDate = DateTime.now().add(const Duration(days: 30));
  String? _categoryId;
  bool _reminder = true;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _renewalDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('tr'),
    );
    if (picked != null) setState(() => _renewalDate = picked);
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni Abonelik',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Abonelik adı'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Aylık tutar (₺)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tutar boş olamaz';
                  final parsed = MoneyFormatter.parseTryToMinor(v);
                  if (parsed == null || parsed <= 0) {
                    return 'Geçerli bir tutar gir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _period,
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Haftalık')),
                  DropdownMenuItem(value: 'monthly', child: Text('Aylık')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yıllık')),
                ],
                onChanged: (v) => setState(() => _period = v ?? 'monthly'),
                decoration: const InputDecoration(labelText: 'Periyot'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Yenileme tarihi'),
                subtitle: Text(DateFormatter.short(_renewalDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(context),
              ),
              categories.when(
                data: (cats) {
                  final expenseCats = cats
                      .where((c) => c.type == 'expense')
                      .toList(growable: false);
                  return DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    items: expenseCats
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(growable: false),
                    onChanged: (v) => setState(() => _categoryId = v),
                    decoration:
                        const InputDecoration(labelText: 'Kategori'),
                    validator: (v) =>
                        v == null ? 'Kategori seçimi zorunlu' : null,
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
                title: const Text('Yenileme hatırlatıcısı'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final amount =
                        MoneyFormatter.parseTryToMinor(_amountController.text);
                    if (amount == null) return;
                    await widget.ref
                        .read(subscriptionActionsProvider)
                        .create(
                          name: _nameController.text.trim(),
                          amountMinor: amount,
                          renewalDate: _renewalDate,
                          period: _period,
                          categoryId: _categoryId!,
                          reminder: _reminder,
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
      ),
    );
  }
}
