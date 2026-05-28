import 'package:drift/drift.dart';

import '../app_database.dart';

class SavingsRepository {
  const SavingsRepository(this._db);

  final AppDatabase _db;

  Stream<List<SavingsGoal>> watchAll() {
    final query = _db.select(_db.savingsGoals)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.asc(s.targetEpochSeconds)]);
    return query.watch();
  }

  Future<void> add(SavingsGoalsCompanion data) =>
      _db.into(_db.savingsGoals).insert(data);

  Future<int> updateCurrent(String id, int currentMinor) {
    return (_db.update(_db.savingsGoals)..where((s) => s.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentMinor: Value(currentMinor),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> softDelete(String id) {
    return (_db.update(_db.savingsGoals)..where((s) => s.id.equals(id))).write(
      SavingsGoalsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
}
