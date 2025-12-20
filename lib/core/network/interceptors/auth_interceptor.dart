import 'package:dio/dio.dart';
import 'package:pixel_love/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('🚨 [AuthInterceptor] 401 Unauthorized - removing token');
      print('   - Request URL: ${err.requestOptions.uri}');
      _storageService.removeToken();
    }
    super.onError(err, handler);
  }
}
