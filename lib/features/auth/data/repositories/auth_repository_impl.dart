import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
    : _dataSource = dataSource;

  @override
  AppUserEntity? get currentUser => _dataSource.currentUser;

  @override
  Stream<AppUserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<Either<Failures, AppUserEntity>> signInAnonymously() async {
    try {
      final user = await _dataSource.signInAnonymously();
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, AppUserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, AppUserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _dataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, AppUserEntity>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, AppUserEntity>> linkAnonymousToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _dataSource.linkAnonymousToEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failures, Unit>> signOut() async {
    try {
      await _dataSource.signOut();
      return right(unit);
    } on ServerException catch (e) {
      return left(Failures(message: e.message));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
