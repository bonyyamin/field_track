import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles notification permission requests for both Android and iOS.
///
/// - **Android 13+ (API 33+)**: Requires `POST_NOTIFICATIONS` at runtime.
/// - **Android < 13**: Notifications are granted implicitly; returns `true`.
/// - **iOS**: Requests alert, badge, and sound permissions via the
///   `flutter_local_notifications` iOS resolver.
class NotificationPermissionHandler {
  final FlutterLocalNotificationsPlugin _plugin;

  const NotificationPermissionHandler(this._plugin);

  // ── Public API ──────────────────────────────────────────────────────────

  /// Requests notification permission and returns `true` if granted.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return _requestAndroidPermission();
    } else if (Platform.isIOS) {
      return _requestIosPermission();
    }
    // Other platforms (desktop, web) — assume granted.
    return true;
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  /// Android: On API 33+ use `permission_handler`; below that notifications
  /// are always allowed so we just return `true`.
  Future<bool> _requestAndroidPermission() async {
    // The `POST_NOTIFICATIONS` permission was introduced in Android 13 (API 33).
    // On older versions notifications are implicitly granted.
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// iOS: Request alert, badge, and sound through the local notifications plugin.
  Future<bool> _requestIosPermission() async {
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl == null) return false;

    final granted = await iosImpl.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }
}
