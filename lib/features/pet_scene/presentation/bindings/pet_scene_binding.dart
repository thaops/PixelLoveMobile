import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet_scene/data/datasources/pet_scene_remote_datasource.dart';
import 'package:pixel_love/features/pet_scene/data/repositories/pet_scene_repository_impl.dart';
import 'package:pixel_love/features/pet_scene/domain/repositories/pet_scene_repository.dart';
import 'package:pixel_love/features/pet_scene/domain/usecases/get_pet_scene_usecase.dart';
import 'package:pixel_love/features/pet_scene/presentation/controllers/pet_scene_controller.dart';

class PetSceneBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();

    Get.lazyPut<PetSceneRemoteDataSource>(
      () => PetSceneRemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<PetSceneRepository>(
      () => PetSceneRepositoryImpl(Get.find<PetSceneRemoteDataSource>()),
    );

    Get.lazyPut(() => GetPetSceneUseCase(Get.find<PetSceneRepository>()));

    Get.lazyPut(() => PetSceneController(Get.find<GetPetSceneUseCase>()));
  }
}
