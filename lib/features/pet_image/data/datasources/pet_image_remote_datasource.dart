import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet_image/data/models/pet_image_list_response_dto.dart';
import 'package:pixel_love/features/pet_image/data/models/send_image_to_pet_response_dto.dart';

abstract class PetImageRemoteDataSource {
  /// Lấy danh sách ảnh đã gửi cho pet
  Future<ApiResult<PetImageListResponseDto>> getPetImages({
    int page = 1,
    int limit = 20,
  });

  /// Gửi ảnh cho pet (sau khi đã upload lên Cloudinary)
  Future<ApiResult<SendImageToPetResponseDto>> sendImageToPet({
    required String imageUrl,
    String? takenAt, // ISO string, optional
    String? text, // Caption, optional
  });
}

class PetImageRemoteDataSourceImpl implements PetImageRemoteDataSource {
  final DioApi _dioApi;

  PetImageRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<PetImageListResponseDto>> getPetImages({
    int page = 1,
    int limit = 20,
  }) async {
    return await _dioApi.get(
      '/pet/images',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => PetImageListResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<SendImageToPetResponseDto>> sendImageToPet({
    required String imageUrl,
    String? takenAt,
    String? text,
  }) async {
    final data = <String, dynamic>{
      'imageUrl': imageUrl,
    };

    if (takenAt != null) {
      data['takenAt'] = takenAt;
    }

    if (text != null && text.isNotEmpty) {
      data['text'] = text;
    }

    return await _dioApi.post(
      '/pet/image',
      data: data,
      fromJson: (json) => SendImageToPetResponseDto.fromJson(json),
    );
  }
}

