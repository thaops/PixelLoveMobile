import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/feature/{{feature_name}}/data/models/{{model_name}}_dto.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/models/{{model_name}}.dart';

abstract class {{feature_name.pascalCase()}}RemoteDataSource {
  Future<ApiResult<List<{{model_name.pascalCase()}}>>> get{{model_name.pascalCase()}}List();
}

class {{feature_name.pascalCase()}}RemoteDataSourceImpl
    implements {{feature_name.pascalCase()}}RemoteDataSource {
  final DioApi dioApi;
  final String basePath = '/api/{{feature_name}}';

  {{feature_name.pascalCase()}}RemoteDataSourceImpl({required this.dioApi});

  @override
  Future<ApiResult<List<{{model_name.pascalCase()}}>>> get{{model_name.pascalCase()}}List() async {
    try {
      final response = await dioApi.get(basePath);
      final parsed = ApiResponseHandler.handleListResponse<{{model_name.pascalCase()}}Dto>(
        response,
        (json) => {{model_name.pascalCase()}}Dto.fromJson(json),
      );
      if (parsed.isSuccess && parsed.data != null) {
        final data = parsed.data!.map((dto) => dto.toDomain()).toList();
        return ApiResult.success(data);
      }
      return ApiResult.error(parsed.error ?? 'get{{model_name.pascalCase()}}List failed');
    } catch (e) {
      return ApiResult.error('get{{model_name.pascalCase()}}List failed: $e');
    }
  }
}

