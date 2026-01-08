import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/fridge/data/models/create_note_request.dart';
import 'package:pixel_love/features/fridge/data/models/fridge_dto.dart';

abstract class FridgeRemoteDataSource {
  Future<ApiResult<FridgeDto>> getFridgeData();
  Future<ApiResult<void>> createNote(CreateNoteRequest request);
}

class FridgeRemoteDataSourceImpl implements FridgeRemoteDataSource {
  final DioApi _dioApi;

  FridgeRemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<FridgeDto>> getFridgeData() async {
    return await _dioApi.get(
      '/fridge/home',
      fromJson: (json) => FridgeDto.fromJson(json),
    );
  }

  @override
  Future<ApiResult<void>> createNote(CreateNoteRequest request) async {
    return await _dioApi.post(
      '/fridge/note',
      data: request.toJson(),
      fromJson: (_) => null, // API trả về void
    );
  }
}
