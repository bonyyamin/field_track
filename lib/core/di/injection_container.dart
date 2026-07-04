import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:field_tracker/core/network/dio_client.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:field_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:field_tracker/features/auth/domain/usecases/login_usecases.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_tracker/features/auth/repositories/auth_repository.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Configures and registers all application dependencies.
Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Core / Storage ────────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // ── Core / Network ────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<Connectivity>()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      secureStorage: sl<SecureStorageService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Expose the raw Dio instance for data sources that need it directly.
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // ── Feature: Auth ─────────────────────────────────────────────────────────

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<SecureStorageService>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      local: sl<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => HasValidSessionUseCase(sl<AuthRepository>()));

  // BLoC (factory so every widget tree gets a fresh instance if needed)
  sl.registerFactory(
    () => AuthBloc(
      login: sl<LoginUseCase>(),
      register: sl<RegisterUseCase>(),
      logout: sl<LogoutUseCase>(),
      hasValidSession: sl<HasValidSessionUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
    ),
  );

  // ── Feature: Locations & Geofence ────────────────────────────────────────
  // TODO: Register LocationRemoteDataSource, LocationRepositoryImpl,
  //       location use cases, GeofenceService, NotificationService

  // ── Feature: Todos & Sync ─────────────────────────────────────────────────
  // TODO: Register TodoRemoteDataSource, TodoLocalDataSource (Drift),
  //       TodoRepositoryImpl, todo use cases, SyncBloc
}