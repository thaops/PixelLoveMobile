import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/pet_scene/data/datasources/pet_scene_remote_datasource.dart';
import 'package:pixel_love/features/pet_scene/data/models/pet_scene_dto.dart';

class FakePetSceneRemoteDataSource implements PetSceneRemoteDataSource {
  @override
  Future<ApiResult<PetSceneDto>> getPetScene() async {
    final fakeData = {
      "background": {
        "imageUrl":
            "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517801/background_pet_ashg7f.png",
        "width": 2048,
        "height": 2048,
      },
      "objects": [
 
        {
          "id": "chari-pet",
          "type": "chari-pet",
          "imageUrl":
          "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517794/background_pet_ca%CC%81i_%C4%91e%CC%A3%CC%82m_cu%CC%89a_pet_j4w2g5.png",
          "x": 750,
          "y": 1450,
          "width": 600,
          "height": 600,
          "zIndex": 9,
        },

         {
          "id": "pet",
          "type": "pet",
          "imageUrl":
      "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517831/pet_level_1_aav3jk.png",
          "x": 720,
          "y": 1200,
          "width": 650,
          "height": 650,
          "zIndex": 11,
        },
      ],
      "petStatus": {
        "level": 1,
        "exp": 365,
        "expToNextLevel": 135,
        "todayFeedCount": 0,
        "lastFeedTime": "2026-02-07T06:10:20.900Z",
      },
    };

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return ApiResult.success(PetSceneDto.fromJson(fakeData));
  }
}
