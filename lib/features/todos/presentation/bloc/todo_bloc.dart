import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/storage/database_tables.dart';
import 'package:field_tracker/core/usecase/usecase.dart';

import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/sync_pending_todos_usecase.dart';
import '../../domain/usecases/toggle_todo_usecase.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final SyncPendingTodosUseCase syncPendingTodosUseCase;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _networkSubscription;

  TodoBloc({
    required this.getTodosUseCase,
    required this.toggleTodoUseCase,
    required this.syncPendingTodosUseCase,
    required this.networkInfo,
  }) : super(const TodoInitialState()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<FilterChangedEvent>(_onFilterChanged);
    on<SyncPendingTodosEvent>(_onSyncPendingTodos);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);

    // Listen to network status changes to auto-sync when back online
    _networkSubscription = networkInfo.onStatusChange.listen((isOnline) {
      add(ConnectivityChangedEvent(isOnline));
    });
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    final isOnline = await networkInfo.isConnected;

    if (state is! TodoLoadedState) {
      emit(const TodoLoadingState());
    }

    final result = await getTodosUseCase(GetTodosParams(forceRefresh: event.forceRefresh));

    result.fold(
      (failure) => emit(TodoErrorState(failure.message)),
      (todos) {
        final currentFilter = state is TodoLoadedState
            ? (state as TodoLoadedState).filter
            : TodoFilter.all;

        emit(TodoLoadedState(
          allTodos: todos,
          filter: currentFilter,
          isOffline: !isOnline,
        ));
      },
    );
  }

  Future<void> _onToggleTodo(
    ToggleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is! TodoLoadedState) return;
    final currentState = state as TodoLoadedState;

    // 1. Immediate optimistic UI state update
    final now = DateTime.now().toUtc();
    final updatedList = currentState.allTodos.map((t) {
      if (t.id == event.todoId) {
        return t.copyWith(
          isCompleted: event.newValue,
          updatedAt: now,
          syncStatus: SyncStatus.pending,
        );
      }
      return t;
    }).toList();

    emit(currentState.copyWith(allTodos: updatedList));

    // 2. Perform background local persistence and sync attempt
    await toggleTodoUseCase(ToggleTodoParams(
      todoId: event.todoId,
      isCompleted: event.newValue,
    ));

    // Refresh state from local storage to pick up true sync status
    final result = await getTodosUseCase(const GetTodosParams(forceRefresh: false));
    result.fold(
      (_) {},
      (todos) {
        if (state is TodoLoadedState) {
          emit((state as TodoLoadedState).copyWith(allTodos: todos));
        }
      },
    );
  }

  void _onFilterChanged(
    FilterChangedEvent event,
    Emitter<TodoState> emit,
  ) {
    if (state is TodoLoadedState) {
      emit((state as TodoLoadedState).copyWith(filter: event.filter));
    }
  }

  Future<void> _onSyncPendingTodos(
    SyncPendingTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is! TodoLoadedState) return;
    final currentState = state as TodoLoadedState;

    emit(currentState.copyWith(isSyncing: true));

    final result = await syncPendingTodosUseCase(const NoParams());

    result.fold(
      (_) => emit((state as TodoLoadedState).copyWith(isSyncing: false)),
      (_) async {
        // Reload fresh list from repository
        final reloadResult = await getTodosUseCase(const GetTodosParams(forceRefresh: true));
        reloadResult.fold(
          (_) => emit((state as TodoLoadedState).copyWith(isSyncing: false)),
          (todos) {
            emit(currentState.copyWith(
              allTodos: todos,
              isSyncing: false,
            ));
          },
        );
      },
    );
  }

  void _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<TodoState> emit,
  ) {
    if (state is TodoLoadedState) {
      final currentState = state as TodoLoadedState;
      emit(currentState.copyWith(isOffline: !event.isOnline));

      if (event.isOnline) {
        add(const SyncPendingTodosEvent());
      }
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    return super.close();
  }
}