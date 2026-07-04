import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:field_tracker/core/constants/app_constants.dart';

/// Wraps `flutter_local_notifications` to provide a simple, app-specific API.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  // ── Android channel details ─────────────────────────────────────────────

  static const _androidChannel = AndroidNotificationChannel(
    AppConstants.notificationChannelId,
    AppConstants.notificationChannelName,
    description: AppConstants.notificationChannelDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const _androidDetails = AndroidNotificationDetails(
    AppConstants.notificationChannelId,
    AppConstants.notificationChannelName,
    channelDescription: AppConstants.notificationChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    playSound: true,
    enableVibration: true,
  );

  static const _darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _darwinDetails,
  );

  // ── Initialisation ──────────────────────────────────────────────────────

  /// Initialises the plugin and creates the Android notification channel.
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(settings: initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  // ── Notification display ────────────────────────────────────────────────

  /// Shows a geofence-entry notification for [locationName].
  Future<void> showEntryNotification(String locationName) async {
    await _plugin.show(
      id: locationName.hashCode,
      title: 'Location entered',
      body: 'You entered $locationName',
      notificationDetails: _notificationDetails,
    );
  }

  /// Cancels the geofence notification for [locationName].
  Future<void> cancelEntryNotification(String locationName) async {
    await _plugin.cancel(id: locationName.hashCode);
  }
}
