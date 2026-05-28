import 'package:flutter/foundation.dart';

class LoggerService {
  const LoggerService._();

  static void debug(String message) {
    if (kReleaseMode) return;
    debugPrint(message);
  }
}
