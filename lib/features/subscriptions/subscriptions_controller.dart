import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repository_providers.dart';

final subscriptionsProvider = StreamProvider.autoDispose<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchAll();
});

final subscriptionActionsProvider =
    Provider<SubscriptionActions>((ref) => SubscriptionActions(ref));

class SubscriptionActions {
  const SubscriptionActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String name,
    required int amountMinor,
    required DateTime renewalDate,
    required String period,
    required String categoryId,
    bool reminder = true,
  }) async {
    await _ref.read(subscriptionRepositoryProvider).add(
      SubscriptionsCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        amountMinor: amountMinor,
        renewalEpochSeconds: renewalDate.millisecondsSinceEpoch ~/ 1000,
        period: period,
        categoryId: categoryId,
        reminder: Value(reminder),
      ),
    );
  }

  Future<void> softDelete(String id) =>
      _ref.read(subscriptionRepositoryProvider).softDelete(id);
}
