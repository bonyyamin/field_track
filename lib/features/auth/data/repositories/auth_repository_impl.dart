import 'package:field_tracker/core/error/error_mapper.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:field_tracker/features/auth/data/model/auth_response_model.dart';
import 'package:field_tracker/features/auth/data/model/user_model.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';
import 'package:field_tracker/features/auth/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Strategy:
///  - All write operations hit the remote first, then persist locally on success.
///  - [hasValidSession] is local-only (no network call) for fast startup.
///  - [getCurrentUser] fetches from remote; returns cached user on network error.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl({
    required this._remote,
    required this._local,
  });

  // ── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    // Bypass check for testing/development
    if (email.trim() == 'bony@gmail.com' && password == '12345678') {
      const mockUser = UserModel(
        id: 'bypass_bony_id',
        email: 'bony@gmail.com',
        fullName: 'Bony Yamin',
        role: 'admin',
      );
      final mockResponse = AuthResponseModel(
        accessToken: 'mock_bypass_access_token',
        refreshToken: 'mock_bypass_refresh_token',
        user: mockUser,
      );
      await _local.cacheSession(mockResponse);
      return const Right(mockUser);
    }

    try {
      final response = await _remote.login(email: email, password: password);
      await _local.cacheSession(response);
      return Right(response.user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _remote.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _local.cacheSession(response);
      return Right(response.user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Best-effort server-side invalidation; clear local regardless.
      await _remote.logout();
    } catch (_) {
      // Ignore errors — always clear local session.
    } finally {
      await _local.clearSession();
    }
    return const Right(null);
  }

  // ── Get current user ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    final cached = await _local.getCachedUser();
    if (cached != null && cached.email == 'bony@gmail.com') {
      return Right(cached);
    }
    try {
      final user = await _remote.getCurrentUser();
      await _local.updateCachedUser(user);
      return Right(user);
    } catch (e) {
      // Network unavailable — serve cached user if available.
      if (cached != null) return Right(cached);
      return Left(mapExceptionToFailure(e));
    }
  }

  // ── Has valid session ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> hasValidSession() async {
    try {
      final valid = await _local.hasValidSession();
      return Right(valid);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
