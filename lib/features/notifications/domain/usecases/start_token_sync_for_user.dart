import 'package:fpdart/fpdart.dart';
import 'package:weather_app_sarmad/core/error/failures.dart';
import 'package:weather_app_sarmad/core/usecase/usecase.dart';
import 'package:weather_app_sarmad/features/notifications/domain/repositories/notification_repository.dart';

class StartTokenSyncForUser implements UseCase<Unit, StartTokenSyncParams> {
  final NotificationRepository repository;

  StartTokenSyncForUser(this.repository);

  @override
  Future<Either<Failures, Unit>> call(StartTokenSyncParams params) {
    return repository.startTokenSyncForUser(params.userId);
  }
}


class StartTokenSyncParams{
  final String userId;

 const StartTokenSyncParams({required this.userId});
}