import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:finova_expense/core/database/app_database.dart';
import 'package:finova_expense/core/services/finance_math_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinanceMathService unit tests', () {
    const service = FinanceMathService();

    test('Bütçe hesaplama', () {
      final value = service.monthlyBudgetUsagePercent(spentMinor: 65000, budgetMinor: 100000);
      expect(value, 65);
    });

    test('Gelir-gider toplamı', () {
      final value = service.netSavings(incomeMinor: 200000, expenseMinor: 80000);
      expect(value, 120000);
    });

    test('Tasarruf oranı', () {
      final value = service.savingsRatePercent(incomeMinor: 300000, expenseMinor: 120000);
      expect(value, 60);
    });

    test('Abonelik yıllık maliyet', () {
      final value = service.subscriptionYearlyCost(monthlyCostMinor: 15000);
      expect(value, 180000);
    });

    test('Borç kalan tutar', () {
      final value = service.debtRemaining(totalMinor: 50000, paidMinor: 18000);
      expect(value, 32000);
    });
  });

  group('Repository tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Transaction ekleme/silme/güncelleme', () async {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: 'cat1',
              name: 'Yemek',
              type: 'expense',
              color: 0xFF1D4ED8,
              icon: 'restaurant',
            ),
          );
      await db.into(db.wallets).insert(
            WalletsCompanion.insert(
              id: 'wallet1',
              name: 'Nakit',
              type: 'cash',
              currency: 'TRY',
              color: 0xFF10B981,
              icon: 'wallet',
            ),
          );
      await db.into(db.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx1',
              type: 'expense',
              amountMinor: 1000,
              dateEpochSeconds: 1710000000,
              walletId: 'wallet1',
              categoryId: 'cat1',
            ),
          );
      final inserted = await db.select(db.transactions).get();
      expect(inserted.length, 1);

      await (db.update(db.transactions)..where((t) => t.id.equals('tx1'))).write(
        const TransactionsCompanion(amountMinor: Value(2000)),
      );
      final updated = await (db.select(db.transactions)..where((t) => t.id.equals('tx1'))).getSingle();
      expect(updated.amountMinor, 2000);

      await (db.update(db.transactions)..where((t) => t.id.equals('tx1'))).write(
        TransactionsCompanion(deletedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000)),
      );
      final deleted = await (db.select(db.transactions)..where((t) => t.id.equals('tx1'))).getSingle();
      expect(deleted.deletedAt != null, true);
    });

    test('Kategori filtreleme', () async {
      await db.batch((batch) {
        batch.insertAll(db.categories, [
          CategoriesCompanion.insert(id: 'c1', name: 'Maaş', type: 'income', color: 1, icon: 'salary'),
          CategoriesCompanion.insert(id: 'c2', name: 'Market', type: 'expense', color: 2, icon: 'market'),
        ]);
      });
      final expenses = await (db.select(db.categories)..where((c) => c.type.equals('expense'))).get();
      expect(expenses.any((item) => item.name == 'Market'), true);
    });
  });
}
