import 'package:pixel_love/common/utils/api_response_handler.dart';
import 'package:pixel_love/feature/{{feature_name}}/data/datasources/remote/{{feature_name}}_remote_datasource.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/models/{{model_name}}.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';

class {{feature_name.pascalCase()}}RepositoryImpl implements {{feature_name.pascalCase()}}Repository {
  final {{feature_name.pascalCase()}}RemoteDataSource remoteDataSource;

  {{feature_name.pascalCase()}}RepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<ApiResult<List<{{model_name.pascalCase()}}>>> get{{model_name.pascalCase()}}List() async {
    return await remoteDataSource.get{{model_name.pascalCase()}}List();
  }
}

