import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/errors/failure.dart';
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/interceptors/auth_interceptor.dart';
import 'package:pixel_love/core/network/interceptors/error_interceptor.dart';
import 'package:pixel_love/core/services/storage_service.dart';

/// Service để upload ảnh lên Cloudinary qua backend API
/// Có thể tái sử dụng ở nhiều nơi trong app
class CloudinaryUploadService {
  late final Dio _dio;
  final StorageService _storageService;

  CloudinaryUploadService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60), // Upload có thể lâu hơn
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_storageService),
      ErrorInterceptor(),
      // Không dùng LogInterceptor cho upload để tránh log file lớn
    ]);
  }

  /// Upload file ảnh lên Cloudinary
  ///
  /// [file]: File ảnh cần upload
  ///
  /// Returns: [ApiResult<String>] với secure_url của ảnh đã upload
  Future<ApiResult<String>> uploadImage(File file) async {
    try {
      // Kiểm tra file tồn tại
      if (!await file.exists()) {
        return ApiResult.error(
          ValidationFailure(message: 'File không tồn tại'),
        );
      }

      // Kiểm tra kích thước file (tối đa 10MB)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        return ApiResult.error(
          ValidationFailure(
            message: 'File quá lớn. Vui lòng chọn ảnh nhỏ hơn 10MB',
          ),
        );
      }

      // Tạo FormData với file
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      // Upload với Content-Type multipart/form-data
      final response = await _dio.post(
        '/cloudinary/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Lấy secure_url từ response
      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return ApiResult.error(
          ServerFailure(message: 'Không nhận được URL ảnh từ server'),
        );
      }

      return ApiResult.success(secureUrl);
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Lỗi không xác định: $e'));
    }
  }

  Future<ApiResult<String>> uploadAudio(File file) async {
    try {
      if (!await file.exists()) {
        return ApiResult.error(
          ValidationFailure(message: 'File không tồn tại'),
        );
      }

      final fileSize = await file.length();
      const maxSize = 20 * 1024 * 1024;
      if (fileSize > maxSize) {
        return ApiResult.error(
          ValidationFailure(
            message: 'File quá lớn. Vui lòng chọn audio nhỏ hơn 20MB',
          ),
        );
      }

      final fileName = file.path.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType('audio', 'mpeg'),
        ),
      });

      final response = await _dio.post(
        '/cloudinary/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return ApiResult.error(
          ServerFailure(message: 'Không nhận được URL audio từ server'),
        );
      }

      return ApiResult.success(secureUrl);
    } on DioException catch (e) {
      return ApiResult.error(_handleDioError(e));
    } catch (e) {
      return ApiResult.error(ServerFailure(message: 'Lỗi không xác định: $e'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Kết nối quá lâu. Vui lòng kiểm tra kết nối mạng.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        String message;
        if (responseData is Map) {
          final msg = responseData['message'];
          if (msg is List) {
            message = msg.join(', ');
          } else {
            message =
                msg?.toString() ??
                error.response?.statusMessage ??
                'Lỗi server';
          }
        } else {
          message = error.response?.statusMessage ?? 'Lỗi server';
        }

        if (statusCode == 401) {
          return UnauthorizedFailure(message: message);
        } else if (statusCode == 400) {
          return ValidationFailure(message: message);
        } else {
          return ServerFailure(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Đã hủy upload');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
        );

      default:
        return ServerFailure(message: error.message ?? 'Lỗi không xác định');
    }
  }
}
