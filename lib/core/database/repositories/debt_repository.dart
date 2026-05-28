import 'package:drift/drift.dart';

import '../app_database.dart';

class DebtRepository {
  const DebtRepository(this._db);

  final AppDatabase _db;

  Stream<List<Debt>> watchAll() {
    final query = _db.select(_db.debts)
      ..where((d) => d.deletedAt.isNull())
      ..orderBy([(d) => OrderingTerm.asc(d.dueEpochSeconds)]);
    return query.watch();
  }

  Future<void> add(DebtsCompanion data) => _db.into(_db.debts).insert(data);

  Future<int> updatePaid(String id, int paidMinor) {
    return (_db.update(_db.debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(
        paidMinor: Value(paidMinor),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> softDelete(String id) {
    return (_db.update(_db.debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
}
