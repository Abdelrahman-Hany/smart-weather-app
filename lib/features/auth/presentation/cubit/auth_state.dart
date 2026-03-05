import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user_entity.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUserEntity? user;
  final String? errorMessage;
  final bool isLinkingAccount;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isLinkingAccount = false,
  });

  bool get isAnonymous => user?.isAnonymous ?? true;
  bool get isSignedIn => status == AuthStatus.authenticated && user != null;
  bool get isFullAccount => isSignedIn && !isAnonymous;

  AuthState copyWith({
    AuthStatus? status,
    AppUserEntity? user,
    String? errorMessage,
    bool clearError = false,
    bool? isLinkingAccount,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLinkingAccount: isLinkingAccount ?? this.isLinkingAccount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user?.uid,
    user?.isAnonymous,
    errorMessage,
    isLinkingAccount,
  ];
}
