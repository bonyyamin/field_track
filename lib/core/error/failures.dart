import 'package:equatable/equatable.dart';

/// Base Failure class representing domain-level error results.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Returned when server/API call fails.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end. Please try again shortly.']);
}

/// Returned when local database or secure storage caching fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not load saved data. Please restart the app.']);
}

/// Returned when network connectivity is unavailable.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network and try again.']);
}

/// Returned when authentication or token validation fails.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'The email or password you entered is incorrect. Please try again.']);
}

/// Returned when input data validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please check your details and try again.']);
}