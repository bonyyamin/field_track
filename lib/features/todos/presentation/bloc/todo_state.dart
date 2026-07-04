import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';
import 'todo_event.dart';

sealed class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitialState extends TodoState {
  const TodoInitialState();
}

class TodoLoadingState extends TodoState {
  const TodoLoadingState();
}

class TodoLoadedState extends TodoState {
  final List<TodoEntity> allTodos;
  final TodoFilter filter;
  final bool isSyncing;
  final bool isOffline;
  final int pendingCount;

  const TodoLoadedState({
    required this.allTodos,
    this.filter = TodoFilter.all,
    this.isSyncing = false,
    this.isOffline = false,
    this.pendingCount = 0,
  });

  List<TodoEntity> get visibleTodos {
    switch (filter) {
      case TodoFilter.pending:
        return allTodos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return allTodos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
        return allTodos;
    }
  }

  int get doneCount => allTodos.where((t) => t.isCompleted).length;

  int get totalCount => allTodos.length;

  TodoLoadedState copyWith({
    List<TodoEntity>? allTodos,
    TodoFilter? filter,
    bool? isSyncing,
    bool? isOffline,
    int? pendingCount,
  }) {
    return TodoLoadedState(
      allTodos: allTodos ?? this.allTodos,
      filter: filter ?? this.filter,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [
        allTodos,
        filter,
        isSyncing,
        isOffline,
        pendingCount,
      ];
}

class TodoErrorState extends TodoState {
  final String message;

  const TodoErrorState(this.message);

  @override
  List<Object?> get props => [message];
}