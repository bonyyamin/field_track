/// Custom exception classes thrown at the data layer.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Thrown when a remote server call fails or returns an invalid status code.
class ServerException extends AppException {
  final Map<String, dynamic>? data;

  const ServerException({
    required String message,
    int? statusCode,
    this.data,
  }) : super(message, statusCode: statusCode);
}

/// Thrown when local database or cached storage operations fail.
class CacheException extends AppException {
  const CacheException({required String message}) : super(message);
}

/// Thrown when authentication is missing, invalid, or expired (401/403).
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Your session has expired. Please log in again.',
  }) : super(message, statusCode: 401);
}

/// Thrown when there is no active internet connection.
class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection. Please check your network and try again.',
  }) : super(message);
}

/// Thrown when input validation fails from client or server side.
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    int? statusCode,
  }) : super(message, statusCode: statusCode);
}

/// Thrown when location permissions are denied by the user.
class LocationPermissionException extends AppException {
  const LocationPermissionException({
    String message = 'Location access was denied. Please allow it in your device settings.',
  }) : super(message);
}

/// Thrown when device location services (GPS) are turned off.
class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException({
    String message = 'Location services are turned off. Please enable GPS in your settings.',
  }) : super(message);
}