import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class RequestNotificationPermissions implements UseCase<bool, NoParams> {
  final NotificationRepository repository;
  RequestNotificationPermissions(this.repository);

  @override
  Future<Either<Failures, bool>> call(NoParams params) {
    return repository.requestPermissions();
  }
}