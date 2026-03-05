import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOut implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const SignOut(this.repository);

  @override
  Future<Either<Failures, Unit>> call(NoParams params) {
    return repository.signOut();
  }
}
