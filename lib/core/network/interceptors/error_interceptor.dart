import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:pixel_love/routes/app_routes.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      getx.Get.offAllNamed(AppRoutes.login);
    }

    super.onError(err, handler);
  }
}
