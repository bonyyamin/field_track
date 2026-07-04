import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../entities/pending_change_entity.dart';
import '../entities/todo_entity.dart';

/// Contract interface for the Todos repository in the domain layer.
abstract class TodoRepository {
  /// Fetches todos (loads from local storage, syncs with remote if connected).
  Future<Either<Failure, List<TodoEntity>>> getTodos({bool forceRefresh = false});

  /// Optimistically updates task completed status locally and queues pending change.
  Future<Either<Failure, TodoEntity>> toggleTodo(String todoId, bool isCompleted);

  /// Synchronises all queued pending changes to the server.
  Future<Either<Failure, void>> syncPendingChanges();

  /// Gets current list of pending unsynced changes.
  Future<List<PendingChangeEntity>> getPendingChanges();
}