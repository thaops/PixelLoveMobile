import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AuthInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read<String>('access_token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.remove('access_token');
    }
    super.onError(err, handler);
  }
}
