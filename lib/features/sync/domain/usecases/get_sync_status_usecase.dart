import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/features/todos/domain/repositories/todo_repository.dart';
import '../entities/pending_change_display_item.dart';

class SyncStatusSnapshot extends Equatable {
  final List<PendingChangeDisplayItem> pendingChanges;
  final DateTime? lastSyncedAt;
  final bool isOffline;

  const SyncStatusSnapshot({
    required this.pendingChanges,
    this.lastSyncedAt,
    required this.isOffline,
  });

  @override
  List<Object?> get props => [pendingChanges, lastSyncedAt, isOffline];
}

class GetSyncStatusUseCase {
  final TodoRepository todoRepository;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  const GetSyncStatusUseCase({
    required this.todoRepository,
    required this.secureStorage,
    required this.networkInfo,
  });

  Future<SyncStatusSnapshot> call() async {
    final isOnline = await networkInfo.isConnected;
    final lastSyncedAt = await secureStorage.getLastSyncedAt();
    final rawPending = await todoRepository.getPendingChanges();

    // Fetch todos to enrich pending items with title & icons
    final todosResult = await todoRepository.getTodos();
    final todosMap = <String, String>{};
    todosResult.fold((_) {}, (todos) {
      for (final t in todos) {
        todosMap[t.id] = t.title;
      }
    });

    final displayItems = rawPending.map((p) {
      final title = todosMap[p.todoId] ?? _getFallbackTitle(p.todoId);
      final icon = _getIconForTitle(title);

      return PendingChangeDisplayItem(
        todoId: p.todoId,
        title: title,
        isCompleted: p.isCompleted,
        updatedAt: p.updatedAt,
        iconData: icon,
      );
    }).toList();

    return SyncStatusSnapshot(
      pendingChanges: displayItems,
      lastSyncedAt: lastSyncedAt,
      isOffline: !isOnline,
    );
  }

  String _getFallbackTitle(String id) {
    if (id == '1') return 'Take inventory count';
    if (id == '2') return 'Visit branch manager';
    if (id == '3') return 'Verify delivery shipment';
    if (id == '4') return 'Update store display';
    if (id == '5') return 'Submit daily report';
    return 'Task #$id';
  }

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('inventory') || lower.contains('count') || lower.contains('stock')) {
      return Icons.inventory_2_outlined;
    }
    if (lower.contains('manager') || lower.contains('report') || lower.contains('document') || lower.contains('shipment')) {
      return Icons.description_outlined;
    }
    if (lower.contains('store') || lower.contains('display') || lower.contains('branch') || lower.contains('visit') || lower.contains('location')) {
      return Icons.location_on_outlined;
    }
    return Icons.assignment_outlined;
  }
}