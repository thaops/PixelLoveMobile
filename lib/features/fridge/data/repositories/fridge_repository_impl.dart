import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/fridge/data/datasources/fridge_remote_datasource.dart';
import 'package:pixel_love/features/fridge/data/models/create_note_request.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';
import 'package:pixel_love/features/fridge/domain/repositories/fridge_repository.dart';

class FridgeRepositoryImpl implements FridgeRepository {
  final FridgeRemoteDataSource _remoteDataSource;

  FridgeRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<Fridge>> getFridgeData() async {
    final result = await _remoteDataSource.getFridgeData();

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<void>> createNote(String content) async {
    final request = CreateNoteRequest(content: content);
    final result = await _remoteDataSource.createNote(request);

    return result.when(
      success: (_) => ApiResult.success(null),
      error: (error) => ApiResult.error(error),
    );
  }
}

