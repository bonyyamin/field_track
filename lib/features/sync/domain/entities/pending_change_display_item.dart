import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Presentation-ready entity representing a pending offline todo change for the Sync screen UI.
class PendingChangeDisplayItem extends Equatable {
  final String todoId;
  final String title;
  final bool isCompleted;
  final DateTime updatedAt;
  final IconData iconData;

  const PendingChangeDisplayItem({
    required this.todoId,
    required this.title,
    required this.isCompleted,
    required this.updatedAt,
    this.iconData = Icons.task_alt_outlined,
  });

  @override
  List<Object?> get props => [todoId, title, isCompleted, updatedAt, iconData];
}
