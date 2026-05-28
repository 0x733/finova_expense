import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/formatters/date_formatter.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import 'savings_controller.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasarruf Hedefleri')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Hedef Ekle'),
      ),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Hedefler yüklenemedi')),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Tasarruf hedefi yok',
                description:
                    'Tatil, ev veya araba için tasarruf hedefi belirleyerek ilerlemeyi takip et.',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final goal = items[index];
              final progress = goal.targetMinor == 0
                  ? 0.0
                  : (goal.currentMinor / goal.targetMinor).clamp(0.0, 1.0);
              final targetDate = DateTime.fromMillisecondsSinceEpoch(
                  goal.targetEpochSeconds * 1000);
              final daysLeft = targetDate.difference(DateTime.now()).inDays;
              final monthsLeft = (daysLeft / 30).ceil();
              final remaining = goal.targetMinor - goal.currentMinor;
              final monthlyNeeded =
                  monthsLeft > 0 ? (remaining / monthsLeft).ceil() : remaining;

              return Dismissible(
                key: ValueKey(goal.id),
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
                    ref.read(savingsActionsProvider).softDelete(goal.id),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ProgressRing(progress: progress),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(goal.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${MoneyFormatter.formatMinor(minor: goal.currentMinor, currency: 'TRY')} / ${MoneyFormatter.formatMinor(minor: goal.targetMinor, currency: 'TRY')}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Hedef: ${DateFormatter.short(targetDate)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (progress < 1.0)
                              FilledButton.tonal(
                                onPressed: () => _showAddAmountDialog(
                                    context, ref, goal.id, goal.currentMinor),
                                child: const Text('Ekle'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              daysLeft > 0 ? '$daysLeft gün kaldı' : 'Süre doldu',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: daysLeft <= 30
                                      ? const Color(0xFFEF4444)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                            if (monthsLeft > 0 && remaining > 0)
                              Text(
                                'Aylık: ${MoneyFormatter.formatMinor(minor: monthlyNeeded, currency: 'TRY')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: const Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.w600),
                              ),
                          ],
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

  Future<void> _showAddAmountDialog(
      BuildContext context, WidgetRef ref, String goalId, int currentMinor) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Birikime Ekle'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Eklenecek tutar (₺)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ekle')),
        ],
      ),
    );
    controller.dispose();
    if (confirmed != true || !context.mounted) return;
    final amount = MoneyFormatter.parseTryToMinor(controller.text);
    if (amount == null || amount <= 0) return;
    await ref.read(savingsActionsProvider).addToGoal(goalId, amount, currentMinor);
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddSavingsSheet(ref: ref),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: const Color(0xFF10B981),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AddSavingsSheet extends StatefulWidget {
  const _AddSavingsSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddSavingsSheet> createState() => _AddSavingsSheetState();
}

class _AddSavingsSheetState extends State<_AddSavingsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('tr'),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yeni Tasarruf Hedefi',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hedef adı'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Hedef tutar (₺)'),
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
            TextFormField(
              controller: _currentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Mevcut birikim (₺, opsiyonel)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hedef tarih'),
              subtitle: Text(DateFormatter.short(_targetDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final target =
                      MoneyFormatter.parseTryToMinor(_targetController.text);
                  if (target == null) return;
                  final currentStr = _currentController.text.trim();
                  final current = currentStr.isEmpty
                      ? 0
                      : MoneyFormatter.parseTryToMinor(currentStr) ?? 0;
                  await widget.ref.read(savingsActionsProvider).create(
                        name: _nameController.text.trim(),
                        targetMinor: target,
                        targetDate: _targetDate,
                        currentMinor: current,
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
