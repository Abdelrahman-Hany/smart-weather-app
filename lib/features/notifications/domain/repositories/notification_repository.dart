import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class NotificationRepository {
  Future<Either<Failures, bool>> requestPermissions();
  Future<Either<Failures, Unit>> initializeMessageHandlers();
  Future<Either<Failures, Unit>> startTokenSyncForUser(String userId);
  Future<Either<Failures, Unit>> stopTokenSync();
}