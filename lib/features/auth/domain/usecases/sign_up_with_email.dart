import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

class SignUpWithEmail implements UseCase<AppUserEntity, SignUpWithEmailParams> {
  final AuthRepository repository;
  const SignUpWithEmail(this.repository);

  @override
  Future<Either<Failures, AppUserEntity>> call(SignUpWithEmailParams params) {
    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
