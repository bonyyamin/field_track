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
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const AuthFailure();
        }
        if (statusCode == 422) {
          final message = _extractMessage(e, 'Validation error');
          return ValidationFailure(message);
        }
        final message = _extractMessage(e, 'Server error');
        return ServerFailure(message);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled');

      default:
        return const NetworkFailure();
    }
  }

  // ── Domain exceptions (thrown by data sources) ─────────────────────────
  if (e is UnauthorizedException) return const AuthFailure();
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is ValidationException) return ValidationFailure(e.message);
  if (e is CacheException) return CacheFailure(e.message);
  if (e is ServerException) {
    return ServerFailure(e.message);
  }

  // ── Catch-all ──────────────────────────────────────────────────────────
  return const ServerFailure('An unexpected error occurred');
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