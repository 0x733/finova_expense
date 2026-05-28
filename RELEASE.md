# RELEASE

## 1) Android Keystore Oluşturma

```bash
keytool -genkey -v -keystore ~/finova-release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias finova
```

## 2) `key.properties` Örneği

`android/key.properties` dosyası:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=finova
storeFile=/home/USER/finova-release-keystore.jks
```

## 3) Gradle Yapılandırması

- `android/app/build.gradle.kts` içinde:
  - `compileSdk = 36`
  - `minSdk = 23`
  - `targetSdk = 35`
  - `isMinifyEnabled = true`
  - `isShrinkResources = true`
  - Proguard dosyaları aktif
  - `coreLibraryDesugaring` aktif

Üretim imzası için release signing config, `key.properties` üzerinden gerçek keystore ile eşleştirilmelidir.

## 4) APK / AAB Üretimi

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Çıktılar:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 5) Google Play Hazırlık Checklist

- [ ] Uygulama imzalama ve keystore doğrulandı
- [ ] Version code / version name güncellendi
- [ ] Release notları hazırlandı
- [ ] Privacy Policy URL eklendi
- [ ] Data Safety formu dolduruldu
- [ ] Test cihazlarında smoke/regression yapıldı
- [ ] AAB Play Console pre-launch raporu incelendi

## 6) Privacy Policy Notları

- Finansal veriler cihazda lokal veritabanında tutulur.
- Harici API’ye finansal içerik gönderilmez.
- Kullanıcı isteğiyle yapılan export dosyaları kullanıcı kontrolündedir.
- Bildirimler sadece cihaz içi planlanır.

## 7) Veri Güvenliği Beyanı İçin Notlar

- Veri saklama: Local SQLite (Drift)
- Hassas ayarlar: `flutter_secure_storage`
- Kimlik doğrulama: `local_auth` altyapısı
- Network zorunluluğu olmadan temel kullanım
- Loglarda hassas finansal veri göstermeme yaklaşımı
