import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/domain/usecases/login_usecases.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/usecases/get_profile_stats_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// ProfileBloc manages user profile state, update profile, and sign out logic.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUseCase getCurrentUser;
  final GetProfileStatsUseCase getProfileStats;
  final UpdateProfileUseCase updateProfile;
  final LogoutUseCase logout;

  ProfileBloc({
    required this.getCurrentUser,
    required this.getProfileStats,
    required this.updateProfile,
    required this.logout,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfileSubmitted>(_onUpdateProfileSubmitted);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    await _fetchProfileData(emit);
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    await _fetchProfileData(emit);
  }

  Future<void> _fetchProfileData(Emitter<ProfileState> emit) async {
    final userResult = await getCurrentUser(const NoParams());

    await userResult.fold(
      (failure) async {
        emit(ProfileError(failure.message));
      },
      (user) async {
        final statsResult = await getProfileStats(const NoParams());
        statsResult.fold(
          (failure) => emit(ProfileLoaded(
            user: user,
            stats: const ProfileStats(
              completedTasks: 0,
              totalTasks: 0,
              activeLocationsCount: 0,
            ),
          )),
          (stats) => emit(ProfileLoaded(
            user: user,
            stats: stats,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateProfileSubmitted(
    UpdateProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    ProfileStats currentStats = const ProfileStats(
      completedTasks: 0,
      totalTasks: 0,
      activeLocationsCount: 0,
    );
    if (currentState is ProfileLoaded) {
      currentStats = currentState.stats;
    }

    emit(const ProfileLoading());

    final updateResult = await updateProfile(
      UpdateProfileParams(
        fullName: event.fullName,
        email: event.email,
      ),
    );

    updateResult.fold(
      (failure) => emit(ProfileError(failure.message)),
      (updatedUser) => emit(ProfileLoaded(
        user: updatedUser,
        stats: currentStats,
      )),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSigningOut());
    final logoutResult = await logout(const NoParams());

    logoutResult.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileSignedOut()),
    );
  }
}