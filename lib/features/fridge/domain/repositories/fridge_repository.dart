import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';

abstract class FridgeRepository {
  Future<ApiResult<Fridge>> getFridgeData();
  Future<ApiResult<void>> createNote(String content);
}

