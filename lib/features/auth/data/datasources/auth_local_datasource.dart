import 'dart:convert';

import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/features/auth/data/model/auth_response_model.dart';
import 'package:field_tracker/features/auth/data/model/user_model.dart';

/// Manages persisting & reading the auth session from secure/local storage.
///
/// Responsibilities:
///   - Cache access/refresh tokens via [SecureStorageService].
///   - Cache the serialised [UserModel] to avoid a network round-trip on cold start.
///   - Clear everything on logout.
class AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  const AuthLocalDataSource(this._secureStorage);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persists tokens + user data after a successful login/register.
  Future<void> cacheSession(AuthResponseModel response) async {
    await _secureStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _secureStorage.saveUserId(response.user.id);
    await _secureStorage.saveUserData(jsonEncode(response.user.toJson()));
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the cached [UserModel] or `null` if no session exists.
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = await _secureStorage.getUserData();
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Returns `true` when a non-empty access token is stored.
  Future<bool> hasValidSession() => _secureStorage.hasValidSession();

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Wipes all stored auth data (called on logout).
  Future<void> clearSession() => _secureStorage.clearAll();
}