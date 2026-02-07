import 'package:pixel_love/core/errors/failure.dart';

class ApiResult<T> {
  final T? data;
  final Failure? error;
  final bool isSuccess;

  const ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.error(Failure error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure error) error,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return error(this.error!);
    }
  }
}
