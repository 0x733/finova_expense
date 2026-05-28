import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

class BudgetWithProgress {
  const BudgetWithProgress({
    required this.budget,
    required this.spentMinor,
  });

  final Budget budget;
  final int spentMinor;

  double get progress =>
      budget.amountMinor == 0 ? 0 : (spentMinor / budget.amountMinor).clamp(0.0, 1.0);
  int get remainingMinor => budget.amountMinor - spentMinor;
  bool get isOverBudget => spentMinor > budget.amountMinor;
}

final budgetsProvider = StreamProvider.autoDispose<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

final budgetsWithProgressProvider =
    FutureProvider.autoDispose<List<BudgetWithProgress>>((ref) async {
  final budgets = await ref.watch(budgetRepositoryProvider).watchAll().first;
  final txRepo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  return Future.wait(
    budgets.map((b) async {
      final int spent;
      if (b.categoryId != null) {
        spent = await txRepo.totalByTypeAndCategory(
            'expense', b.categoryId!, startOfMonth, now);
      } else {
        spent = await txRepo.totalByType('expense', startOfMonth, now);
      }
      return BudgetWithProgress(budget: b, spentMinor: spent);
    }),
  );
});

final budgetActionsProvider =
    Provider<BudgetActions>((ref) => BudgetActions(ref));

class BudgetActions {
  const BudgetActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String name,
    required int amountMinor,
    required String period,
    String? categoryId,
  }) async {
    await _ref.read(budgetRepositoryProvider).add(
      BudgetsCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        amountMinor: amountMinor,
        period: period,
        categoryId: Value(categoryId),
      ),
    );
  }

  Future<void> softDelete(String id) =>
      _ref.read(budgetRepositoryProvider).softDelete(id);
}
