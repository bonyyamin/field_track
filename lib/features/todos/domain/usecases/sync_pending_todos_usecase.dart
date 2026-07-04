import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../repositories/todo_repository.dart';

class SyncPendingTodosUseCase implements UseCase<void, NoParams> {
  final TodoRepository _repository;

  const SyncPendingTodosUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.syncPendingChanges();
  }
}