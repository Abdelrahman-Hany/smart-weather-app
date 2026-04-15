import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notification_repository.dart';

class InitializeMessageHandlers implements UseCase<Unit, NoParams> {
  final NotificationRepository repository;
  InitializeMessageHandlers(this.repository);

  @override
  Future<Either<Failures, Unit>> call(NoParams params) {
    return repository.initializeMessageHandlers();
  }
}