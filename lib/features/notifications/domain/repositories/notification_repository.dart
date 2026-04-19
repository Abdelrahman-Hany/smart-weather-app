import 'package:fpdart/fpdart.dart';
import 'package:weather_app_sarmad/features/notifications/domain/entities/weather_alert_notification_entity.dart';

import '../../../../core/error/failures.dart';

abstract interface class NotificationRepository {
  Future<Either<Failures, bool>> requestPermissions();
  Future<Either<Failures, Unit>> initializeMessageHandlers();
  Future<Either<Failures, Unit>> startTokenSyncForUser(String userId);
  Future<Either<Failures, Unit>> stopTokenSync();

  Future<Either<Failures, Unit>> initializeLocalNotifications();
  Future<Either<Failures, Unit>> showWeatherAlertNotification(WeatherAlertNotificationEntity alert);
}