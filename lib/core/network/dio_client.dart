import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:field_tracker/core/constants/app_constants.dart';
import 'package:field_tracker/core/network/auth_interceptor.dart';
import 'package:field_tracker/core/network/connectivity_interceptor.dart';
import 'package:field_tracker/core/network/logging_interceptor.dart';
import 'package:field_tracker/core/storage/secure_storage_service.dart';
import 'package:field_tracker/core/network/network_info.dart';

/// Configured [Dio] wrapper used throughout the app.
///
/// Interceptor chain (in order):
///   1. [ConnectivityInterceptor] — fail fast when offline (no socket opened)
///   2. [AuthInterceptor]        — attach token; handle 401 refresh + retry
///   3. [LoggingInterceptor]     — debug-only curl-style logging
class DioClient {
  late final Dio dio;

  DioClient({
    required SecureStorageService secureStorage,
    required NetworkInfo networkInfo,
  }) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.fieldtrack.app';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          seconds: AppConstants.connectionTimeoutSeconds,
        ),
        receiveTimeout: const Duration(
          seconds: AppConstants.receiveTimeoutSeconds,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(
        secureStorage: secureStorage,
        baseUrl: baseUrl,
      ),
      LoggingInterceptor(),
    ]);
  }
}
