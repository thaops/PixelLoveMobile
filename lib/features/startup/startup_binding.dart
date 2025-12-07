import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pixel_love/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:pixel_love/features/startup/startup_controller.dart';

class StartupBinding implements Bindings {
  @override
  void dependencies() {
    // Inject dependencies in order
    final dioApi = Get.find<DioApi>();
    final storage = Get.find<GetStorage>();
    final storageService = Get.find<StorageService>();

    // Auth Remote DataSource
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dioApi));
    }

    // Auth Repository
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>(), storage),
      );
    }

    // Get Me UseCase
    Get.lazyPut<GetMeUseCase>(() => GetMeUseCase(Get.find<AuthRepository>()));

    // Startup Controller
    Get.lazyPut<StartupController>(
      () => StartupController(storageService, Get.find<GetMeUseCase>()),
    );
  }
}
