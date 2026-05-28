import 'package:drift/drift.dart';

import '../app_database.dart';

class CategoryRepository {
  const CategoryRepository(this._db);

  final AppDatabase _db;

  Future<List<Category>> list({String? type}) {
    final query = _db.select(_db.categories)..where((c) => c.deletedAt.isNull());
    if (type != null) {
      query.where((c) => c.type.equals(type));
    }
    query.orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query.get();
  }

  Stream<List<Category>> watchAll() {
    final query = _db.select(_db.categories)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]);
    return query.watch();
  }

  Future<void> add(CategoriesCompanion data) => _db.into(_db.categories).insert(data);

  Future<int> updateById(String id, CategoriesCompanion data) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(data);
  }

  Future<int> softDelete(String id) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }
}
