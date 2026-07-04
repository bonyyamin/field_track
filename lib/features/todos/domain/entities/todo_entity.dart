import 'package:equatable/equatable.dart';
import 'package:field_tracker/core/storage/database_tables.dart';

/// Core domain entity representing a task/todo item in FieldTrack.
class TodoEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const TodoEntity({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  TodoEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueAt: dueAt ?? this.dueAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        dueAt,
        updatedAt,
        syncStatus,
      ];
}