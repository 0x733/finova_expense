import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/database/database_providers.dart';
import '../../core/security/security_service.dart';
import '../../core/services/export_import_service.dart';
import '../../core/services/notification_service.dart';
import '../dashboard/dashboard_nav_bar.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final onboardingBiometric = ref.watch(onboardingBiometricProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      bottomNavigationBar: const DashboardNavBar(selectedIndex: 4),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(mode.name),
            onTap: () async {
              ref.read(themeModeProvider.notifier).state =
                  mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              await persistSettings(ref);
            },
          ),
          ListTile(
            title: const Text('Para birimi'),
            subtitle: Text(currency),
          ),
          ListTile(
            title: const Text('JSON dışa aktarma'),
            onTap: () async {
              final db = ref.read(appDatabaseProvider);
              final service = ExportImportService(db);
              final json = await service.exportJson();
              await service.shareExport(json, 'json');
            },
          ),
          ListTile(
            title: const Text('CSV dışa aktarma'),
            onTap: () async {
              final db = ref.read(appDatabaseProvider);
              final service = ExportImportService(db);
              final csv = await service.exportCsv();
              await service.shareExport(csv, 'csv');
            },
          ),
          ListTile(
            title: const Text('JSON içe aktarma'),
            onTap: () async {
              final db = ref.read(appDatabaseProvider);
              final service = ExportImportService(db);
              final result = await service.importJsonFromPicker();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
            },
          ),
          SwitchListTile(
            title: const Text('Biometric koruma'),
            value: onboardingBiometric,
            onChanged: (value) async {
              ref.read(onboardingBiometricProvider.notifier).state = value;
              final security = SecurityService(const FlutterSecureStorage(), LocalAuthentication());
              await security.setBiometricEnabled(value);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Biometric koruma açıldı' : 'Biometric koruma kapatıldı')),
              );
            },
          ),
          ListTile(
            title: const Text('Biometric doğrulama'),
            subtitle: const Text('Kimlik doğrulamayı şimdi dene'),
            onTap: () async {
              final security = SecurityService(const FlutterSecureStorage(), LocalAuthentication());
              final ok = await security.authenticate();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Doğrulandı' : 'Doğrulama başarısız')));
            },
          ),
          ListTile(
            title: const Text('Bildirim gönder'),
            onTap: () {
              NotificationService.instance.showSimple(id: 88, title: 'Finova', body: 'Yaklaşan ödeme hatırlatıcısı');
            },
          ),
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('Tasarruf Hedefleri'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/savings'),
          ),
          ListTile(
            title: const Text('Gizlilik politikası'),
            subtitle: const Text('Yer tutucu'),
          ),
        ],
      ),
    );
  }
}
