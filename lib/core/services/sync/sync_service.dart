import 'dart:async';

import 'package:field_tracker/core/network/network_info.dart';

/// Represents the current synchronisation state exposed to the UI layer.
enum SyncStatus {
  offline,
  syncing,
  synced,
  failed,
  idle,
}

typedef SyncPendingChangesCallback = Future<bool> Function();

/// Orchestrates offline-to-online todo synchronisation.
class SyncService {
  final NetworkInfo _networkInfo;
  final SyncPendingChangesCallback _syncCallback;

  SyncService({
    required this._networkInfo,
    required this._syncCallback,
  });

  // ── Internal state ──────────────────────────────────────────────────────

  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();

  StreamSubscription<bool>? _connectivitySubscription;

  // ── Public API ──────────────────────────────────────────────────────────

  Stream<SyncStatus> get statusStream => _controller.stream;

  void start() {
    if (_connectivitySubscription != null) return;

    _connectivitySubscription = _networkInfo.onStatusChange.listen(
      (isOnline) async {
        if (isOnline) {
          _controller.add(SyncStatus.syncing);
          try {
            final success = await _syncCallback();
            _controller.add(success ? SyncStatus.synced : SyncStatus.failed);
          } catch (_) {
            _controller.add(SyncStatus.failed);
          }
        } else {
          _controller.add(SyncStatus.offline);
        }
      },
    );
  }

  Future<void> syncNow() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      _controller.add(SyncStatus.offline);
      return;
    }

    _controller.add(SyncStatus.syncing);
    try {
      final success = await _syncCallback();
      _controller.add(success ? SyncStatus.synced : SyncStatus.failed);
    } catch (_) {
      _controller.add(SyncStatus.failed);
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _controller.close();
  }
}