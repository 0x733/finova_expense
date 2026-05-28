# Finova Expense

Finova Expense, Android odaklı, Flutter ile geliştirilmiş offline-first kişisel finans takip uygulamasıdır. Gelir, gider, bütçe, kategori, cüzdan, abonelik ve borç/alacak takibini modern ekranlarla sunar.

## Özellikler

- Offline-first yapı (Drift + SQLite)
- Gelir / gider / transfer kayıtları
- Dashboard özet kartları ve trend grafik alanları
- Bütçe, kategori, cüzdan, abonelik ve borç/alacak modülleri
- Material 3 tema, açık/koyu/sistem modu
- TRY/USD/EUR/GBP para birimi altyapısı
- Local notifications altyapısı
- Biometric/PIN altyapısı için local_auth ve secure storage entegrasyon temeli
- Riverpod tabanlı state management
- Widget/unit/repository/integration test seti

## Mimari

- Clean Architecture prensiplerine uyumlu, feature-first klasörleme
- Katmanlar:
  - `core`: database, servisler, güvenlik, hata/result altyapısı
  - `features`: ekran bazlı modüller (dashboard, transactions, budgets, ...)
  - `shared`: ortak widget, formatter, chart bileşenleri
  - `app`: tema, router, uygulama iskeleti
- UI doğrudan DB erişimi yapmaz; provider + repository katmanı üzerinden ilerler.

## Kurulum

Ön koşullar:
- Flutter stable (3.44+ önerilir)
- Android SDK 36
- JDK 17

Adımlar:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Geliştirme Komutları

```bash
flutter analyze
flutter test
flutter run
```

## Test Komutları

```bash
flutter test
flutter test test/finance_and_repository_test.dart
flutter test test/widget_flows_test.dart
flutter test integration_test/app_flow_test.dart
```

## Release Build Komutları

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## Bilinen Limitler

- Bazı ekranlarda CRUD akışları temel seviyededir; ileri düzey filtre ve düzenleme akışları genişletilebilir.
- Export/import için altyapı yerleşimi hazır olsa da format validasyon kapsamı artırılabilir.
- Bildirim senaryoları planlama ve zamanlama tarafında genişletilebilir.

## Gelecek Geliştirmeler

- Gelişmiş analitik (heatmap, multi-range karşılaştırma, tahminleme)
- Transfer işlemlerinde çift taraflı ledger görünümü
- Daha zengin onboarding adımları ve örnek veri sihirbazı
- Genişletilmiş localization desteği
- Google Play release pipeline otomasyonu (CI/CD)
