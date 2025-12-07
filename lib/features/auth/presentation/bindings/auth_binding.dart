import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pixel_love/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pixel_love/features/auth/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();
    final storage = Get.find<GetStorage>();
    final storageService = Get.find<StorageService>();

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        Get.find<AuthRemoteDataSource>(),
        storage,
      ),
    );

    Get.lazyPut(() => LoginGoogleUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => GetMeUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<AuthRepository>()));

    Get.lazyPut(
      () => AuthController(
        Get.find<LoginGoogleUseCase>(),
        Get.find<GetMeUseCase>(),
        Get.find<LogoutUseCase>(),
        storageService,
      ),
    );
  }
}
