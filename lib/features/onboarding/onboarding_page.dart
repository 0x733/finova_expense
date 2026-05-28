import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/constants/app_constants.dart';
import '../../core/database/database_providers.dart';
import '../../core/database/sample_data.dart';
import '../../core/security/security_service.dart';
import '../settings/settings_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _biometricEnabled = false;
  bool _addSampleData = true;
  bool _loading = false;

  Future<void> _onStart() async {
    setState(() => _loading = true);
    try {
      final db = ref.read(appDatabaseProvider);
      if (_addSampleData) {
        await seedSampleData(db);
      }
      final security = SecurityService(const FlutterSecureStorage(), LocalAuthentication());
      await security.setBiometricEnabled(_biometricEnabled);
      if (_biometricEnabled) {
        final ok = await security.authenticate();
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Biometric doğrulama başlatılamadı. Ayarlardan tekrar deneyebilirsin.')),
          );
        }
      }
      await markOnboardingComplete(ref);
      if (!mounted) return;
      context.go('/dashboard');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(selectedCurrencyProvider);
    final mode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                'Finova Expense',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Gelir, gider, bütçe ve finansal alışkanlıklarını akıllı grafiklerle takip et.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              Text('Para Birimi', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.supportedCurrencies.map((c) {
                  final selected = c == currency;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(selectedCurrencyProvider.notifier).state = c,
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 24),
              Text('Tema', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Açık')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Koyu')),
                ],
                selected: {mode},
                onSelectionChanged: (v) =>
                    ref.read(themeModeProvider.notifier).state = v.first,
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _biometricEnabled,
                      onChanged: (v) =>
                          setState(() => _biometricEnabled = v ?? false),
                      title: const Text('PIN/Biometric koruma'),
                      subtitle: const Text(
                          'Uygulamayı açarken kimlik doğrulama istesin'),
                      secondary:
                          const Icon(Icons.fingerprint_rounded),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _addSampleData,
                      onChanged: (v) =>
                          setState(() => _addSampleData = v ?? true),
                      title: const Text('Örnek verilerle başla'),
                      subtitle: const Text(
                          'Kategoriler, hesaplar ve işlemler otomatik eklenir'),
                      secondary:
                          const Icon(Icons.data_exploration_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _loading ? null : _onStart,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Başla',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
