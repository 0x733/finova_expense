import 'package:drift/drift.dart';

import '../app_database.dart';

class TransactionRepository {
  const TransactionRepository(this._db);

  final AppDatabase _db;

  Future<List<Transaction>> list({int limit = 50, int offset = 0}) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.dateEpochSeconds)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Stream<List<Transaction>> watchLatest({int limit = 20}) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.dateEpochSeconds)])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<Transaction>> watchAll() {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.dateEpochSeconds)]);
    return query.watch();
  }

  Future<void> add(TransactionsCompanion companion) => _db.into(_db.transactions).insert(companion);

  Future<int> updateById(String id, TransactionsCompanion companion) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(companion);
  }

  Future<int> softDelete(String id) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> totalByType(String type, DateTime from, DateTime to) async {
    final fromEpoch = from.millisecondsSinceEpoch ~/ 1000;
    final toEpoch = to.millisecondsSinceEpoch ~/ 1000;
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amountMinor.sum()])
      ..where(_db.transactions.type.equals(type) & _db.transactions.dateEpochSeconds.isBetweenValues(fromEpoch, toEpoch) & _db.transactions.deletedAt.isNull());
    final row = await query.getSingle();
    return row.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Future<int> totalByTypeAndCategory(String type, String categoryId, DateTime from, DateTime to) async {
    final fromEpoch = from.millisecondsSinceEpoch ~/ 1000;
    final toEpoch = to.millisecondsSinceEpoch ~/ 1000;
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amountMinor.sum()])
      ..where(_db.transactions.type.equals(type) &
          _db.transactions.categoryId.equals(categoryId) &
          _db.transactions.dateEpochSeconds.isBetweenValues(fromEpoch, toEpoch) &
          _db.transactions.deletedAt.isNull());
    final row = await query.getSingle();
    return row.read(_db.transactions.amountMinor.sum()) ?? 0;
  }

  Stream<List<Transaction>> watchFiltered({
    String? type,
    String? walletId,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    int? minAmountMinor,
    int? maxAmountMinor,
    int limit = 100,
    int offset = 0,
  }) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull());
    if (type != null) query.where((t) => t.type.equals(type));
    if (walletId != null) query.where((t) => t.walletId.equals(walletId));
    if (categoryId != null) query.where((t) => t.categoryId.equals(categoryId));
    if (from != null) {
      query.where((t) => t.dateEpochSeconds.isBiggerOrEqualValue(from.millisecondsSinceEpoch ~/ 1000));
    }
    if (to != null) {
      query.where((t) => t.dateEpochSeconds.isSmallerOrEqualValue(to.millisecondsSinceEpoch ~/ 1000));
    }
    if (minAmountMinor != null) {
      query.where((t) => t.amountMinor.isBiggerOrEqualValue(minAmountMinor));
    }
    if (maxAmountMinor != null) {
      query.where((t) => t.amountMinor.isSmallerOrEqualValue(maxAmountMinor));
    }
    query
      ..orderBy([(t) => OrderingTerm.desc(t.dateEpochSeconds)])
      ..limit(limit, offset: offset);
    return query.watch();
  }
}
