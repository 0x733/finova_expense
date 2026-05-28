import 'package:drift/drift.dart';

import '../app_database.dart';

class SubscriptionRepository {
  const SubscriptionRepository(this._db);

  final AppDatabase _db;

  Stream<List<Subscription>> watchAll() {
    final query = _db.select(_db.subscriptions)
      ..where((s) => s.deletedAt.isNull());
    return query.watch();
  }

  Future<void> add(SubscriptionsCompanion data) =>
      _db.into(_db.subscriptions).insert(data);

  Future<int> softDelete(String id) {
    return (_db.update(_db.subscriptions)..where((s) => s.id.equals(id))).write(
      SubscriptionsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
}
