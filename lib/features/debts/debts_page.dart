import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/formatters/date_formatter.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import 'debts_controller.dart';

class DebtsPage extends ConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Borç / Alacak')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kayıt Ekle'),
      ),
      body: debts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Borç kayıtları yüklenemedi')),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Borç kaydı yok',
                description:
                    'Borç verdiğin veya aldığın kayıtları takip etmek için ekleme yap.',
              ),
            );
          }

          final receivables =
              items.where((d) => d.isReceivable).toList(growable: false);
          final payables =
              items.where((d) => !d.isReceivable).toList(growable: false);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (receivables.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Alacaklarım',
                  total: receivables.fold<int>(
                      0, (s, d) => s + (d.amountMinor - d.paidMinor)),
                  color: const Color(0xFF10B981),
                ),
                ...receivables.map((d) => _DebtTile(debt: d, ref: ref)),
                const SizedBox(height: 16),
              ],
              if (payables.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Borçlarım',
                  total: payables.fold<int>(
                      0, (s, d) => s + (d.amountMinor - d.paidMinor)),
                  color: const Color(0xFFEF4444),
                ),
                ...payables.map((d) => _DebtTile(debt: d, ref: ref)),
              ],
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
      builder: (ctx) => _AddDebtSheet(ref: ref),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.total,
    required this.color,
  });

  final String title;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(
            MoneyFormatter.formatMinor(minor: total, currency: 'TRY'),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt, required this.ref});

  final Debt debt;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final remaining = debt.amountMinor - debt.paidMinor;
    final progress =
        debt.amountMinor == 0 ? 0.0 : (debt.paidMinor / debt.amountMinor).clamp(0.0, 1.0);
    final isPaid = remaining <= 0;
    return Dismissible(
      key: ValueKey(debt.id),
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
      onDismissed: (_) => ref.read(debtActionsProvider).softDelete(debt.id),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isPaid ? null : () => _showPaymentDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(debt.personName,
                        style: Theme.of(context).textTheme.titleSmall),
                    if (isPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Ödendi',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: isPaid
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kalan: ${MoneyFormatter.formatMinor(minor: remaining, currency: 'TRY')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Vade: ${DateFormatter.short(DateTime.fromMillisecondsSinceEpoch(debt.dueEpochSeconds * 1000))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (!isPaid)
                  Text(
                    'Ödeme kaydetmek için dokun',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ödeme Kaydet'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Ödenen tutar (₺)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Kaydet')),
        ],
      ),
    );
    controller.dispose();
    if (confirmed != true || !context.mounted) return;
    final payment = MoneyFormatter.parseTryToMinor(controller.text);
    if (payment == null || payment <= 0) return;
    final newPaid = (debt.paidMinor + payment).clamp(0, debt.amountMinor);
    await ref.read(debtActionsProvider).updatePaid(debt.id, newPaid);
  }
}

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isReceivable = false;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('tr'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Yeni Borç / Alacak',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Borç aldım')),
                ButtonSegment(value: true, label: Text('Borç verdim')),
              ],
              selected: {_isReceivable},
              onSelectionChanged: (v) =>
                  setState(() => _isReceivable = v.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kişi adı'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Tutar (₺)'),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Son ödeme tarihi'),
              subtitle: Text(DateFormatter.short(_dueDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(context),
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
                  await widget.ref.read(debtActionsProvider).create(
                    personName: _nameController.text.trim(),
                    amountMinor: amount,
                    dueDate: _dueDate,
                    isReceivable: _isReceivable,
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
