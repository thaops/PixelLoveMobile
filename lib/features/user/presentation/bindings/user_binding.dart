import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/user/data/datasources/user_remote_datasource.dart';
import 'package:pixel_love/features/user/data/repositories/user_repository_impl.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';
import 'package:pixel_love/features/user/domain/usecases/complete_profile_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/onboard_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/update_profile_usecase.dart';
import 'package:pixel_love/features/user/presentation/controllers/user_controller.dart';
import 'package:pixel_love/features/user/presentation/controllers/onboard_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();
    final storageService = Get.find<StorageService>();

    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(dioApi));

    Get.lazyPut<UserRepository>(
      () =>
          UserRepositoryImpl(Get.find<UserRemoteDataSource>(), storageService),
    );

    Get.lazyPut(() => CompleteProfileUseCase(Get.find<UserRepository>()));
    Get.lazyPut(() => OnboardUseCase(Get.find<UserRepository>()));
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<UserRepository>()));

    Get.lazyPut(
      () => UserController(
        Get.find<CompleteProfileUseCase>(),
        Get.find<UpdateProfileUseCase>(),
        storageService,
      ),
    );

    Get.lazyPut(
      () => OnboardController(
        Get.find<OnboardUseCase>(),
      ),
    );
  }
}
