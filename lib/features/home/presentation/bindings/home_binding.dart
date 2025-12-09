import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pixel_love/features/home/data/repositories/home_repository_impl.dart';
import 'package:pixel_love/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_love/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:pixel_love/features/home/presentation/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();
    final storageService = Get.find<StorageService>();

    Get.lazyPut<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(Get.find<HomeRemoteDataSource>()),
    );

    Get.lazyPut(() => GetHomeDataUseCase(Get.find<HomeRepository>()));

    Get.lazyPut(
      () => HomeController(
        Get.find<GetHomeDataUseCase>(),
        storageService,
      ),
    );
  }
}

