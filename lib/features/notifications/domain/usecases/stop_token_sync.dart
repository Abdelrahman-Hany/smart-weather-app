import 'package:fpdart/fpdart.dart';
import 'package:weather_app_sarmad/core/error/failures.dart';
import 'package:weather_app_sarmad/core/usecase/usecase.dart';
import 'package:weather_app_sarmad/features/notifications/domain/repositories/notification_repository.dart';

class StopTokenSync implements UseCase<Unit, NoParams> {
  final NotificationRepository repository;
  StopTokenSync(this.repository);
  @override
  Future<Either<Failures, Unit>> call(NoParams params) {
    return repository.stopTokenSync();
  }
  
}