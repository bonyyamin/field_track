import 'package:dio/dio.dart';
import 'package:field_tracker/core/network/network_info.dart';

/// Fails requests early (before any socket attempt) when the device is
/// offline.
///
/// This lets the repository's catch-block detect [DioExceptionType.connectionError]
/// and immediately route the write to the local queue, without waiting for
/// a 30-second connection timeout.
class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;

  ConnectivityInterceptor(this._networkInfo);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      return handler.reject(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: options,
          message: 'No internet connection. Request cancelled.',
        ),
      );
    }
    handler.next(options);
  }
}
