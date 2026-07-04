import 'package:equatable/equatable.dart';

enum TodoFilter {
  all('All'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TodoFilter(this.label);
}

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  final bool forceRefresh;

  const LoadTodosEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class ToggleTodoEvent extends TodoEvent {
  final String todoId;
  final bool newValue;

  const ToggleTodoEvent({
    required this.todoId,
    required this.newValue,
  });

  @override
  List<Object?> get props => [todoId, newValue];
}

class FilterChangedEvent extends TodoEvent {
  final TodoFilter filter;

  const FilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SyncPendingTodosEvent extends TodoEvent {
  const SyncPendingTodosEvent();
}

class ConnectivityChangedEvent extends TodoEvent {
  final bool isOnline;

  const ConnectivityChangedEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}