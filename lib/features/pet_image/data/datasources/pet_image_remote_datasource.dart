import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/pet_image/data/models/pet_image_dto.dart';
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

  Future<ApiResult<bool>> sendReaction({
    required String imageId,
    required String emoji,
    required int count,
  });

  /// Lấy chi tiết một ảnh (bao gồm đầy đủ reactions mới nhất)
  Future<ApiResult<PetImageDto>> getPetImageDetails(String imageId);
}

class PetImageRemoteDataSourceImpl implements PetImageRemoteDataSource {
  final DioApi _dioApi;

  PetImageRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<PetImageDto>> getPetImageDetails(String imageId) async {
    return await _dioApi.get(
      '/pet/images/$imageId',
      fromJson: (json) => PetImageDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<PetImageListResponseDto>> getPetImages({
    int page = 1,
    int limit = 20,
  }) async {
    return await _dioApi.get(
      '/pet/images',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => PetImageListResponseDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<SendImageToPetResponseDto>> sendImageToPet({
    required String imageUrl,
    String? takenAt,
    String? text,
  }) async {
    final data = <String, dynamic>{'imageUrl': imageUrl};

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

  @override
  Future<ApiResult<bool>> sendReaction({
    required String imageId,
    required String emoji,
    required int count,
  }) async {
    return await _dioApi.post(
      '/pet/images/$imageId/reactions',
      data: {'emoji': emoji, 'count': count},
      fromJson: (json) => json['success'] as bool? ?? true,
    );
  }
}
