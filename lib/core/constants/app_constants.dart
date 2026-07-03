/// Application-wide constants including storage keys, background task configs, and channel IDs.
abstract final class AppConstants {
  // Application details
  static const String appName = 'FieldTrack';

  // Secure Storage Keys
  static const String secureKeyAccessToken = 'access_token';
  static const String secureKeyRefreshToken = 'refresh_token';
  static const String secureKeyUserId = 'user_id';
  static const String secureKeyUserData = 'user_data';

  // Shared Preferences Keys
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyLastSyncTime = 'last_sync_time';

  // Notification Channel IDs
  static const String notificationChannelId = 'geofence_channel';
  static const String notificationChannelName = 'Geofence Alerts';
  static const String notificationChannelDescription =
      'Notifications for location entry and exit events';

  // Geofence & Location Constants
  static const int geofenceCheckIntervalMinutes = 15; // Android WorkManager minimum background interval
  static const double geofenceHysteresisMeters = 10.0; // Avoid boundary flicker
  static const double defaultGeofenceRadiusMeters = 100.0;

  // Network & Sync Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int autoSyncIntervalMinutes = 5;
}