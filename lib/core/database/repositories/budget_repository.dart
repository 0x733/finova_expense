import 'package:drift/drift.dart';

import '../app_database.dart';

class BudgetRepository {
  const BudgetRepository(this._db);

  final AppDatabase _db;

  Stream<List<Budget>> watchAll() {
    final query = _db.select(_db.budgets)
      ..where((b) => b.deletedAt.isNull())
      ..orderBy([(b) => OrderingTerm.asc(b.name)]);
    return query.watch();
  }

  Future<void> add(BudgetsCompanion data) => _db.into(_db.budgets).insert(data);

  Future<int> softDelete(String id) {
    return (_db.update(_db.budgets)..where((b) => b.id.equals(id))).write(
      BudgetsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
}
