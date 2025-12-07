import 'package:get/get.dart';
import 'package:pixel_love/common/base/base_controller.dart';
import 'package:pixel_love/common/mixins/api_result_mixin.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/models/{{model_name}}.dart';
import 'package:pixel_love/feature/{{feature_name}}/domain/usecases/get_{{model_name}}_list_usecase.dart';

class {{feature_name.pascalCase()}}Controller extends BaseController with ApiResultMixin {
  final Get{{model_name.pascalCase()}}ListUsecase get{{model_name.pascalCase()}}ListUsecase;

  final RxList<{{model_name.pascalCase()}}> {{model_name.camelCase()}}List = <{{model_name.pascalCase()}}>[].obs;

  {{feature_name.pascalCase()}}Controller({
    required this.get{{model_name.pascalCase()}}ListUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    // TODO: Load data
  }

  Future<void> load{{model_name.pascalCase()}}List() async {
    // TODO: Implement
    await handleApiCall<List<{{model_name.pascalCase()}}>>(
      apiCall: () => get{{model_name.pascalCase()}}ListUsecase.call(),
      onSuccess: (data) {
        {{model_name.camelCase()}}List.assignAll(data);
      },
    );
  }

  Future<void> onRefresh() async {
    await load{{model_name.pascalCase()}}List();
  }
}

