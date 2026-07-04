import 'package:equatable/equatable.dart';
import '../../domain/entities/pending_change_display_item.dart';

class SyncState extends Equatable {
  final bool isOffline;
  final bool isSyncing;
  final List<PendingChangeDisplayItem> pendingChanges;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final String? successMessage;

  const SyncState({
    required this.isOffline,
    this.isSyncing = false,
    this.pendingChanges = const [],
    this.lastSyncedAt,
    this.errorMessage,
    this.successMessage,
  });

  factory SyncState.initial() => const SyncState(
        isOffline: false,
        isSyncing: false,
        pendingChanges: [],
      );

  SyncState copyWith({
    bool? isOffline,
    bool? isSyncing,
    List<PendingChangeDisplayItem>? pendingChanges,
    DateTime? lastSyncedAt,
    String? errorMessage,
    String? successMessage,
  }) {
    return SyncState(
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isOffline,
        isSyncing,
        pendingChanges,
        lastSyncedAt,
        errorMessage,
        successMessage,
      ];
}