import 'package:equatable/equatable.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodosParams extends Equatable {
  final bool forceRefresh;

  const GetTodosParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class GetTodosUseCase implements UseCase<List<TodoEntity>, GetTodosParams> {
  final TodoRepository _repository;

  const GetTodosUseCase(this._repository);

  @override
  Future<Either<Failure, List<TodoEntity>>> call(GetTodosParams params) {
    return _repository.getTodos(forceRefresh: params.forceRefresh);
  }
}
