import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../core/security/security_service.dart';
import '../core/services/notification_service.dart';
import '../features/settings/settings_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FinovaApp extends ConsumerStatefulWidget {
  const FinovaApp({super.key});

  @override
  ConsumerState<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends ConsumerState<FinovaApp> {
  bool _locked = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.initialize();
    _loadSettings();
    _bootstrapSecurity();
  }

  void _loadSettings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsInitProvider);
    });
  }

  Future<void> _bootstrapSecurity() async {
    final security = SecurityService(const FlutterSecureStorage(), LocalAuthentication());
    final enabled = await security.isBiometricEnabled();
    if (!mounted) return;
    if (!enabled) {
      setState(() {
        _locked = false;
      });
      return;
    }
    final ok = await security.authenticate();
    if (!mounted) return;
    setState(() {
      _locked = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final app = MaterialApp.router(
          title: 'Finova Expense',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: buildLightTheme(lightDynamic),
          darkTheme: buildDarkTheme(darkDynamic),
          routerConfig: router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
        );
        if (!_locked) {
          return app;
        }
        return Stack(
          children: [
            app,
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: FilledButton(
                  onPressed: _bootstrapSecurity,
                  child: const Text('Biometric ile kilidi aç'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
