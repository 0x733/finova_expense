import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import 'wallets_controller.dart';

const _kWalletIcons = <String, IconData>{
  'payments': Icons.payments_outlined,
  'account_balance': Icons.account_balance_outlined,
  'credit_card': Icons.credit_card_outlined,
  'savings': Icons.savings_outlined,
  'currency_bitcoin': Icons.currency_bitcoin_outlined,
  'account_balance_wallet': Icons.account_balance_wallet_outlined,
  'attach_money': Icons.attach_money_rounded,
  'euro': Icons.euro_rounded,
  'currency_pound': Icons.currency_pound_rounded,
  'school': Icons.school_outlined,
  'home': Icons.home_outlined,
  'directions_car': Icons.directions_car_outlined,
  'flight': Icons.flight_outlined,
  'shopping_cart': Icons.shopping_cart_outlined,
  'work': Icons.work_outlined,
};

class WalletsPage extends ConsumerWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final archivedAsync = ref.watch(archivedWalletsProvider);

    if (walletsAsync.isLoading || archivedAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (walletsAsync.hasError || archivedAsync.hasError) {
      return const Scaffold(
        body: Center(child: Text('Hesaplar yüklenemedi')),
      );
    }

    final active = walletsAsync.value ?? [];
    final archived = archivedAsync.value ?? [];
    final totalBalance = active.fold<int>(0, (s, w) => s + w.currentBalanceMinor);

    return Scaffold(
      appBar: AppBar(title: const Text('Cüzdanlar / Hesaplar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Hesap Ekle'),
      ),
      body: active.isEmpty && archived.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Hesap bulunamadı',
                description:
                    'Nakit, banka veya kredi kartı hesabı ekleyerek bakiyeni takip et.',
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam Bakiye',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              MoneyFormatter.formatMinor(
                                  minor: totalBalance, currency: 'TRY'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (active.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey('active_${active[index].id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.archive_outlined,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) => ref
                                .read(walletActionsProvider)
                                .archive(active[index].id),
                            child: _buildTile(context, ref, active[index]),
                          ),
                        ),
                        childCount: active.length,
                      ),
                    ),
                  ),
                if (archived.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Chip(
                        avatar: const Icon(Icons.archive_outlined, size: 16),
                        label: const Text('Arşiv'),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey('archived_${archived[index].id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.unarchive_outlined,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) => ref
                                .read(walletActionsProvider)
                                .unarchive(archived[index].id),
                            child: _buildTile(context, ref, archived[index],
                                archived: true),
                          ),
                        ),
                        childCount: archived.length,
                      ),
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
    );
  }

  IconData _walletIcon(String iconKey) =>
      _kWalletIcons[iconKey] ?? Icons.payments_outlined;

  String _walletTypeLabel(String type) => switch (type) {
        'cash' => 'Nakit',
        'bank' => 'Banka Hesabı',
        'creditCard' => 'Kredi Kartı',
        'savings' => 'Birikim Hesabı',
        'crypto' => 'Kripto Cüzdan',
        _ => 'Diğer',
      };

  Widget _buildTile(BuildContext context, WidgetRef ref, Wallet item,
      {bool archived = false}) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () => _showSheet(context, ref, wallet: item),
      leading: CircleAvatar(
        backgroundColor: Color(item.color),
        radius: 20,
        child: Icon(_walletIcon(item.icon), color: Colors.white, size: 18),
      ),
      title: Text(item.name),
      subtitle: Text(
        _walletTypeLabel(item.type) + (archived ? ' · Arşivlendi' : ''),
      ),
      trailing: Text(
        MoneyFormatter.formatMinor(
            minor: item.currentBalanceMinor, currency: item.currency),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: item.currentBalanceMinor >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context, WidgetRef ref,
      {Wallet? wallet}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WalletSheet(ref: ref, wallet: wallet),
    );
  }
}

class _WalletSheet extends StatefulWidget {
  const _WalletSheet({required this.ref, this.wallet});

  final WidgetRef ref;
  final Wallet? wallet;

  @override
  State<_WalletSheet> createState() => _WalletSheetState();
}

class _WalletSheetState extends State<_WalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'cash';
  String _currency = 'TRY';
  int _selectedColor = 0xFF10B981;
  String _selectedIcon = 'payments';
  bool _isSaving = false;

  static const _colorOptions = [
    0xFF10B981,
    0xFF1D4ED8,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF8B5CF6,
    0xFF06B6D4,
    0xFFEC4899,
    0xFF64748B,
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    if (w != null) {
      _nameController.text = w.name;
      _type = w.type;
      _currency = w.currency;
      _selectedColor = w.color;
      _selectedIcon = w.icon;
      _balanceController.text =
          MoneyFormatter.formatMinorForInput(w.currentBalanceMinor);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.wallet != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Hesabı Düzenle' : 'Yeni Hesap',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hesap adı'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Nakit')),
                  DropdownMenuItem(
                      value: 'bank', child: Text('Banka Hesabı')),
                  DropdownMenuItem(
                      value: 'creditCard', child: Text('Kredi Kartı')),
                  DropdownMenuItem(
                      value: 'savings', child: Text('Birikim Hesabı')),
                  DropdownMenuItem(
                      value: 'crypto', child: Text('Kripto Cüzdan')),
                  DropdownMenuItem(value: 'other', child: Text('Diğer')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'cash'),
                decoration: const InputDecoration(labelText: 'Hesap türü'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText:
                            isEdit ? 'Mevcut bakiye' : 'Başlangıç bakiyesi',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final parsed = MoneyFormatter.parseTryToMinor(v);
                        if (parsed == null) return 'Geçersiz tutar';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _currency,
                    items: const [
                      DropdownMenuItem(value: 'TRY', child: Text('₺ TRY')),
                      DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                      DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
                    ],
                    onChanged: (v) =>
                        setState(() => _currency = v ?? 'TRY'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Renk', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colorOptions.map((color) {
                  final selected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                                width: 2.5)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 12),
              Text('İkon', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kWalletIcons.entries.map((entry) {
                  final selected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIcon = entry.key),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        entry.value,
                        color: selected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSaving = true);
                    final balanceStr = _balanceController.text.trim();
                    final balanceMinor = balanceStr.isEmpty
                        ? 0
                        : MoneyFormatter.parseTryToMinor(balanceStr) ?? 0;
                    final actions = widget.ref.read(walletActionsProvider);
                    if (widget.wallet == null) {
                      await actions.create(
                        name: _nameController.text.trim(),
                        type: _type,
                        currency: _currency,
                        color: _selectedColor,
                        icon: _selectedIcon,
                        initialBalanceMinor: balanceMinor,
                      );
                    } else {
                      await actions.update(
                        id: widget.wallet!.id,
                        name: _nameController.text.trim(),
                        type: _type,
                        currency: _currency,
                        color: _selectedColor,
                        icon: _selectedIcon,
                      );
                      if (balanceMinor != widget.wallet!.currentBalanceMinor) {
                        await actions.setBalance(
                            widget.wallet!.id, balanceMinor);
                      }
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kaydet'),
                ),
              ),
              if (isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                    onPressed: () async {
                      await widget.ref
                          .read(walletActionsProvider)
                          .softDelete(widget.wallet!.id);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hesabı Sil'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
