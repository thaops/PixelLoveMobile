import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/{{feature_name}}/data/datasources/remote/{{feature_name}}_remote_datasource.dart';
import 'package:pixel_love/features/{{feature_name}}/data/repository_impl/{{feature_name}}_repository_impl.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/usecases/get_{{model_name}}_list_usecase.dart';
import 'package:pixel_love/features/{{feature_name}}/presentation/controller/{{feature_name}}_controller.dart';

class {{feature_name.pascalCase()}}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<{{feature_name.pascalCase()}}RemoteDataSource>(
      () => {{feature_name.pascalCase()}}RemoteDataSourceImpl(
        dioApi: Get.find<DioApi>(),
      ),
    );

    Get.lazyPut<{{feature_name.pascalCase()}}Repository>(
      () => {{feature_name.pascalCase()}}RepositoryImpl(
        remoteDataSource: Get.find<{{feature_name.pascalCase()}}RemoteDataSource>(),
      ),
    );

    Get.lazyPut<Get{{model_name.pascalCase()}}ListUsecase>(
      () => Get{{model_name.pascalCase()}}ListUsecase(
        repository: Get.find<{{feature_name.pascalCase()}}Repository>(),
      ),
    );

    Get.lazyPut<{{feature_name.pascalCase()}}Controller>(
      () => {{feature_name.pascalCase()}}Controller(
        get{{model_name.pascalCase()}}ListUsecase: Get.find<Get{{model_name.pascalCase()}}ListUsecase>(),
      ),
    );
  }
}

