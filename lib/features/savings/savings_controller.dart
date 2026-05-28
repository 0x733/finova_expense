import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final savingsGoalsProvider =
    StreamProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.watch(savingsRepositoryProvider).watchAll();
});

final savingsActionsProvider =
    Provider<SavingsActions>((ref) => SavingsActions(ref));

class SavingsActions {
  const SavingsActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String name,
    required int targetMinor,
    required DateTime targetDate,
    int currentMinor = 0,
  }) async {
    await _ref.read(savingsRepositoryProvider).add(
      SavingsGoalsCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        targetMinor: targetMinor,
        targetEpochSeconds: targetDate.millisecondsSinceEpoch ~/ 1000,
        currentMinor: Value(currentMinor),
      ),
    );
  }

  Future<void> addToGoal(String id, int addMinor, int currentMinor) {
    final newAmount = currentMinor + addMinor;
    return _ref.read(savingsRepositoryProvider).updateCurrent(id, newAmount);
  }

  Future<void> softDelete(String id) =>
      _ref.read(savingsRepositoryProvider).softDelete(id);
}
