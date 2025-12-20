import 'package:dio/dio.dart';

/// Error Interceptor - Handles HTTP errors
/// Note: Navigation on 401 will be handled at UI layer via ref.listen
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log 401 errors - navigation will be handled at UI layer
    if (err.response?.statusCode == 401) {
      print('⚠️ 401 Unauthorized - User needs to login');
      // Navigation will be handled by AuthNotifier or StartupNotifier
    }

    super.onError(err, handler);
  }
}
