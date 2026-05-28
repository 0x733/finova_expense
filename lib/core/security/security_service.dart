import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  SecurityService(this._storage, this._auth);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  static const _pinKey = 'app_pin';
  static const _biometricEnabledKey = 'biometric_enabled';

  Future<bool> authenticate() async {
    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    if (!canCheck || !supported) {
      return false;
    }
    return _auth.authenticate(
      localizedReason: 'Finova Expense kilidini aç',
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );
  }

  Future<void> savePin(String pin) => _storage.write(key: _pinKey, value: pin);
  Future<String?> getPin() => _storage.read(key: _pinKey);

  Future<void> setBiometricEnabled(bool enabled) => _storage.write(key: _biometricEnabledKey, value: enabled ? '1' : '0');

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == '1';
  }
}

