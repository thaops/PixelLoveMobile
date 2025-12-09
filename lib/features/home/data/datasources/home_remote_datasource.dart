import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';

abstract class HomeRemoteDataSource {
  Future<ApiResult<HomeDto>> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioApi _dioApi;

  HomeRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<HomeDto>> getHomeData() async {
    return await _dioApi.get(
      '/home',
      fromJson: (json) => HomeDto.fromJson(json),
    );
  }
}

