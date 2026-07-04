import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/auth/domain/usecases/login_usecases.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_state.dart';

/// AuthBloc orchestrates authentication state across the app.
///
/// Event → State transitions:
///   [AppStarted]        → [AuthAuthenticated] | [AuthUnauthenticated]
///   [LoginRequested]    → [AuthLoading] → [AuthAuthenticated] | [AuthFailureState]
///   [RegisterRequested] → [AuthLoading] → [AuthAuthenticated] | [AuthFailureState]
///   [LogoutRequested]   → [AuthUnauthenticated]
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final HasValidSessionUseCase _hasValidSession;
  final GetCurrentUserUseCase _getCurrentUser;

  AuthBloc({
    required this._login,
    required this._register,
    required this._logout,
    required this._hasValidSession,
    required this._getCurrentUser,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ── AppStarted ────────────────────────────────────────────────────────────

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final sessionResult = await _hasValidSession(const NoParams());

    await sessionResult.fold(
      (_) async => emit(const AuthUnauthenticated()),
      (hasSession) async {
        if (!hasSession) {
          emit(const AuthUnauthenticated());
          return;
        }

        final userResult = await _getCurrentUser(const NoParams());
        userResult.fold(
          (_) => emit(const AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
        );
      },
    );
  }

  // ── LoginRequested ────────────────────────────────────────────────────────

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ── RegisterRequested ─────────────────────────────────────────────────────

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _register(
      RegisterParams(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ── LogoutRequested ───────────────────────────────────────────────────────

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout(const NoParams());
    emit(const AuthUnauthenticated());
  }
}