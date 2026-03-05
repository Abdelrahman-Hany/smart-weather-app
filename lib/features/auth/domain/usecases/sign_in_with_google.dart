import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<AppUserEntity, NoParams> {
  final AuthRepository repository;
  const SignInWithGoogle(this.repository);

  @override
  Future<Either<Failures, AppUserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
