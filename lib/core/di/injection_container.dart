import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:field_tracker/core/network/dio_client.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/services/geofence/geofence_service.dart';
import 'package:field_tracker/core/services/geofence/geofence_state_cache.dart';
import 'package:field_tracker/core/services/geofence/location_permission_handler.dart';
import 'package:field_tracker/core/services/notification/notification_permission_handler.dart';
import 'package:field_tracker/core/services/notification/notification_service.dart';
import 'package:field_tracker/core/services/sync/sync_service.dart';
import 'package:field_tracker/core/storage/local_database.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:field_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:field_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:field_tracker/features/auth/domain/usecases/login_usecases.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_tracker/features/auth/repositories/auth_repository.dart';
import 'package:field_tracker/features/locations/data/datasources/location_local_datasource.dart';
import 'package:field_tracker/features/locations/data/datasources/location_remote_datasource.dart';
import 'package:field_tracker/features/locations/data/repositories/location_repository_impl.dart';
import 'package:field_tracker/features/locations/domain/repositories/location_repository.dart';
import 'package:field_tracker/features/locations/domain/usecases/location_usecases.dart';
import 'package:field_tracker/features/locations/presentation/bloc/location_bloc.dart';

import 'package:field_tracker/features/todos/data/datasources/todo_local_datasource.dart';
import 'package:field_tracker/features/todos/data/datasources/todo_remote_datasource.dart';
import 'package:field_tracker/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:field_tracker/features/todos/domain/repositories/todo_repository.dart';
import 'package:field_tracker/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:field_tracker/features/todos/domain/usecases/sync_pending_todos_usecase.dart';
import 'package:field_tracker/features/todos/domain/usecases/toggle_todo_usecase.dart';
import 'package:field_tracker/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_tracker/core/usecase/usecase.dart';

/// Global Service Locator instance
final sl = GetIt.instance;

/// Configures and registers all application dependencies.
///
/// Pass [localDatabase] if it has already been initialised (e.g., in [main])
/// so the same Hive boxes are reused rather than opened a second time.
Future<void> configureDependencies({LocalDatabase? localDatabase}) async {
  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // ── Core / Storage ────────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // LocalDatabase (Hive) — use the pre-initialised instance if provided.
  sl.registerLazySingleton<LocalDatabase>(
    () => localDatabase ?? LocalDatabase(),
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

  // ── Core / Notification ───────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl<FlutterLocalNotificationsPlugin>()),
  );

  sl.registerLazySingleton<NotificationPermissionHandler>(
    () => NotificationPermissionHandler(sl<FlutterLocalNotificationsPlugin>()),
  );

  // ── Core / Geofence ───────────────────────────────────────────────────────
  sl.registerLazySingleton<GeofenceStateCache>(
    () => GeofenceStateCache(sl<LocalDatabase>().geofenceStateBox),
  );

  sl.registerLazySingleton<GeofenceService>(
    () => GeofenceService(
      stateCache: sl<GeofenceStateCache>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  sl.registerLazySingleton<LocationPermissionHandler>(
    () => LocationPermissionHandler(),
  );

  // ── Core / Sync ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      networkInfo: sl<NetworkInfo>(),
      syncCallback: () async {
        final result = await sl<SyncPendingTodosUseCase>()(const NoParams());
        return result.isRight;
      },
    ),
  );

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

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      login: sl<LoginUseCase>(),
      register: sl<RegisterUseCase>(),
      logout: sl<LogoutUseCase>(),
      hasValidSession: sl<HasValidSessionUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
    ),
  );

  // ── Feature: Locations ────────────────────────────────────────────────────

  // Data sources
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(sl<LocalDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl<LocationRemoteDataSource>(),
      localDataSource: sl<LocationLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLocationsUseCase(sl<LocationRepository>()));
  sl.registerLazySingleton(() => AddLocationUseCase(sl<LocationRepository>()));
  sl.registerLazySingleton(() => UpdateLocationUseCase(sl<LocationRepository>()));
  sl.registerLazySingleton(() => DeleteLocationUseCase(sl<LocationRepository>()));

  // BLoC
  sl.registerFactory(
    () => LocationBloc(
      getLocationsUseCase: sl<GetLocationsUseCase>(),
      addLocationUseCase: sl<AddLocationUseCase>(),
      updateLocationUseCase: sl<UpdateLocationUseCase>(),
      deleteLocationUseCase: sl<DeleteLocationUseCase>(),
    ),
  );

  // ── Feature: Todos & Sync ─────────────────────────────────────────────────

  // Data sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl<LocalDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl<TodoRemoteDataSource>(),
      localDataSource: sl<TodoLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodosUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => ToggleTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => SyncPendingTodosUseCase(sl<TodoRepository>()));

  // BLoC
  sl.registerFactory(
    () => TodoBloc(
      getTodosUseCase: sl<GetTodosUseCase>(),
      toggleTodoUseCase: sl<ToggleTodoUseCase>(),
      syncPendingTodosUseCase: sl<SyncPendingTodosUseCase>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}