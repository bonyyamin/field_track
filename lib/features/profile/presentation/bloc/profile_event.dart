import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when profile page initializes or needs reloading.
final class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Event triggered when user pulls to refresh profile data.
final class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// Event triggered when user submits edit profile form.
final class UpdateProfileSubmitted extends ProfileEvent {
  final String fullName;
  final String email;

  const UpdateProfileSubmitted({
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, email];
}

/// Event triggered when user clicks sign out button.
final class SignOutRequested extends ProfileEvent {
  const SignOutRequested();
}