import 'package:equatable/equatable.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';
import 'package:field_tracker/features/auth/repositories/auth_repository.dart';

// ── LoginUseCase ─────────────────────────────────────────────────────────────

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repo;
  const LoginUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) =>
      _repo.login(params.email, params.password);
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// ── RegisterUseCase ───────────────────────────────────────────────────────────

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository _repo;
  const RegisterUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      _repo.register(params.fullName, params.email, params.password);
}

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String password;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

// ── LogoutUseCase ─────────────────────────────────────────────────────────────

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repo;
  const LogoutUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repo.logout();
}

// ── GetCurrentUserUseCase ─────────────────────────────────────────────────────

class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repo;
  const GetCurrentUserUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repo.getCurrentUser();
}

// ── HasValidSessionUseCase ────────────────────────────────────────────────────

class HasValidSessionUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _repo;
  const HasValidSessionUseCase(this._repo);

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repo.hasValidSession();
}
