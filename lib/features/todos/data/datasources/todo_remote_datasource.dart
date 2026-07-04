import 'package:dio/dio.dart';
import 'package:field_tracker/core/constants/api_endpoints.dart';
import 'package:field_tracker/core/error/exceptions.dart';
import '../models/pending_change_model.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> patchTodo(String todoId, bool isCompleted, String updatedAt);
  Future<List<String>> syncTodos(List<PendingChangeModel> changes);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio _dio;

  const TodoRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await _dio.get(ApiEndpoints.todos);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data.containsKey('data')) {
          list = data['data'] as List;
        } else if (data is Map<String, dynamic> && data.containsKey('todos')) {
          list = data['todos'] as List;
        } else {
          list = [];
        }
        return list.map((json) => TodoModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw const ServerException(message: 'Failed to fetch todos');
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Failed to fetch todos';
      throw ServerException(message: msg.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TodoModel> patchTodo(String todoId, bool isCompleted, String updatedAt) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.todoById(todoId),
        data: {
          'is_completed': isCompleted,
          'updated_at': updatedAt,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        Map<String, dynamic> json;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          json = data['data'] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic> && data.containsKey('todo')) {
          json = data['todo'] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          json = data;
        } else {
          json = {};
        }
        return TodoModel.fromJson(json);
      }
      throw const ServerException(message: 'Failed to patch todo');
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Failed to patch todo';
      throw ServerException(message: msg.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> syncTodos(List<PendingChangeModel> changes) async {
    if (changes.isEmpty) return [];

    try {
      final response = await _dio.post(
        ApiEndpoints.todoSync,
        data: {
          'changes': changes.map((c) => c.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('synced_ids') && data['synced_ids'] is List) {
            return (data['synced_ids'] as List).map((e) => e.toString()).toList();
          }
          if (data.containsKey('synced') && data['synced'] is List) {
            return (data['synced'] as List).map((e) => e.toString()).toList();
          }
          if (data.containsKey('results') && data['results'] is List) {
            final results = data['results'] as List;
            final syncedIds = <String>[];
            for (final r in results) {
              if (r is Map<String, dynamic> && (r['success'] == true || r['status'] == 'synced')) {
                syncedIds.add((r['todo_id'] ?? r['id'] ?? '').toString());
              }
            }
            if (syncedIds.isNotEmpty) return syncedIds;
          }
        }
        return changes.map((c) => c.todoId).toList();
      }
      throw const ServerException(message: 'Failed to sync pending todos');
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Failed to sync pending todos';
      throw ServerException(message: msg.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}