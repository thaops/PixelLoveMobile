import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:pixel_love/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:pixel_love/features/pet/domain/repositories/pet_repository.dart';
import 'package:pixel_love/features/pet/domain/usecases/feed_pet_usecase.dart';
import 'package:pixel_love/features/pet/domain/usecases/get_pet_status_usecase.dart';
import 'package:pixel_love/features/pet/presentation/controllers/pet_controller.dart';

class PetBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();

    Get.lazyPut<PetRemoteDataSource>(
      () => PetRemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<PetRepository>(
      () => PetRepositoryImpl(Get.find<PetRemoteDataSource>()),
    );

    Get.lazyPut(() => GetPetStatusUseCase(Get.find<PetRepository>()));
    Get.lazyPut(() => FeedPetUseCase(Get.find<PetRepository>()));

    Get.lazyPut(
      () => PetController(
        Get.find<GetPetStatusUseCase>(),
        Get.find<FeedPetUseCase>(),
      ),
    );
  }
}
