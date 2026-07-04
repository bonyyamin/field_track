import 'package:equatable/equatable.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';

/// Base sealed class for all auth states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — session check not yet performed.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Session check or auth operation is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated — holds the logged-in user.
final class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No valid session found — user needs to log in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed — carries a human-readable message.
final class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
