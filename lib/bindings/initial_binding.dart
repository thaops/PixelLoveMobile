import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/socket_service.dart';
import 'package:pixel_love/core/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = GetStorage();
    
    Get.put<DioApi>(DioApi(), permanent: true);
    Get.put<GetStorage>(storage, permanent: true);
    
    final storageService = StorageService(storage);
    Get.put<StorageService>(storageService, permanent: true);
    
    Get.put<SocketService>(SocketService(storageService), permanent: true);
  }
}
