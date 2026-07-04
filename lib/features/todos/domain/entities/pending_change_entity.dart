import 'package:equatable/equatable.dart';

/// Domain representation of a queued offline todo change.
class PendingChangeEntity extends Equatable {
  final String todoId;
  final bool isCompleted;
  final DateTime updatedAt;
  final int retryCount;
  final String status;

  const PendingChangeEntity({
    required this.todoId,
    required this.isCompleted,
    required this.updatedAt,
    this.retryCount = 0,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [
        todoId,
        isCompleted,
        updatedAt,
        retryCount,
        status,
      ];
}
