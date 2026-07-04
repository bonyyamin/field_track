import 'package:dio/dio.dart';
import 'package:field_tracker/core/constants/api_endpoints.dart';
import 'package:field_tracker/core/error/exceptions.dart';
import 'package:field_tracker/features/auth/data/model/auth_response_model.dart';
import 'package:field_tracker/features/auth/data/model/user_model.dart';

/// Performs all auth HTTP calls against the remote API.
///
/// Throws typed [AppException] subclasses on failure — the repository's
/// catch-block translates these into [Failure] objects via [mapExceptionToFailure].
class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  // ── Get current user ──────────────────────────────────────────────────────

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  // ── Private helper ────────────────────────────────────────────────────────

  /// Translates [DioException] → typed [AppException].
  Never _throwMapped(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map ? (data['message'] as String?) : null;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw const NetworkException();
    }
    if (statusCode == 401) {
      throw UnauthorizedException(
        message: message ?? 'The email or password you entered is incorrect. Please try again.',
      );
    }
    if (statusCode == 422) {
      throw ValidationException(message: message ?? 'Validation error');
    }
    throw ServerException(
      message: message ?? 'Server error',
      statusCode: statusCode,
    );
  }
}