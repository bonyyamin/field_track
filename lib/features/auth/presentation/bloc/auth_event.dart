import 'package:equatable/equatable.dart';

/// Base sealed class for all auth events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app start — checks for a persisted session.
final class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Fired when the user submits the login form.
final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the user submits the register form.
final class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

/// Fired when the user taps logout.
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}