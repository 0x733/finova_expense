import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final walletsProvider = StreamProvider.autoDispose<List<Wallet>>((ref) {
  return ref.watch(walletRepositoryProvider).watchAll();
});

final archivedWalletsProvider = StreamProvider.autoDispose<List<Wallet>>((ref) {
  return ref.watch(walletRepositoryProvider).watchArchived();
});

final walletActionsProvider = Provider<WalletActions>((ref) => WalletActions(ref));

class WalletActions {
  const WalletActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String name,
    required String type,
    required String currency,
    required int color,
    required String icon,
    int initialBalanceMinor = 0,
  }) async {
    await _ref.read(walletRepositoryProvider).add(
      WalletsCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        type: type,
        currency: currency,
        color: color,
        icon: icon,
        initialBalanceMinor: Value(initialBalanceMinor),
        currentBalanceMinor: Value(initialBalanceMinor),
      ),
    );
  }

  Future<void> update({
    required String id,
    required String name,
    required String type,
    required String currency,
    required int color,
    required String icon,
  }) async {
    await _ref.read(walletRepositoryProvider).updateById(
      id,
      WalletsCompanion(
        name: Value(name),
        type: Value(type),
        currency: Value(currency),
        color: Value(color),
        icon: Value(icon),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      ),
    );
  }

  Future<void> archive(String id) =>
      _ref.read(walletRepositoryProvider).archive(id);

  Future<void> unarchive(String id) =>
      _ref.read(walletRepositoryProvider).unarchive(id);

  Future<void> setBalance(String id, int newMinor) =>
      _ref.read(walletRepositoryProvider).setBalance(id, newMinor);

  Future<void> softDelete(String id) =>
      _ref.read(walletRepositoryProvider).softDelete(id);
}
