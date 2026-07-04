import 'package:equatable/equatable.dart';
import '../../domain/entities/pending_change_display_item.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class LoadSyncStatus extends SyncEvent {
  const LoadSyncStatus();
}

class ConnectivityChanged extends SyncEvent {
  final bool isOnline;
  const ConnectivityChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class PendingChangesUpdated extends SyncEvent {
  final List<PendingChangeDisplayItem> pendingChanges;
  const PendingChangesUpdated(this.pendingChanges);

  @override
  List<Object?> get props => [pendingChanges];
}

class ManualSyncRequested extends SyncEvent {
  const ManualSyncRequested();
}