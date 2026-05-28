import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    try {
      await _plugin.initialize(const InitializationSettings(android: android));
    } catch (_) {}
  }

  Future<void> showSimple({required int id, required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('finova_main', 'Finova', importance: Importance.defaultImportance),
    );
    await _plugin.show(id, title, body, details);
  }
}
