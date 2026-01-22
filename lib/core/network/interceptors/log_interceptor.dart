import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class CustomLogInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120, // Increased line length for better readability
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String dataLog = '';
    if (options.data != null) {
      try {
        if (options.data is Map || options.data is List) {
          dataLog = const JsonEncoder.withIndent('  ').convert(options.data);
        } else {
          dataLog = options.data.toString();
        }
      } catch (e) {
        dataLog = options.data.toString();
      }
    }

    _logger.i(
      '→ ${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Data: $dataLog',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String dataLog = '';
    if (response.data != null) {
      try {
        if (response.data is Map || response.data is List) {
          dataLog = const JsonEncoder.withIndent('  ').convert(response.data);
        } else {
          dataLog = response.data.toString();
        }
      } catch (e) {
        dataLog = response.data.toString();
      }
    }

    _logger.i(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      'Data: $dataLog',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String dataLog = '';
    if (err.response?.data != null) {
      try {
        if (err.response?.data is Map || err.response?.data is List) {
          dataLog = const JsonEncoder.withIndent(
            '  ',
          ).convert(err.response?.data);
        } else {
          dataLog = err.response?.data.toString() ?? '';
        }
      } catch (e) {
        dataLog = err.response?.data.toString() ?? '';
      }
    }

    _logger.e(
      '⚠ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'Error: ${err.message}\n'
      'Response: $dataLog',
    );
    super.onError(err, handler);
  }
}
