import 'package:pixel_love/common/utils/api_response_handler.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/models/{{model_name}}.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';

class Get{{model_name.pascalCase()}}ListUsecase {
  final {{feature_name.pascalCase()}}Repository repository;

  Get{{model_name.pascalCase()}}ListUsecase({required this.repository});

  Future<ApiResult<List<{{model_name.pascalCase()}}>>> call() async {
    return await repository.get{{model_name.pascalCase()}}List();
  }
}

