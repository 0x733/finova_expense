import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final transactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amountMinor,
    required this.walletId,
    required this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.isFavorite = false,
  });

  final String type;
  final int amountMinor;
  final String walletId;
  final String categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final bool isFavorite;
}

final transactionActionsProvider = Provider<TransactionActions>((ref) {
  return TransactionActions(ref);
});

class TransactionActions {
  TransactionActions(this._ref);

  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> create(TransactionDraft draft) async {
    final repo = _ref.read(transactionRepositoryProvider);
    final walletRepo = _ref.read(walletRepositoryProvider);
    await repo.add(
      TransactionsCompanion.insert(
        id: _uuid.v4(),
        type: draft.type,
        amountMinor: draft.amountMinor,
        dateEpochSeconds: draft.date.millisecondsSinceEpoch ~/ 1000,
        walletId: draft.walletId,
        categoryId: draft.categoryId,
        note: Value(draft.note),
        isRecurring: Value(draft.isRecurring),
        isFavorite: Value(draft.isFavorite),
      ),
    );
    if (draft.type != 'transfer') {
      final delta = draft.type == 'income' ? draft.amountMinor : -draft.amountMinor;
      await walletRepo.adjustBalance(draft.walletId, delta);
    }
  }

  Future<void> update(Transaction original, TransactionDraft draft) async {
    final repo = _ref.read(transactionRepositoryProvider);
    final walletRepo = _ref.read(walletRepositoryProvider);
    if (original.type != 'transfer') {
      final reverseDelta = original.type == 'income' ? -original.amountMinor : original.amountMinor;
      await walletRepo.adjustBalance(original.walletId, reverseDelta);
    }
    await repo.updateById(
      original.id,
      TransactionsCompanion(
        type: Value(draft.type),
        amountMinor: Value(draft.amountMinor),
        dateEpochSeconds: Value(draft.date.millisecondsSinceEpoch ~/ 1000),
        walletId: Value(draft.walletId),
        categoryId: Value(draft.categoryId),
        note: Value(draft.note),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
    if (draft.type != 'transfer') {
      final newDelta = draft.type == 'income' ? draft.amountMinor : -draft.amountMinor;
      await walletRepo.adjustBalance(draft.walletId, newDelta);
    }
  }

  Future<void> delete(Transaction tx) async {
    if (tx.type != 'transfer') {
      final reverseDelta = tx.type == 'income' ? -tx.amountMinor : tx.amountMinor;
      await _ref.read(walletRepositoryProvider).adjustBalance(tx.walletId, reverseDelta);
    }
    await _ref.read(transactionRepositoryProvider).softDelete(tx.id);
  }

  Future<void> softDelete(String id) => _ref.read(transactionRepositoryProvider).softDelete(id);
}
