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
  const ServerFailure([super.message = 'Server failure occurred']);
}

/// Returned when local database or secure storage caching fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred']);
}

/// Returned when network connectivity is unavailable.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet connection']);
}

/// Returned when authentication or token validation fails.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Returned when input data validation fails.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}