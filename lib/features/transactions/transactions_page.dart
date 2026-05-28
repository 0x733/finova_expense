import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/services/ocr_service.dart';
import '../../shared/formatters/date_formatter.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../categories/categories_controller.dart';
import '../dashboard/dashboard_nav_bar.dart';
import '../wallets/wallets_controller.dart';
import 'transactions_controller.dart';

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
    'currency_bitcoin': Icons.currency_bitcoin_outlined,
  };
  return map[iconName] ?? Icons.label_outline_rounded;
}

String _dateGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Bugün';
  if (d == today.subtract(const Duration(days: 1))) return 'Dün';
  return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
}

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _filterType = 'all';

  List<Object> _buildGrouped(List<Transaction> items) {
    final result = <Object>[];
    String? lastKey;
    for (final tx in items) {
      final date = DateTime.fromMillisecondsSinceEpoch(tx.dateEpochSeconds * 1000);
      final key = _dateGroupLabel(date);
      if (key != lastKey) {
        result.add(key);
        lastKey = key;
      }
      result.add(tx);
    }
    return result;
  }

  Future<void> _showSheet(
    BuildContext context,
    WidgetRef ref, {
    Transaction? transaction,
    required List<Wallet> wallets,
    required List<Category> categories,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TransactionSheet(
        ref: ref,
        transaction: transaction,
        wallets: wallets,
        categories: categories,
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, Transaction tx,
      Map<String, Category> categoryMap, Map<String, Wallet> walletMap) {
    final category = categoryMap[tx.categoryId];
    final wallet = walletMap[tx.walletId];
    final isIncome = tx.type == 'income';
    final isTransfer = tx.type == 'transfer';
    final amountColor = isIncome
        ? const Color(0xFF10B981)
        : isTransfer
            ? null
            : const Color(0xFFEF4444);
    final amountPrefix = isIncome ? '+' : isTransfer ? '' : '-';

    return Dismissible(
      key: ValueKey(tx.id),
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
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('İşlemi Sil'),
            content: const Text('Bu işlem silinecek ve cüzdan bakiyesi geri alınacak. Emin misin?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => ref.read(transactionActionsProvider).delete(tx),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => _showSheet(context, ref,
            transaction: tx,
            wallets: walletMap.values.toList(),
            categories: categoryMap.values.toList()),
        leading: CircleAvatar(
          backgroundColor: category != null
              ? Color(category.color)
              : Theme.of(context).colorScheme.primaryContainer,
          radius: 20,
          child: Icon(_txIconData(category?.icon), color: Colors.white, size: 18),
        ),
        title: Text(tx.note?.isNotEmpty == true ? tx.note! : (category?.name ?? _typeLabel(tx.type))),
        subtitle: Text(
            '${wallet?.name ?? ''} · ${DateFormatter.short(DateTime.fromMillisecondsSinceEpoch(tx.dateEpochSeconds * 1000))}'),
        trailing: Text(
          '$amountPrefix${MoneyFormatter.formatMinor(minor: tx.amountMinor, currency: wallet?.currency ?? 'TRY')}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'income' => 'Gelir',
        'expense' => 'Gider',
        'transfer' => 'Transfer',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İşlemler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final wallets = ref.read(walletsProvider).valueOrNull ?? [];
          final categories = ref.read(categoriesProvider).valueOrNull ?? [];
          _showSheet(context, ref, wallets: wallets, categories: categories);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('İşlem Ekle'),
      ),
      bottomNavigationBar: const DashboardNavBar(selectedIndex: 1),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('İşlemler yüklenemedi')),
        data: (transactions) => categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Kategoriler yüklenemedi')),
          data: (categories) => walletsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Cüzdanlar yüklenemedi')),
            data: (wallets) {
              final categoryMap = {for (final c in categories) c.id: c};
              final walletMap = {for (final w in wallets) w.id: w};

              final filteredItems = _filterType == 'all'
                  ? transactions
                  : transactions.where((tx) => tx.type == _filterType).toList();

              final grouped = _buildGrouped(filteredItems);

              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Hepsi'),
                          selected: _filterType == 'all',
                          onSelected: (_) => setState(() => _filterType = 'all'),
                        ),
                        ChoiceChip(
                          label: const Text('Gelir'),
                          selected: _filterType == 'income',
                          onSelected: (_) => setState(() => _filterType = 'income'),
                        ),
                        ChoiceChip(
                          label: const Text('Gider'),
                          selected: _filterType == 'expense',
                          onSelected: (_) => setState(() => _filterType = 'expense'),
                        ),
                        ChoiceChip(
                          label: const Text('Transfer'),
                          selected: _filterType == 'transfer',
                          onSelected: (_) => setState(() => _filterType = 'transfer'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: grouped.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: EmptyStateCard(
                              title: 'Henüz işlem yok',
                              description:
                                  'İlk gelir veya gider kaydını ekleyerek takibe başlayabilirsin.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: grouped.length,
                            itemBuilder: (_, index) {
                              final item = grouped[index];
                              if (item is String) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                                  child: Text(
                                    item,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildTile(
                                    context, ref, item as Transaction, categoryMap, walletMap),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TransactionSheet extends StatefulWidget {
  const _TransactionSheet({
    required this.ref,
    required this.wallets,
    required this.categories,
    this.transaction,
  });

  final WidgetRef ref;
  final List<Wallet> wallets;
  final List<Category> categories;
  final Transaction? transaction;

  @override
  State<_TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends State<_TransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String? _walletId;
  String? _categoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _walletId = transaction.walletId;
      _categoryId = transaction.categoryId;
      _amountController.text = MoneyFormatter.formatMinorForInput(transaction.amountMinor);
      _noteController.text = transaction.note ?? '';
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(transaction.dateEpochSeconds * 1000);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('tr'),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _scanReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera ile tara'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden seç'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final result = await OcrService().scanReceipt(source: source);
    if (!mounted || result == null) return;

    if (result.amountMinor != null && result.amountMinor! > 0) {
      _amountController.text = MoneyFormatter.formatMinorForInput(result.amountMinor!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fişten tutar algılandı. Kontrol edip kaydedebilirsin.')),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fişten tutar algılanamadı. Tutarı manuel girebilirsin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wallets.isEmpty || widget.categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('İşlem eklemek için önce en az bir cüzdan ve kategori oluşturmalısın.'),
          ],
        ),
      );
    }

    _walletId ??= widget.wallets.first.id;
    _categoryId ??= widget.categories.first.id;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.transaction == null ? 'Yeni İşlem' : 'İşlemi Düzenle',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      items: const [
                        DropdownMenuItem(value: 'income', child: Text('Gelir')),
                        DropdownMenuItem(value: 'expense', child: Text('Gider')),
                        DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                      ],
                      onChanged: (value) => setState(() => _type = value ?? 'expense'),
                      decoration: const InputDecoration(labelText: 'Tür'),
                    ),
                  ),
                  if (widget.transaction == null) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _scanReceipt,
                      icon: const Icon(Icons.receipt_long_rounded),
                      tooltip: 'Fiş Oku',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tutar (₺)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Tutar boş olamaz';
                  final parsed = MoneyFormatter.parseTryToMinor(value);
                  if (parsed == null || parsed <= 0) return 'Geçerli bir tutar gir';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _walletId,
                items: widget.wallets
                    .map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${w.currency})')))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _walletId = value),
                decoration: const InputDecoration(labelText: 'Cüzdan'),
                validator: (value) => value == null ? 'Cüzdan seçimi zorunlu' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _categoryId = value),
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value == null ? 'Kategori seçimi zorunlu' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tarih'),
                subtitle: Text(DateFormatter.short(_selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Not'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final amountMinor = MoneyFormatter.parseTryToMinor(_amountController.text);
                          if (amountMinor == null) return;
                          setState(() => _isSaving = true);
                          final draft = TransactionDraft(
                            type: _type,
                            amountMinor: amountMinor,
                            walletId: _walletId!,
                            categoryId: _categoryId!,
                            date: _selectedDate,
                            note: _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim(),
                          );
                          final actions = widget.ref.read(transactionActionsProvider);
                          if (widget.transaction == null) {
                            await actions.create(draft);
                          } else {
                            await actions.update(widget.transaction!, draft);
                          }
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                  child: const Text('Kaydet'),
                ),
              ),
              if (widget.transaction != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('İşlemi Sil'),
                          content: const Text(
                              'Bu işlem silinecek ve cüzdan bakiyesi geri alınacak.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Vazgeç')),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                      if (!confirmed || !context.mounted) return;
                      await widget.ref
                          .read(transactionActionsProvider)
                          .delete(widget.transaction!);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: const Text('İşlemi Sil'),
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
