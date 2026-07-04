import 'package:field_tracker/core/storage/database_tables.dart';
import 'package:field_tracker/core/storage/local_database.dart';
import '../models/pending_change_model.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> updateLocalTodoStatus(String id, bool isCompleted, DateTime updatedAt);
  Future<void> enqueuePendingChange(PendingChangeModel change);
  Future<List<PendingChangeModel>> getPendingChanges();
  Future<void> removePendingChange(String todoId);
  Future<void> markTodoSynced(String todoId);
  Future<void> incrementRetryCount(String todoId);
  Future<void> clearCache();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final LocalDatabase _db;

  const TodoLocalDataSourceImpl(this._db);

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final hiveModels = _db.todosBox.values.toList();
    return hiveModels.map((m) => TodoModel.fromHiveModel(m)).toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final pendingKeys = _db.pendingChangesBox.keys.toSet();

    for (final remoteTodo in todos) {
      // Don't overwrite local un-synced state if there is a pending local change
      if (pendingKeys.contains(remoteTodo.id)) {
        final existingHive = _db.todosBox.get(remoteTodo.id);
        if (existingHive != null) {
          final updatedHive = TodoHiveModel(
            id: remoteTodo.id,
            title: remoteTodo.title,
            description: remoteTodo.description,
            isCompleted: existingHive.isCompleted,
            dueAt: remoteTodo.dueAt?.toIso8601String(),
            updatedAt: existingHive.updatedAt,
            syncStatus: SyncStatus.pending.name,
          );
          await _db.todosBox.put(remoteTodo.id, updatedHive);
          continue;
        }
      }
      await _db.todosBox.put(remoteTodo.id, remoteTodo.toHiveModel());
    }
  }

  @override
  Future<void> updateLocalTodoStatus(String id, bool isCompleted, DateTime updatedAt) async {
    final existing = _db.todosBox.get(id);
    if (existing != null) {
      existing.isCompleted = isCompleted;
      existing.updatedAt = updatedAt.toIso8601String();
      existing.syncStatus = SyncStatus.pending.name;
      await existing.save();
    }
  }

  @override
  Future<void> enqueuePendingChange(PendingChangeModel change) async {
    // Keyed by todoId (latest write wins, prevents duplicates)
    await _db.pendingChangesBox.put(change.todoId, change.toHiveModel());
  }

  @override
  Future<List<PendingChangeModel>> getPendingChanges() async {
    final hiveModels = _db.pendingChangesBox.values.toList();
    return hiveModels.map((m) => PendingChangeModel.fromHiveModel(m)).toList();
  }

  @override
  Future<void> removePendingChange(String todoId) async {
    await _db.pendingChangesBox.delete(todoId);
  }

  @override
  Future<void> markTodoSynced(String todoId) async {
    final existing = _db.todosBox.get(todoId);
    if (existing != null) {
      existing.syncStatus = SyncStatus.synced.name;
      await existing.save();
    }
  }

  @override
  Future<void> incrementRetryCount(String todoId) async {
    final pending = _db.pendingChangesBox.get(todoId);
    if (pending != null) {
      pending.retryCount += 1;
      pending.status = PendingChangeStatus.failed.name;
      await pending.save();
    }
  }

  @override
  Future<void> clearCache() async {
    await _db.todosBox.clear();
    await _db.pendingChangesBox.clear();
  }
}
