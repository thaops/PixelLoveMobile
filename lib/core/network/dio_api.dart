import 'package:dio/dio.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/errors/failure.dart';
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/interceptors/auth_interceptor.dart';
import 'package:pixel_love/core/network/interceptors/error_interceptor.dart';
import 'package:pixel_love/core/network/interceptors/log_interceptor.dart';
import 'package:pixel_love/core/services/storage_service.dart';

class DioApi {
  late final Dio _dio;

  DioApi(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_storageService),
      CustomLogInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  final StorageService _storageService;

  Dio get dio => _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return ApiResult.success(fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return ApiResult.success(fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return ApiResult.success(fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return ApiResult.success(fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Handle message có thể là string hoặc array
        String message;
        if (responseData is Map) {
          final msg = responseData['message'];
          if (msg is List) {
            message = msg.join(', '); // Join array thành string
          } else {
            message =
                msg?.toString() ??
                error.response?.statusMessage ??
                'Server error occurred';
          }
        } else {
          message = error.response?.statusMessage ?? 'Server error occurred';
        }

        if (statusCode == 401) {
          return UnauthorizedFailure(message: message);
        } else if (statusCode == 400) {
          return ValidationFailure(message: message);
        } else {
          return ServerFailure(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Request cancelled');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'No internet connection. Please check your network.',
        );

      default:
        return ServerFailure(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }
}
