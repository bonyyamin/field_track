import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';

/// Abstract contract for auth operations.
/// Implemented by [AuthRepositoryImpl] in the data layer;
/// consumed by use cases (dependency inversion).
abstract class AuthRepository {
  /// Authenticate with email + password. Returns [UserEntity] on success.
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Create new account. Returns [UserEntity] on success.
  Future<Either<Failure, UserEntity>> register(
    String fullName,
    String email,
    String password,
  );

  /// Invalidate tokens server-side and clear local session.
  Future<Either<Failure, void>> logout();

  /// Fetch the currently authenticated user profile from API.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Returns true if a non-expired access token exists locally.
  Future<Either<Failure, bool>> hasValidSession();
}
