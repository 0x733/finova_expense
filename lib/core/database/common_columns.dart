import 'package:drift/drift.dart';

int nowEpochSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

mixin TimestampColumns on Table {
  IntColumn get createdAt => integer().withDefault(Constant(nowEpochSeconds()))();
  IntColumn get updatedAt => integer().withDefault(Constant(nowEpochSeconds()))();
  IntColumn get deletedAt => integer().nullable()();
}
