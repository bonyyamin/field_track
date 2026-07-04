import 'package:equatable/equatable.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class ToggleTodoParams extends Equatable {
  final String todoId;
  final bool isCompleted;

  const ToggleTodoParams({
    required this.todoId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [todoId, isCompleted];
}

class ToggleTodoUseCase implements UseCase<TodoEntity, ToggleTodoParams> {
  final TodoRepository _repository;

  const ToggleTodoUseCase(this._repository);

  @override
  Future<Either<Failure, TodoEntity>> call(ToggleTodoParams params) {
    return _repository.toggleTodo(params.todoId, params.isCompleted);
  }
}