import 'package:equatable/equatable.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';
import 'package:field_tracker/features/auth/repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String fullName;
  final String email;

  const UpdateProfileParams({
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, email];
}

/// Usecase to update user profile information.
class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  const UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return repository.updateProfile(params.fullName, params.email);
  }
}
