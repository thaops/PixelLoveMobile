import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';

/// Repository interface cho Pet Image feature
abstract class PetImageRepository {
  /// Lấy danh sách ảnh đã gửi cho pet
  /// 
  /// [page]: Số trang (bắt đầu từ 1)
  /// [limit]: Số item mỗi trang
  /// 
  /// Returns: ApiResult với tuple (List<PetImage>, total)
  Future<ApiResult<({List<PetImage> items, int total})>> getPetImages({
    int page = 1,
    int limit = 20,
  });

  /// Gửi ảnh cho pet
  /// 
  /// [imageUrl]: URL ảnh đã upload lên Cloudinary
  /// [takenAt]: Thời điểm chụp ảnh (optional)
  /// [text]: Caption (optional)
  /// 
  /// Returns: ApiResult với tuple (expAdded, bonus, levelUp, actionId)
  Future<ApiResult<({
    int expAdded,
    int bonus,
    bool levelUp,
    String actionId,
  })>> sendImageToPet({
    required String imageUrl,
    DateTime? takenAt,
    String? text,
  });
}

