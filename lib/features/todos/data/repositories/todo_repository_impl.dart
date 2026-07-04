import 'package:field_tracker/core/error/exceptions.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/storage/database_tables.dart';
import 'package:field_tracker/core/usecase/usecase.dart';

import '../../domain/entities/pending_change_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/pending_change_model.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Default seed tasks matching the design screenshot when server returns 404 or empty.
  static List<TodoModel> get _defaultInitialTodos {
    final now = DateTime.now();
    return [
      TodoModel(
        id: '66511c4f8d1a2b3c4d5e6f01',
        title: 'Visit branch manager',
        description: 'Collect signed documents from downtown branch',
        isCompleted: false,
        dueAt: DateTime(now.year, now.month, now.day, 9, 0),
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ),
      TodoModel(
        id: '66511c4f8d1a2b3c4d5e6f02',
        title: 'Take inventory count',
        description: 'Count shelf stock and storage stock in warehouse',
        isCompleted: false,
        dueAt: DateTime(now.year, now.month, now.day, 11, 0),
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ),
      TodoModel(
        id: '66511c4f8d1a2b3c4d5e6f03',
        title: 'Inspect service desk',
        description: 'Check system readiness and staff attendance',
        isCompleted: false,
        dueAt: DateTime(now.year, now.month, now.day, 12, 0),
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ),
      TodoModel(
        id: '66511c4f8d1a2b3c4d5e6f04',
        title: 'Update location signage',
        description: 'Replace old directional signs at city office',
        isCompleted: true,
        dueAt: DateTime(now.year, now.month, now.day, 13, 0),
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ),
      TodoModel(
        id: '66511c4f8d1a2b3c4d5e6f05',
        title: 'Submit daily report',
        description: 'Log visit summary and photos',
        isCompleted: false,
        dueAt: DateTime(now.year, now.month, now.day, 17, 0),
        updatedAt: now,
        syncStatus: SyncStatus.synced,
      ),
    ];
  }

  @override
  Future<Either<Failure, List<TodoEntity>>> getTodos({bool forceRefresh = false}) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        if (remoteTodos.isNotEmpty) {
          await localDataSource.cacheTodos(remoteTodos);
        } else {
          final cached = await localDataSource.getCachedTodos();
          if (cached.isEmpty) {
            await localDataSource.cacheTodos(_defaultInitialTodos);
          }
        }
        final cached = await localDataSource.getCachedTodos();
        return Right(cached);
      } catch (_) {
        // Fallback to local cache or seed default tasks if mock server endpoint returns 404
        final cached = await localDataSource.getCachedTodos();
        if (cached.isNotEmpty) return Right(cached);

        await localDataSource.cacheTodos(_defaultInitialTodos);
        final seeded = await localDataSource.getCachedTodos();
        return Right(seeded);
      }
    }

    // Offline mode: load directly from Hive box
    final cached = await localDataSource.getCachedTodos();
    if (cached.isEmpty) {
      await localDataSource.cacheTodos(_defaultInitialTodos);
      return Right(await localDataSource.getCachedTodos());
    }
    return Right(cached);
  }

  @override
  Future<Either<Failure, TodoEntity>> toggleTodo(String todoId, bool isCompleted) async {
    final now = DateTime.now().toUtc();

    // 1. ALWAYS update local DB first (optimistic UI update, works offline)
    await localDataSource.updateLocalTodoStatus(todoId, isCompleted, now);
    await localDataSource.enqueuePendingChange(
      PendingChangeModel(
        todoId: todoId,
        isCompleted: isCompleted,
        updatedAt: now,
        retryCount: 0,
        status: 'pending',
      ),
    );

    // Get updated entity from local cache to return to UI
    final cachedList = await localDataSource.getCachedTodos();
    final updatedEntity = cachedList.firstWhere(
      (t) => t.id == todoId,
      orElse: () => TodoModel(
        id: todoId,
        title: '',
        isCompleted: isCompleted,
        updatedAt: now,
      ),
    );

    // 2. Try immediate sync if connected
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        await remoteDataSource.patchTodo(todoId, isCompleted, now.toIso8601String());
        await localDataSource.markTodoSynced(todoId);
        await localDataSource.removePendingChange(todoId);
      } catch (_) {
        // Keep in pendingChangesBox silently; background/reconnect sync will retry
      }
    }

    return Right(updatedEntity);
  }

  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    final pendingList = await localDataSource.getPendingChanges();
    if (pendingList.isEmpty) {
      return const Right(null);
    }

    // Purge any legacy pending changes with invalid IDs (not 24 hex characters)
    final validPendingList = <PendingChangeModel>[];
    for (final item in pendingList) {
      if (item.todoId.length != 24) {
        await localDataSource.removePendingChange(item.todoId);
      } else {
        validPendingList.add(item);
      }
    }

    if (validPendingList.isEmpty) {
      return const Right(null);
    }

    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      return const Left(NetworkFailure());
    }

    try {
      final syncedIds = await remoteDataSource.syncTodos(validPendingList);

      for (final id in syncedIds) {
        await localDataSource.markTodoSynced(id);
        await localDataSource.removePendingChange(id);
      }

      // Handle any items that were not returned as synced
      final remainingPending = await localDataSource.getPendingChanges();
      for (final item in remainingPending) {
        if (!syncedIds.contains(item.todoId)) {
          await localDataSource.incrementRetryCount(item.todoId);
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<PendingChangeEntity>> getPendingChanges() async {
    return localDataSource.getPendingChanges();
  }
}