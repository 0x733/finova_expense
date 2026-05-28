import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
final selectedCurrencyProvider = StateProvider<String>((_) => 'TRY');
final onboardingBiometricProvider = StateProvider<bool>((_) => false);

final settingsInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final settings = await (db.select(db.appSettings)
        ..where((s) => s.id.equals('default-settings')))
      .getSingleOrNull();
  if (settings == null) return;
  final mode = switch (settings.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  ref.read(themeModeProvider.notifier).state = mode;
  ref.read(selectedCurrencyProvider.notifier).state = settings.currency;
});

Future<void> persistSettings(WidgetRef ref) async {
  final db = ref.read(appDatabaseProvider);
  final mode = ref.read(themeModeProvider);
  final currency = ref.read(selectedCurrencyProvider);
  final modeStr = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    _ => 'system',
  };
  await (db.update(db.appSettings)..where((s) => s.id.equals('default-settings'))).write(
    AppSettingsCompanion(
      themeMode: Value(modeStr),
      currency: Value(currency),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  );
}

Future<void> markOnboardingComplete(WidgetRef ref) async {
  final db = ref.read(appDatabaseProvider);
  await (db.update(db.appSettings)..where((s) => s.id.equals('default-settings'))).write(
    AppSettingsCompanion(
      onboardingCompleted: const Value(true),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  );
}
