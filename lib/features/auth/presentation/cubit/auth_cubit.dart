import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SignInAnonymously _signInAnonymously;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  StreamSubscription<AppUserEntity?>? _authSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    required SignInAnonymously signInAnonymously,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  }) : _authRepository = authRepository,
       _signInAnonymously = signInAnonymously,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOut = signOut,
       super(const AuthState());

  /// Start listening to auth state changes.
  void init() {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: currentUser));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearError: true,
          ),
        );
      }
    });
  }

  Future<void> signInAnonymously() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signInAnonymously(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> linkAnonymousToEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(state.copyWith(isLinkingAccount: true, clearError: true));
    final result = await _authRepository.linkAnonymousToEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLinkingAccount: false, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(isLinkingAccount: false, user: user)),
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signOut(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
