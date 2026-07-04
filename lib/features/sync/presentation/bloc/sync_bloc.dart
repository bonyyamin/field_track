import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/storage/local_database.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/todos/domain/usecases/sync_pending_todos_usecase.dart';
import '../../domain/usecases/get_sync_status_usecase.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final GetSyncStatusUseCase getSyncStatusUseCase;
  final SyncPendingTodosUseCase syncPendingTodosUseCase;
  final NetworkInfo networkInfo;
  final SecureStorageService secureStorage;
  final LocalDatabase localDatabase;

  StreamSubscription<bool>? _networkSubscription;
  StreamSubscription? _hiveSubscription;

  SyncBloc({
    required this.getSyncStatusUseCase,
    required this.syncPendingTodosUseCase,
    required this.networkInfo,
    required this.secureStorage,
    required this.localDatabase,
  })  : super(SyncState.initial()) {
    on<LoadSyncStatus>(_onLoadSyncStatus);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<PendingChangesUpdated>(_onPendingChangesUpdated);
    on<ManualSyncRequested>(_onManualSyncRequested);

    _initListeners();
  }

  void _initListeners() {
    _networkSubscription = networkInfo.onStatusChange.listen((isOnline) {
      add(ConnectivityChanged(isOnline));
    });

    _hiveSubscription = localDatabase.pendingChangesBox.watch().listen((_) {
      add(const LoadSyncStatus());
    });
  }

  Future<void> _onLoadSyncStatus(
    LoadSyncStatus event,
    Emitter<SyncState> emit,
  ) async {
    final snapshot = await getSyncStatusUseCase();
    emit(state.copyWith(
      isOffline: snapshot.isOffline,
      pendingChanges: snapshot.pendingChanges,
      lastSyncedAt: snapshot.lastSyncedAt,
    ));
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    final snapshot = await getSyncStatusUseCase();
    emit(state.copyWith(
      isOffline: !event.isOnline,
      pendingChanges: snapshot.pendingChanges,
    ));
  }

  Future<void> _onPendingChangesUpdated(
    PendingChangesUpdated event,
    Emitter<SyncState> emit,
  ) async {
    emit(state.copyWith(pendingChanges: event.pendingChanges));
  }

  Future<void> _onManualSyncRequested(
    ManualSyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      emit(state.copyWith(
        isOffline: true,
        errorMessage: 'You are currently offline. Changes will upload when connected.',
      ));
      return;
    }

    emit(state.copyWith(isSyncing: true));

    final result = await syncPendingTodosUseCase(const NoParams());

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSyncing: false,
          errorMessage: failure.message,
        ));
      },
      (_) async {
        final now = DateTime.now();
        await secureStorage.saveLastSyncedAt(now);
        final snapshot = await getSyncStatusUseCase();

        emit(state.copyWith(
          isSyncing: false,
          pendingChanges: snapshot.pendingChanges,
          lastSyncedAt: now,
          successMessage: 'All pending changes synced successfully!',
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _hiveSubscription?.cancel();
    return super.close();
  }
}