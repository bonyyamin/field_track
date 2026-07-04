import 'dart:async';

import 'package:dio/dio.dart';
import 'package:field_tracker/core/constants/app_constants.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';

/// Attaches Bearer tokens to every outbound request.
///
/// On 401:
/// 1. Queues the failing request.
/// 2. Calls `/auth/refresh` once (guarded by [_isRefreshing]).
/// 3. On success — saves new tokens and retries all queued requests.
/// 4. On failure — clears session tokens so the router redirects to login.
///
/// A dedicated [Dio] instance ([_tokenDio]) is used for the refresh call to
/// avoid re-entering this interceptor recursively.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  /// Bypass interceptors for token refresh so we don't loop.
  final Dio _tokenDio;

  bool _isRefreshing = false;

  /// Completers waiting for a new token; resolved/rejected together.
  final List<Completer<String>> _pendingCompleters = [];

  AuthInterceptor({
    required this._secureStorage,
    required String baseUrl,
  })  : _tokenDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Duration(seconds: AppConstants.connectionTimeoutSeconds),
            receiveTimeout: Duration(seconds: AppConstants.receiveTimeoutSeconds),
          ),
        );

  // ── onRequest ────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── onError ─────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid re-entering the refresh flow for the refresh request itself.
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _secureStorage.clearAll();
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Park this request until refresh finishes.
      final completer = Completer<String>();
      _pendingCompleters.add(completer);
      try {
        final newToken = await completer.future;
        final retried = await _retry(err.requestOptions, newToken);
        return handler.resolve(retried);
      } catch (_) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;
    try {
      final newAccessToken = await _doRefresh();
      _resolveQueue(newAccessToken);
      final retried = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retried);
    } catch (_) {
      // Refresh failed — wipe session so the router redirects to login.
      _rejectQueue();
      await _secureStorage.clearAll();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<String> _doRefresh() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token available');
    }

    final response = await _tokenDio.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final data = response.data!;
    final newAccess = data['access_token'] as String;
    final newRefresh = data['refresh_token'] as String? ?? refreshToken;

    await _secureStorage.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );

    return newAccess;
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String token,
  ) {
    options.headers['Authorization'] = 'Bearer $token';
    return _tokenDio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
      ),
    );
  }

  void _resolveQueue(String token) {
    for (final c in _pendingCompleters) {
      c.complete(token);
    }
    _pendingCompleters.clear();
  }

  void _rejectQueue() {
    for (final c in _pendingCompleters) {
      c.completeError(StateError('Token refresh failed'));
    }
    _pendingCompleters.clear();
  }
}
