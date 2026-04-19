import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/weather_alert_notification_entity.dart';
import '../repositories/notification_repository.dart';

class ShowWeatherAlert implements UseCase<Unit, ShowWeatherAlertParams> {
  final NotificationRepository repository;

  ShowWeatherAlert(this.repository);

  @override
  Future<Either<Failures, Unit>> call(ShowWeatherAlertParams params) {
    return repository.showWeatherAlertNotification(params.alert);
  }
}

class ShowWeatherAlertParams {
  final WeatherAlertNotificationEntity alert;

  const ShowWeatherAlertParams({required this.alert});
}