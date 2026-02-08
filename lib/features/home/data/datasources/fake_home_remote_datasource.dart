import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';

class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  @override
  Future<ApiResult<HomeDto>> getHomeData() async {
    final fakeData = {
      "background": {
        "imageUrl":
            "https://res.cloudinary.com/dukoun1pb/image/upload/v1769238533/background_ch%C3%ADnh_1_ckajnj.png",
        "width": 4096,
        "height": 1920,
      },
      "objects": [

        {
          "id": "streakImage",
          "type": "streakImage",
          "imageUrl":      "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517706/khung_treo_%C4%91e%CC%82%CC%81m_nga%CC%80y__chuo%CC%82%CC%83i_sggk7c.png",
          "x": 1800,
          "y": 130,
          "width": 500,
          "height": 500,
          "zIndex": 10,
        },
          {
          "id": "streakStatus",
          "type": "streakStatus",
          "imageUrl":      "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517747/chuo%CC%82%CC%83i_lo%CC%9B%CC%81n_kcjx3p.png",
          "x": 1925,
          "y": 350,
          "width": 250,
          "height": 250,
          "zIndex": 10,
        },
    
        {
          "id": "boy",
          "type": "boy",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1769093371/nh%C3%A2n_v%E1%BA%ADt_nam_ho5t0v.png",
          "x": 1500,
          "y": 860,
          "width": 780,
          "height": 780,
          "zIndex": 10,
        },
        {
          "id": "girl",
          "type": "girl",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1769093376/nh%C3%A2n_v%E1%BA%ADt_n%E1%BB%AF_rfv3bf.png",
          "x": 1850,
          "y": 930,
          "width": 700,
          "height": 700,
          "zIndex": 10,
        },
        {
          "id": "pet",
          "type": "pet",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1770517831/pet_level_1_aav3jk.png",
          "x": 970,
          "y": 730,
          "width": 600,
          "height": 600,
          "zIndex": 10,
        },
        {
          "id": "kennel",
          "type": "kennel",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1769922743/chu%E1%BB%93ng_c%C3%BAn_1_ud7yws.png",
          "x": 640,
          "y": 830,
          "width": 400,
          "height": 400,
          "zIndex": 10,
        },
        {
          "id": "radio",
          "type": "radio",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1767853620/image-removebg-preview_9_nnrmzi.png",
          "x": 1280,
          "y": 1320,
          "width": 300,
          "height": 300,
          "zIndex": 10,
        },
        {
          "id": "fridge",
          "type": "fridge",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1769238640/t%E1%BB%A7_l%E1%BA%A1nh_vizsfo.png",
          "x": 2520,
          "y": 320,
          "width": 800,
          "height": 1100,
          "zIndex": 10,
        },
        {
          "id": "img-couple",
          "type": "img-couple",
          "imageUrl":
              "https://res.cloudinary.com/dukoun1pb/image/upload/v1767419512/t%E1%BA%A3i_xu%E1%BB%91ng_ofgtla.png",
          "x": 1100,
          "y": 100,
          "width": 300,
          "height": 300,
          "zIndex": 10,
        },
      ],
      "petStatus": {
        "level": 1,
        "exp": 15,
        "nextLevelExp": 485,
        "recentImages": [],
      },
    };

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return ApiResult.success(HomeDto.fromJson(fakeData));
  }
}
