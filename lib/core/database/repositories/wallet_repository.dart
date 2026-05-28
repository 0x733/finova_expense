import 'package:drift/drift.dart';

import '../app_database.dart';

class WalletRepository {
  const WalletRepository(this._db);

  final AppDatabase _db;

  Stream<List<Wallet>> watchAll() {
    final query = _db.select(_db.wallets)
      ..where((w) => w.isArchived.equals(false) & w.deletedAt.isNull())
      ..orderBy([(w) => OrderingTerm.asc(w.name)]);
    return query.watch();
  }

  Stream<List<Wallet>> watchArchived() {
    final query = _db.select(_db.wallets)
      ..where((w) => w.isArchived.equals(true) & w.deletedAt.isNull())
      ..orderBy([(w) => OrderingTerm.asc(w.name)]);
    return query.watch();
  }

  Future<void> add(WalletsCompanion data) => _db.into(_db.wallets).insert(data);

  Future<int> updateById(String id, WalletsCompanion data) {
    return (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(data);
  }

  Future<int> softDelete(String id) {
    return (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> archive(String id) {
    return (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> unarchive(String id) {
    return (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        isArchived: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> setBalance(String id, int newMinor) {
    return (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        currentBalanceMinor: Value(newMinor),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<int> adjustBalance(String id, int deltaMinor) {
    return _db.customUpdate(
      'UPDATE wallets SET current_balance_minor = current_balance_minor + ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt(deltaMinor),
        Variable.withInt(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        Variable.withString(id),
      ],
      updates: {_db.wallets},
    );
  }
}
