import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user_entity.dart';

abstract class AuthRepository {
  /// Returns the currently signed-in user, or null.
  AppUserEntity? get currentUser;

  /// Stream of auth state changes.
  Stream<AppUserEntity?> get authStateChanges;

  /// Sign in anonymously.
  Future<Either<Failures, AppUserEntity>> signInAnonymously();

  /// Sign in with email & password.
  Future<Either<Failures, AppUserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register with email & password.
  Future<Either<Failures, AppUserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with Google.
  Future<Either<Failures, AppUserEntity>> signInWithGoogle();

  /// Link anonymous account to email credentials.
  Future<Either<Failures, AppUserEntity>> linkAnonymousToEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out.
  Future<Either<Failures, Unit>> signOut();
}
