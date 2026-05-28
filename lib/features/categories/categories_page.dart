import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/formatters/money_formatter.dart';
import '../../shared/widgets/empty_state_card.dart';
import 'categories_controller.dart';

const _kCategoryIcons = <String, IconData>{
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
};

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kategoriler')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategori Ekle'),
      ),
      body: categories.when(
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                title: 'Kategori bulunamadı',
                description: 'Market, yemek, ulaşım gibi kategoriler ekleyerek işlemlerini düzenleyebilirsin.',
                actionLabel: null,
              ),
            );
          }
          final expense = items.where((c) => c.type == 'expense').toList();
          final income = items.where((c) => c.type == 'income').toList();
          return CustomScrollView(
            slivers: [
              if (expense.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Chip(
                      avatar: Icon(
                        Icons.arrow_downward_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      label: Text(
                        'Gider',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTile(context, ref, expense[index]),
                      ),
                      childCount: expense.length,
                    ),
                  ),
                ),
              ],
              if (income.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Chip(
                      avatar: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      label: const Text(
                        'Gelir',
                        style: TextStyle(color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTile(context, ref, income[index]),
                      ),
                      childCount: income.length,
                    ),
                  ),
                ),
              ],
              if (income.isEmpty)
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
        error: (_, __) => const Center(child: Text('Kategoriler yüklenemedi')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, Category item) {
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
      onDismissed: (_) => ref.read(categoryActionsProvider).softDelete(item.id),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => _showSheet(context, ref, category: item),
        leading: CircleAvatar(
          backgroundColor: Color(item.color),
          radius: 18,
          child: Icon(
            _kCategoryIcons[item.icon] ?? Icons.label_outline_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(item.type == 'income' ? 'Gelir' : 'Gider'),
        trailing: item.monthlyLimitMinor != null
            ? Chip(
                label: Text(
                  'Limit: ${MoneyFormatter.formatMinor(minor: item.monthlyLimitMinor!, currency: 'TRY')}',
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _showSheet(BuildContext context, WidgetRef ref, {Category? category}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CategorySheet(ref: ref, category: category),
    );
  }
}

class _CategorySheet extends StatefulWidget {
  const _CategorySheet({required this.ref, this.category});

  final WidgetRef ref;
  final Category? category;

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  String _type = 'expense';
  int _selectedColor = 0xFF10B981;
  String _selectedIcon = 'shopping_cart';

  static const _colorOptions = [
    0xFF10B981, 0xFF1D4ED8, 0xFFF59E0B, 0xFFEF4444,
    0xFF8B5CF6, 0xFF06B6D4, 0xFFEC4899, 0xFF6366F1,
    0xFF64748B, 0xFFF97316,
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    if (cat != null) {
      _nameController.text = cat.name;
      _type = cat.type;
      _selectedColor = cat.color;
      _selectedIcon = cat.icon;
      if (cat.monthlyLimitMinor != null) {
        _limitController.text = MoneyFormatter.formatMinorForInput(cat.monthlyLimitMinor!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
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
              Text(
                isEdit ? 'Kategoriyi Düzenle' : 'Yeni Kategori',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Kategori adı'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad boş olamaz' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Gider')),
                  DropdownMenuItem(value: 'income', child: Text('Gelir')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'expense'),
                decoration: const InputDecoration(labelText: 'Tür'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Aylık limit (opsiyonel)',
                  suffixText: '₺',
                ),
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
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2.5)
                            : null,
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
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
                children: _kCategoryIcons.entries.map((entry) {
                  final selected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(entry.value,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface),
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final limitMinor = _limitController.text.trim().isEmpty
                        ? null
                        : MoneyFormatter.parseTryToMinor(_limitController.text.trim());
                    final actions = widget.ref.read(categoryActionsProvider);
                    if (widget.category == null) {
                      await actions.create(
                        name: _nameController.text.trim(),
                        type: _type,
                        color: _selectedColor,
                        icon: _selectedIcon,
                        monthlyLimitMinor: limitMinor,
                      );
                    } else {
                      await actions.update(
                        id: widget.category!.id,
                        name: _nameController.text.trim(),
                        type: _type,
                        color: _selectedColor,
                        icon: _selectedIcon,
                        monthlyLimitMinor: limitMinor,
                      );
                    }
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
