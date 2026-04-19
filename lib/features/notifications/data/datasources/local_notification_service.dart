import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/weather_alert_notification_entity.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin plugin;

  LocalNotificationService({required this.plugin});

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(settings: settings);
  }

  Future<void> showWeatherAlert(WeatherAlertNotificationEntity alert) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts_channel',
      'Weather Alerts',
      channelDescription: 'Alerts for important weather condition changes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
     id: alert.id,
      title: alert.title,
      body: alert.body,
      notificationDetails: details,
      payload: alert.payload,
    );
  }
}