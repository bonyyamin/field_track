import 'package:dio/dio.dart';
import 'package:field_tracker/core/error/exceptions.dart';
import 'package:field_tracker/core/error/failures.dart';

/// Central translator: catch any exception → return the correct [Failure].
///
/// Usage inside every `RepositoryImpl` try/catch:
/// ```dart
/// } catch (e) {
///   return Left(mapExceptionToFailure(e));
/// }
/// ```
Failure mapExceptionToFailure(Object e) {
  // ── Dio / HTTP errors ──────────────────────────────────────────────────
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure('No internet connection. Please check your network and try again.');

      case DioExceptionType.sendTimeout:
        return const NetworkFailure('The request timed out. Please try again.');

      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('The server is not responding. Please try again later.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          final authMsg = _extractMessage(e, 'The email or password you entered is incorrect. Please try again.');
          return AuthFailure(authMsg);
        }
        if (statusCode == 422) {
          final message = _extractMessage(e, 'Please check your details and try again.');
          return ValidationFailure(message);
        }
        final message = _extractMessage(e, 'Something went wrong. Please try again shortly.');
        return ServerFailure(message);

      case DioExceptionType.cancel:
        return const NetworkFailure('The request was cancelled. Please try again.');

      default:
        return NetworkFailure(e.message ?? 'Something went wrong. Please check your connection and try again.');

    }
  }

  // ── Domain exceptions (thrown by data sources) ─────────────────────────
  if (e is UnauthorizedException) return AuthFailure(e.message);
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is ValidationException) return ValidationFailure(e.message);
  if (e is CacheException) return CacheFailure(e.message);
  if (e is ServerException) {
    return ServerFailure(e.message);
  }

  // ── Catch-all ──────────────────────────────────────────────────────────
  return const ServerFailure('Something went wrong. Please try again.');
}

/// Extracts a human-readable message from a [DioException] response body.
/// Falls back to [fallback] when the body has no `message` field.
String _extractMessage(DioException e, String fallback) {
  try {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] as String?) ??
          (data['error'] as String?) ??
          fallback;
    }
  } catch (_) {}
  return fallback;
}