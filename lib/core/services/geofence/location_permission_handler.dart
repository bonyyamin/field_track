import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a location permission request.
enum LocationPermissionResult {
  /// Both foreground (and background on Android) permissions granted.
  granted,

  /// Permission denied; the user may be asked again.
  denied,

  /// Permission permanently denied; only settings page can re-enable.
  permanentlyDenied,
}

/// Handles the multi-step location permission flow.
///
/// On Android this requests:
///   1. `ACCESS_FINE_LOCATION` (foreground) via `geolocator`.
///   2. `ACCESS_BACKGROUND_LOCATION` (background) via `permission_handler`.
///
/// On iOS a single `requestPermission()` covers both foreground and the
/// "Always" background option which the user selects in Settings.
class LocationPermissionHandler {
  /// Checks the current permission state and, if necessary, requests
  /// foreground then background location access.
  ///
  /// Returns a [LocationPermissionResult] describing the outcome.
  Future<LocationPermissionResult> requestPermissions() async {
    // ── Step 1: Check current foreground permission ──────────────────────
    LocationPermission status = await Geolocator.checkPermission();

    // ── Step 2: Request foreground permission if not yet granted ─────────
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }

    // ── Step 3: Handle permanently denied state ──────────────────────────
    if (status == LocationPermission.deniedForever) {
      return LocationPermissionResult.permanentlyDenied;
    }

    // ── Step 4: Request background permission on Android ─────────────────
    // `ACCESS_BACKGROUND_LOCATION` is a separate permission on Android 10+.
    // On iOS the user upgrades to "Always" from Settings; geolocator
    // exposes `LocationPermission.always` for this.
    if (Platform.isAndroid) {
      final bgStatus = await Permission.locationAlways.status;
      if (!bgStatus.isGranted) {
        await Permission.locationAlways.request();
      }
    }

    // ── Step 5: Evaluate final result ────────────────────────────────────
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      return LocationPermissionResult.granted;
    }

    return LocationPermissionResult.denied;
  }

  /// Opens the device settings app so the user can manually change the
  /// location permission when it is permanently denied.
  Future<void> openSettings() => Geolocator.openLocationSettings();
}
