import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams {
  final String email;
  final String password;

  const SignInWithEmailParams({required this.email, required this.password});
}

class SignInWithEmail implements UseCase<AppUserEntity, SignInWithEmailParams> {
  final AuthRepository repository;
  const SignInWithEmail(this.repository);

  @override
  Future<Either<Failures, AppUserEntity>> call(SignInWithEmailParams params) {
    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
