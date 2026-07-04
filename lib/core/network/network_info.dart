import 'package:connectivity_plus/connectivity_plus.dart';

/// Single source of truth for online/offline status.
///
/// - [isConnected] performs an instant connectivity check.
/// - [onStatusChange] emits `true` when online, `false` when offline.
///   Consumed by SyncBloc to trigger automatic pending-changes upload.
class NetworkInfo {
  final Connectivity _connectivity;

  const NetworkInfo(this._connectivity);

  /// Returns `true` if at least one connectivity result is available
  /// (wifi, mobile data, ethernet …).
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream that emits `true` when online and `false` when offline.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
}