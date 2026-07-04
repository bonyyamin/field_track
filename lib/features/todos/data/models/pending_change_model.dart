import 'package:field_tracker/core/storage/database_tables.dart';
import '../../domain/entities/pending_change_entity.dart';

class PendingChangeModel extends PendingChangeEntity {
  const PendingChangeModel({
    required super.todoId,
    required super.isCompleted,
    required super.updatedAt,
    super.retryCount = 0,
    super.status = 'pending',
  });

  factory PendingChangeModel.fromJson(Map<String, dynamic> json) {
    return PendingChangeModel(
      todoId: (json['todo_id'] ?? json['todoId'] ?? '').toString(),
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      retryCount: json['retry_count'] ?? json['retryCount'] ?? 0,
      status: (json['status'] ?? 'pending').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo_id': todoId,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PendingChangeModel.fromHiveModel(PendingChangeHiveModel hiveModel) {
    return PendingChangeModel(
      todoId: hiveModel.todoId,
      isCompleted: hiveModel.isCompleted,
      updatedAt: DateTime.tryParse(hiveModel.updatedAt) ?? DateTime.now().toUtc(),
      retryCount: hiveModel.retryCount,
      status: hiveModel.status,
    );
  }

  PendingChangeHiveModel toHiveModel() {
    return PendingChangeHiveModel(
      todoId: todoId,
      isCompleted: isCompleted,
      updatedAt: updatedAt.toIso8601String(),
      retryCount: retryCount,
      status: status,
    );
  }
}