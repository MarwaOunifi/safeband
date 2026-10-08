import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService().showAlert(
    title: message.notification?.title ?? 'SafeBand',
    body: message.notification?.body ?? '',
    type: AlertType.other,
  );
}

class NotificationService {
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;
  NotificationService._();

  final _fcm   = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'sos_channel', 'Urgences SOS',
        importance: Importance.max,
        enableVibration: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'alert_channel', 'Alertes bracelet',
        importance: Importance.high,
        enableVibration: true,
      ),
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((msg) {
      final type = AlertType.values.firstWhere(
        (e) => e.name == msg.data['type'],
        orElse: () => AlertType.other,
      );
      showAlert(
        title: msg.notification?.title ?? 'SafeBand',
        body: msg.notification?.body ?? '',
        type: type,
      );
    });
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> showAlert({
    required String title,
    required String body,
    required AlertType type,
  }) async {
    await _local.show(
      _idFor(type), title, body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          type == AlertType.sos ? 'sos_channel' : 'alert_channel',
          type == AlertType.sos ? 'Urgences SOS' : 'Alertes bracelet',
          importance: type == AlertType.sos ? Importance.max : Importance.high,
          priority: type == AlertType.sos ? Priority.max : Priority.high,
          color: _colorFor(type),
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
        ),
      ),
    );
  }

  Future<void> showUrgent({required String title, required String body}) async {
    await _local.show(
      0, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sos_channel', 'Urgences SOS',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          enableVibration: true,
          color: Color(0xFFF85149),
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  int _idFor(AlertType t) {
    switch (t) {
      case AlertType.sos:       return 0;
      case AlertType.battery:   return 1;
      case AlertType.outOfZone: return 2;
      case AlertType.removed:   return 3;
      default:                  return 9;
    }
  }

  Color _colorFor(AlertType t) {
    switch (t) {
      case AlertType.battery: return const Color(0xFFF0883E);
      default:                return const Color(0xFFF85149);
    }
  }
}
