import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request / response / error logger.
///
/// Prints curl-style summaries so you can quickly reproduce calls in a
/// terminal.  Nothing is printed in release builds — `kDebugMode` is a
/// compile-time constant, so the dead branch is tree-shaken.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('┌── REQUEST ──────────────────────────────');
      buffer.writeln('│ ${options.method.toUpperCase()} ${options.uri}');
      if (options.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        options.headers.forEach(
          (k, v) => buffer.writeln('│   $k: $v'),
        );
      }
      if (options.data != null) {
        buffer.writeln('│ Body: ${options.data}');
      }
      buffer.write('└─────────────────────────────────────────');
      debugPrint(buffer.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('┌── RESPONSE ─────────────────────────────');
      buffer.writeln(
        '│ ${response.statusCode} ${response.requestOptions.uri}',
      );
      buffer.writeln('│ Data: ${response.data}');
      buffer.write('└─────────────────────────────────────────');
      debugPrint(buffer.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('┌── ERROR ────────────────────────────────');
      buffer.writeln('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      buffer.writeln('│ Type   : ${err.type}');
      buffer.writeln('│ Status : ${err.response?.statusCode}');
      buffer.writeln('│ Message: ${err.message}');
      if (err.response?.data != null) {
        buffer.writeln('│ Body   : ${err.response?.data}');
      }
      buffer.write('└─────────────────────────────────────────');
      debugPrint(buffer.toString());
    }
    handler.next(err);
  }
}
