import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final categoriesProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final categoryActionsProvider = Provider<CategoryActions>((ref) => CategoryActions(ref));

class CategoryActions {
  const CategoryActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String name,
    required String type,
    required int color,
    required String icon,
    int? monthlyLimitMinor,
  }) async {
    await _ref.read(categoryRepositoryProvider).add(
      CategoriesCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        type: type,
        color: color,
        icon: icon,
        monthlyLimitMinor: Value(monthlyLimitMinor),
      ),
    );
  }

  Future<void> update({
    required String id,
    required String name,
    required String type,
    required int color,
    required String icon,
    int? monthlyLimitMinor,
  }) async {
    await _ref.read(categoryRepositoryProvider).updateById(
      id,
      CategoriesCompanion(
        name: Value(name),
        type: Value(type),
        color: Value(color),
        icon: Value(icon),
        monthlyLimitMinor: Value(monthlyLimitMinor),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<void> softDelete(String id) =>
      _ref.read(categoryRepositoryProvider).softDelete(id);
}
