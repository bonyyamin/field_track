import 'package:field_tracker/core/storage/database_tables.dart';
import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required super.id,
    required super.title,
    super.description,
    required super.isCompleted,
    super.dueAt,
    required super.updatedAt,
    super.syncStatus = SyncStatus.synced,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now().toUtc();
      if (dateVal is DateTime) return dateVal;
      return DateTime.tryParse(dateVal.toString())?.toUtc() ?? DateTime.now().toUtc();
    }

    DateTime? parseNullableDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is DateTime) return dateVal;
      return DateTime.tryParse(dateVal.toString())?.toUtc();
    }

    return TodoModel(
      id: (json['id'] ?? json['todo_id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      dueAt: parseNullableDate(json['due_at'] ?? json['dueAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_at': dueAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TodoModel.fromHiveModel(TodoHiveModel hiveModel) {
    return TodoModel(
      id: hiveModel.id,
      title: hiveModel.title,
      description: hiveModel.description,
      isCompleted: hiveModel.isCompleted,
      dueAt: hiveModel.dueAt != null ? DateTime.tryParse(hiveModel.dueAt!) : null,
      updatedAt: DateTime.tryParse(hiveModel.updatedAt) ?? DateTime.now().toUtc(),
      syncStatus: hiveModel.syncStatusEnum,
    );
  }

  TodoHiveModel toHiveModel() {
    return TodoHiveModel(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueAt: dueAt?.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
      syncStatus: syncStatus.name,
    );
  }

  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      dueAt: entity.dueAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  @override
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueAt: dueAt ?? this.dueAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}