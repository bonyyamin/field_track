import 'package:equatable/equatable.dart';
import 'package:field_tracker/features/auth/entities/user_entity.dart';
import '../../domain/entities/profile_stats.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profile loading state.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully state.
final class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final ProfileStats stats;

  const ProfileLoaded({
    required this.user,
    required this.stats,
  });

  @override
  List<Object?> get props => [user, stats];
}

/// Profile error state.
final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sign out in progress state.
final class ProfileSigningOut extends ProfileState {
  const ProfileSigningOut();
}

/// Sign out completed state.
final class ProfileSignedOut extends ProfileState {
  const ProfileSignedOut();
}
