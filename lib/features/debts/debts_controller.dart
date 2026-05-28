import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final debtsProvider = StreamProvider.autoDispose<List<Debt>>((ref) {
  return ref.watch(debtRepositoryProvider).watchAll();
});

final debtActionsProvider =
    Provider<DebtActions>((ref) => DebtActions(ref));

class DebtActions {
  const DebtActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String personName,
    required int amountMinor,
    required DateTime dueDate,
    required bool isReceivable,
  }) async {
    await _ref.read(debtRepositoryProvider).add(
      DebtsCompanion.insert(
        id: const Uuid().v4(),
        personName: personName,
        amountMinor: amountMinor,
        dueEpochSeconds: dueDate.millisecondsSinceEpoch ~/ 1000,
        isReceivable: isReceivable,
      ),
    );
  }

  Future<void> markPaid(String id, int totalMinor) =>
      _ref.read(debtRepositoryProvider).updatePaid(id, totalMinor);

  Future<void> updatePaid(String id, int paidMinor) =>
      _ref.read(debtRepositoryProvider).updatePaid(id, paidMinor);

  Future<void> softDelete(String id) =>
      _ref.read(debtRepositoryProvider).softDelete(id);
}
