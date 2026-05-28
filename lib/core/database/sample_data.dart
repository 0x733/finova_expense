import 'package:drift/drift.dart';

import 'app_database.dart';

Future<void> seedSampleData(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(
      db.categories,
      [
        CategoriesCompanion.insert(id: 'cat-market',    name: 'Market',          type: 'expense', color: 0xFF10B981, icon: 'shopping_cart',        sortOrder: const Value(1)),
        CategoriesCompanion.insert(id: 'cat-yemek',     name: 'Yemek',           type: 'expense', color: 0xFFF59E0B, icon: 'restaurant',           sortOrder: const Value(2)),
        CategoriesCompanion.insert(id: 'cat-kahve',     name: 'Kahve & Kafe',    type: 'expense', color: 0xFFF97316, icon: 'coffee',               sortOrder: const Value(3)),
        CategoriesCompanion.insert(id: 'cat-ulasim',    name: 'Ulaşım',          type: 'expense', color: 0xFF6366F1, icon: 'directions_bus',        sortOrder: const Value(4)),
        CategoriesCompanion.insert(id: 'cat-yakit',     name: 'Yakıt',           type: 'expense', color: 0xFF64748B, icon: 'local_gas_station',     sortOrder: const Value(5)),
        CategoriesCompanion.insert(id: 'cat-arac',      name: 'Araç Bakımı',     type: 'expense', color: 0xFF8B5CF6, icon: 'directions_car',        sortOrder: const Value(6)),
        CategoriesCompanion.insert(id: 'cat-kira',      name: 'Kira',            type: 'expense', color: 0xFF1D4ED8, icon: 'home',                  sortOrder: const Value(7)),
        CategoriesCompanion.insert(id: 'cat-elektrik',  name: 'Elektrik',        type: 'expense', color: 0xFFF59E0B, icon: 'bolt',                  sortOrder: const Value(8)),
        CategoriesCompanion.insert(id: 'cat-su',        name: 'Su',              type: 'expense', color: 0xFF06B6D4, icon: 'water_drop',            sortOrder: const Value(9)),
        CategoriesCompanion.insert(id: 'cat-internet',  name: 'İnternet',        type: 'expense', color: 0xFF8B5CF6, icon: 'wifi',                  sortOrder: const Value(10)),
        CategoriesCompanion.insert(id: 'cat-telefon',   name: 'Telefon',         type: 'expense', color: 0xFF64748B, icon: 'phone_android',         sortOrder: const Value(11)),
        CategoriesCompanion.insert(id: 'cat-fatura',    name: 'Faturalar',       type: 'expense', color: 0xFF64748B, icon: 'receipt',               sortOrder: const Value(12)),
        CategoriesCompanion.insert(id: 'cat-eglence',   name: 'Eğlence',         type: 'expense', color: 0xFFEC4899, icon: 'celebration',           sortOrder: const Value(13)),
        CategoriesCompanion.insert(id: 'cat-sinema',    name: 'Sinema & Dizi',   type: 'expense', color: 0xFFEC4899, icon: 'movie',                 sortOrder: const Value(14)),
        CategoriesCompanion.insert(id: 'cat-muzik',     name: 'Müzik & Yayın',   type: 'expense', color: 0xFF8B5CF6, icon: 'music_note',            sortOrder: const Value(15)),
        CategoriesCompanion.insert(id: 'cat-saglik',    name: 'Sağlık',          type: 'expense', color: 0xFFEF4444, icon: 'local_hospital',        sortOrder: const Value(16)),
        CategoriesCompanion.insert(id: 'cat-spor',      name: 'Spor & Fitness',  type: 'expense', color: 0xFF10B981, icon: 'fitness_center',        sortOrder: const Value(17)),
        CategoriesCompanion.insert(id: 'cat-alisveris', name: 'Alışveriş',       type: 'expense', color: 0xFFF97316, icon: 'shopping_bag',          sortOrder: const Value(18)),
        CategoriesCompanion.insert(id: 'cat-teknoloji', name: 'Teknoloji',       type: 'expense', color: 0xFF6366F1, icon: 'laptop',                sortOrder: const Value(19)),
        CategoriesCompanion.insert(id: 'cat-egitim',    name: 'Eğitim',          type: 'expense', color: 0xFF059669, icon: 'school',                sortOrder: const Value(20)),
        CategoriesCompanion.insert(id: 'cat-seyahat',   name: 'Seyahat',         type: 'expense', color: 0xFF1D4ED8, icon: 'flight',                sortOrder: const Value(21)),
        CategoriesCompanion.insert(id: 'cat-evcil',     name: 'Evcil Hayvan',    type: 'expense', color: 0xFFF59E0B, icon: 'pets',                  sortOrder: const Value(22)),
        CategoriesCompanion.insert(id: 'cat-cocuk',     name: 'Çocuk & Bebek',   type: 'expense', color: 0xFFEC4899, icon: 'child_care',            sortOrder: const Value(23)),
        CategoriesCompanion.insert(id: 'cat-park',      name: 'Park & Doğa',     type: 'expense', color: 0xFF10B981, icon: 'park',                  sortOrder: const Value(24)),
        CategoriesCompanion.insert(id: 'cat-maas',      name: 'Maaş',            type: 'income',  color: 0xFF1D4ED8, icon: 'account_balance_wallet', sortOrder: const Value(25)),
        CategoriesCompanion.insert(id: 'cat-yatirim',   name: 'Yatırım Getirisi',type: 'income',  color: 0xFF059669, icon: 'trending_up',           sortOrder: const Value(26)),
        CategoriesCompanion.insert(id: 'cat-serbest',   name: 'Serbest Çalışma', type: 'income',  color: 0xFF8B5CF6, icon: 'work',                  sortOrder: const Value(27)),
        CategoriesCompanion.insert(id: 'cat-kira-gel',  name: 'Kira Geliri',     type: 'income',  color: 0xFF6366F1, icon: 'home',                  sortOrder: const Value(28)),
        CategoriesCompanion.insert(id: 'cat-prim',      name: 'Prim & İkramiye', type: 'income',  color: 0xFFF59E0B, icon: 'attach_money',          sortOrder: const Value(29)),
      ],
      mode: InsertMode.insertOrIgnore,
    );
    batch.insert(
      db.wallets,
      WalletsCompanion.insert(
        id: 'wallet-nakit',
        name: 'Nakit',
        type: 'cash',
        currency: 'TRY',
        color: 0xFF10B981,
        icon: 'payments',
        initialBalanceMinor: const Value(50000),
        currentBalanceMinor: const Value(50000),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    batch.insert(
      db.wallets,
      WalletsCompanion.insert(
        id: 'wallet-banka',
        name: 'Banka Hesabı',
        type: 'bank',
        currency: 'TRY',
        color: 0xFF1D4ED8,
        icon: 'account_balance',
        initialBalanceMinor: const Value(1500000),
        currentBalanceMinor: const Value(1500000),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  });

  final now = DateTime.now();

  final txs = [
    TransactionsCompanion.insert(id: 'tx-s-01', type: 'income',  amountMinor: 1500000, dateEpochSeconds: DateTime(now.year, now.month,     1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-maas',     note: const Value('Aylık maaş')),
    TransactionsCompanion.insert(id: 'tx-s-02', type: 'expense', amountMinor:   45000, dateEpochSeconds: DateTime(now.year, now.month,     3).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-market',   note: const Value('Haftalık market')),
    TransactionsCompanion.insert(id: 'tx-s-03', type: 'expense', amountMinor:   12000, dateEpochSeconds: DateTime(now.year, now.month,     5).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-yemek',    note: const Value('Öğle yemeği')),
    TransactionsCompanion.insert(id: 'tx-s-04', type: 'expense', amountMinor:    8500, dateEpochSeconds: DateTime(now.year, now.month,     7).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-ulasim'),
    TransactionsCompanion.insert(id: 'tx-s-05', type: 'expense', amountMinor:   25000, dateEpochSeconds: DateTime(now.year, now.month,    10).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-fatura',   note: const Value('Elektrik ve su')),
    TransactionsCompanion.insert(id: 'tx-s-06', type: 'expense', amountMinor:  600000, dateEpochSeconds: DateTime(now.year, now.month,     1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-kira',     note: const Value('Aylık kira')),
    TransactionsCompanion.insert(id: 'tx-s-07', type: 'expense', amountMinor:   35000, dateEpochSeconds: DateTime(now.year, now.month,     4).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-elektrik', note: const Value('Elektrik faturası')),
    TransactionsCompanion.insert(id: 'tx-s-08', type: 'expense', amountMinor:   12000, dateEpochSeconds: DateTime(now.year, now.month,     4).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-su',       note: const Value('Su faturası')),
    TransactionsCompanion.insert(id: 'tx-s-09', type: 'expense', amountMinor:   40000, dateEpochSeconds: DateTime(now.year, now.month,     2).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-internet', note: const Value('İnternet faturası')),
    TransactionsCompanion.insert(id: 'tx-s-10', type: 'expense', amountMinor:   25000, dateEpochSeconds: DateTime(now.year, now.month,     2).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-telefon',  note: const Value('Telefon faturası')),
    TransactionsCompanion.insert(id: 'tx-s-11', type: 'expense', amountMinor:    8000, dateEpochSeconds: DateTime(now.year, now.month,     6).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-kahve',    note: const Value('Kahve')),
    TransactionsCompanion.insert(id: 'tx-s-12', type: 'expense', amountMinor:   45000, dateEpochSeconds: DateTime(now.year, now.month,     8).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-spor',     note: const Value('Spor salonu aylık')),
    TransactionsCompanion.insert(id: 'tx-s-13', type: 'expense', amountMinor:   15000, dateEpochSeconds: DateTime(now.year, now.month,    12).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-sinema',   note: const Value('Netflix')),
    TransactionsCompanion.insert(id: 'tx-s-14', type: 'expense', amountMinor:   70000, dateEpochSeconds: DateTime(now.year, now.month,     9).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-yakit',    note: const Value('Yakıt')),
    TransactionsCompanion.insert(id: 'tx-s-15', type: 'expense', amountMinor:   85000, dateEpochSeconds: DateTime(now.year, now.month,    11).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-alisveris',note: const Value('Kıyafet alışverişi')),

    TransactionsCompanion.insert(id: 'tx-s-16', type: 'income',  amountMinor: 1500000, dateEpochSeconds: DateTime(now.year, now.month - 1,  1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-maas',     note: const Value('Aylık maaş')),
    TransactionsCompanion.insert(id: 'tx-s-17', type: 'income',  amountMinor:  200000, dateEpochSeconds: DateTime(now.year, now.month - 1, 15).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-serbest',  note: const Value('Freelance proje')),
    TransactionsCompanion.insert(id: 'tx-s-18', type: 'expense', amountMinor:  600000, dateEpochSeconds: DateTime(now.year, now.month - 1,  1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-kira',     note: const Value('Kira')),
    TransactionsCompanion.insert(id: 'tx-s-19', type: 'expense', amountMinor:  150000, dateEpochSeconds: DateTime(now.year, now.month - 1,  5).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-market'),
    TransactionsCompanion.insert(id: 'tx-s-20', type: 'expense', amountMinor:   80000, dateEpochSeconds: DateTime(now.year, now.month - 1, 10).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-yemek'),
    TransactionsCompanion.insert(id: 'tx-s-21', type: 'expense', amountMinor:   40000, dateEpochSeconds: DateTime(now.year, now.month - 1,  4).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-elektrik'),
    TransactionsCompanion.insert(id: 'tx-s-22', type: 'expense', amountMinor:   40000, dateEpochSeconds: DateTime(now.year, now.month - 1,  2).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-internet'),
    TransactionsCompanion.insert(id: 'tx-s-23', type: 'expense', amountMinor:   25000, dateEpochSeconds: DateTime(now.year, now.month - 1,  2).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-telefon'),
    TransactionsCompanion.insert(id: 'tx-s-24', type: 'expense', amountMinor:   30000, dateEpochSeconds: DateTime(now.year, now.month - 1, 12).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-ulasim'),
    TransactionsCompanion.insert(id: 'tx-s-25', type: 'expense', amountMinor:   60000, dateEpochSeconds: DateTime(now.year, now.month - 1, 18).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-eglence',  note: const Value('Arkadaş yemeği')),
    TransactionsCompanion.insert(id: 'tx-s-26', type: 'expense', amountMinor:  200000, dateEpochSeconds: DateTime(now.year, now.month - 1, 22).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-seyahat',  note: const Value('Hafta sonu tatili')),
    TransactionsCompanion.insert(id: 'tx-s-27', type: 'expense', amountMinor:   10000, dateEpochSeconds: DateTime(now.year, now.month - 1,  8).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-kahve'),
    TransactionsCompanion.insert(id: 'tx-s-28', type: 'expense', amountMinor:   45000, dateEpochSeconds: DateTime(now.year, now.month - 1,  3).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-spor'),

    TransactionsCompanion.insert(id: 'tx-s-29', type: 'income',  amountMinor: 1500000, dateEpochSeconds: DateTime(now.year, now.month - 2,  1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-maas',     note: const Value('Aylık maaş')),
    TransactionsCompanion.insert(id: 'tx-s-30', type: 'expense', amountMinor:  600000, dateEpochSeconds: DateTime(now.year, now.month - 2,  1).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-kira'),
    TransactionsCompanion.insert(id: 'tx-s-31', type: 'expense', amountMinor:  120000, dateEpochSeconds: DateTime(now.year, now.month - 2,  6).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-market'),
    TransactionsCompanion.insert(id: 'tx-s-32', type: 'expense', amountMinor:   90000, dateEpochSeconds: DateTime(now.year, now.month - 2, 14).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-nakit', categoryId: 'cat-yemek'),
    TransactionsCompanion.insert(id: 'tx-s-33', type: 'expense', amountMinor:  150000, dateEpochSeconds: DateTime(now.year, now.month - 2, 10).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-teknoloji',note: const Value('Tablet')),
    TransactionsCompanion.insert(id: 'tx-s-34', type: 'expense', amountMinor:   30000, dateEpochSeconds: DateTime(now.year, now.month - 2,  4).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-elektrik'),
    TransactionsCompanion.insert(id: 'tx-s-35', type: 'expense', amountMinor:   10000, dateEpochSeconds: DateTime(now.year, now.month - 2,  4).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-su'),
    TransactionsCompanion.insert(id: 'tx-s-36', type: 'expense', amountMinor:   40000, dateEpochSeconds: DateTime(now.year, now.month - 2,  2).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-internet'),
    TransactionsCompanion.insert(id: 'tx-s-37', type: 'expense', amountMinor:   55000, dateEpochSeconds: DateTime(now.year, now.month - 2, 16).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-saglik',   note: const Value('Doktor randevusu')),
    TransactionsCompanion.insert(id: 'tx-s-38', type: 'expense', amountMinor:   25000, dateEpochSeconds: DateTime(now.year, now.month - 2, 20).millisecondsSinceEpoch ~/ 1000, walletId: 'wallet-banka', categoryId: 'cat-egitim',   note: const Value('Online kurs')),
  ];

  await db.batch((batch) => batch.insertAll(db.transactions, txs, mode: InsertMode.insertOrIgnore));
}
