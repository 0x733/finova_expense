import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'common_columns.dart';

part 'app_database.g.dart';

class Categories extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => text()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  IntColumn get monthlyLimitMinor => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Wallets extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get currency => text()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  IntColumn get initialBalanceMinor => integer().withDefault(const Constant(0))();
  IntColumn get currentBalanceMinor => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  IntColumn get dateEpochSeconds => integer()();
  TextColumn get walletId => text().customConstraint('NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT')();
  TextColumn get categoryId => text().customConstraint('NOT NULL REFERENCES categories(id) ON DELETE RESTRICT')();
  TextColumn get note => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

}

class Budgets extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get period => text()();
  TextColumn get categoryId => text().nullable().customConstraint('NULL REFERENCES categories(id) ON DELETE SET NULL')();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurringTransactions extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get transactionId => text().customConstraint('NOT NULL REFERENCES transactions(id) ON DELETE CASCADE')();
  TextColumn get frequency => text()();
  IntColumn get nextRunEpochSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Subscriptions extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountMinor => integer()();
  IntColumn get renewalEpochSeconds => integer()();
  TextColumn get period => text()();
  TextColumn get categoryId => text().customConstraint('NOT NULL REFERENCES categories(id) ON DELETE RESTRICT')();
  BoolColumn get reminder => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Debts extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get personName => text()();
  IntColumn get amountMinor => integer()();
  IntColumn get paidMinor => integer().withDefault(const Constant(0))();
  IntColumn get dueEpochSeconds => integer()();
  BoolColumn get isReceivable => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsGoals extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetMinor => integer()();
  IntColumn get currentMinor => integer().withDefault(const Constant(0))();
  IntColumn get targetEpochSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get currency => text().withDefault(const Constant('TRY'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFF64748B))();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionTags extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().customConstraint('NOT NULL REFERENCES transactions(id) ON DELETE CASCADE')();
  TextColumn get tagId => text().customConstraint('NOT NULL REFERENCES tags(id) ON DELETE CASCADE')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {transactionId, tagId},
      ];
}

@DriftDatabase(
  tables: [
    Transactions,
    Categories,
    Wallets,
    Budgets,
    RecurringTransactions,
    Subscriptions,
    Debts,
    SavingsGoals,
    AppSettings,
    Tags,
    TransactionTags,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.isFavorite);
          }
        },
      );

  Future<void> _seedInitialData() async {
    await batch((batch) {
      batch.insert(appSettings, AppSettingsCompanion.insert(id: 'default-settings'));
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'finova_expense.sqlite',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}

Future<File> appDatabaseFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/finova_expense.sqlite');
}
