import 'package:flutter/cupertino.dart';
import 'package:fpdart/src/either.dart';
import 'package:fpdart/src/unit.dart';
import 'package:weather_app_sarmad/core/error/error_handler.dart';
import 'package:weather_app_sarmad/core/error/failures.dart';
import 'package:weather_app_sarmad/features/notifications/data/datasources/fcm_messaging_service.dart';
import 'package:weather_app_sarmad/features/notifications/data/datasources/local_notification_service.dart';
import 'package:weather_app_sarmad/features/notifications/domain/entities/weather_alert_notification_entity.dart';
import 'package:weather_app_sarmad/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FcmMessagingService fcmMessagingService;
  final LocalNotificationService localNotificationService;
  NotificationRepositoryImpl({required this.fcmMessagingService, required this.localNotificationService});
  @override
  Future<Either<Failures, Unit>> initializeMessageHandlers() async {
    try {
      await fcmMessagingService.initializeMessageHandlers();
      return Right(unit);
    } catch (e) {
      return Left((ErrorHandler.handle(e)));
    }
  }

  @override
  Future<Either<Failures, bool>> requestPermissions() async {
    try {
      final result = await fcmMessagingService.requestPermissions();
      return Right(result);
    } catch (e) {
      return Left((ErrorHandler.handle(e)));
    }
  }

  @override
  Future<Either<Failures, Unit>> startTokenSyncForUser(String userId) async {
    try {
      await fcmMessagingService.startTokenSyncForUser(userId);
      return Right(unit);
    } catch (e) {
      return Left((ErrorHandler.handle(e)));
    }
  }

  @override
  Future<Either<Failures, Unit>> stopTokenSync() async {
    try {
      await fcmMessagingService.stopTokenSync();
      return Right(unit);
    } catch (e) {
      return Left((ErrorHandler.handle(e)));
    }
  }

  @override
  Future<Either<Failures, Unit>> initializeLocalNotifications() async {
    try {
      await localNotificationService.initialize();
      return Right(unit);
    } catch (e) {
      return Left((ErrorHandler.handle(e)));
    }
  }

  @override
  Future<Either<Failures, Unit>> showWeatherAlertNotification(
    WeatherAlertNotificationEntity alert,
  ) async {
    try{
      await localNotificationService.showWeatherAlert(alert);
      return Right(unit);
    }catch(e){
      return Left((ErrorHandler.handle(e)));
    }
  }
}
