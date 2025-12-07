import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/socket_service.dart';
import 'package:pixel_love/features/couple/data/datasources/couple_remote_datasource.dart';
import 'package:pixel_love/features/couple/data/repositories/couple_repository_impl.dart';
import 'package:pixel_love/features/couple/domain/repositories/couple_repository.dart';
import 'package:pixel_love/features/couple/domain/usecases/create_code_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/pair_couple_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/preview_code_usecase.dart';
import 'package:pixel_love/features/couple/presentation/controllers/couple_connection_controller.dart';

class CoupleBinding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();
    final socketService = Get.find<SocketService>();

    Get.lazyPut<CoupleRemoteDataSource>(
      () => CoupleRemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<CoupleRepository>(
      () => CoupleRepositoryImpl(Get.find<CoupleRemoteDataSource>()),
    );

    Get.lazyPut(() => CreateCodeUseCase(Get.find<CoupleRepository>()));
    Get.lazyPut(() => PreviewCodeUseCase(Get.find<CoupleRepository>()));
    Get.lazyPut(() => PairCoupleUseCase(Get.find<CoupleRepository>()));

    Get.lazyPut(
      () => CoupleConnectionController(
        Get.find<CreateCodeUseCase>(),
        Get.find<PreviewCodeUseCase>(),
        Get.find<PairCoupleUseCase>(),
        socketService,
      ),
    );
  }
}

