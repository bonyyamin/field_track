import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:field_tracker/core/constants/app_constants.dart';

/// Single source of truth for reading/writing auth tokens securely.
/// Only this class should ever touch flutter_secure_storage for token data.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  // ── Tokens ──────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.secureKeyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.secureKeyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.secureKeyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.secureKeyRefreshToken);

  // ── User data ────────────────────────────────────────────────────────────

  Future<void> saveUserId(String userId) =>
      _storage.write(key: AppConstants.secureKeyUserId, value: userId);

  Future<String?> getUserId() =>
      _storage.read(key: AppConstants.secureKeyUserId);

  Future<void> saveUserData(String jsonString) =>
      _storage.write(key: AppConstants.secureKeyUserData, value: jsonString);

  Future<String?> getUserData() =>
      _storage.read(key: AppConstants.secureKeyUserData);

  // ── Session ──────────────────────────────────────────────────────────────

  /// Returns true only when a non-null access token is present.
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Wipes all secured storage — call on logout.
  Future<void> clearAll() => _storage.deleteAll();
}
