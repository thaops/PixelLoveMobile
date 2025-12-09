import 'package:get/get.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/domain/usecases/get_home_data_usecase.dart';

class HomeController extends GetxController {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final StorageService _storageService;

  HomeController(
    this._getHomeDataUseCase,
    this._storageService,
  );

  final _isLoading = false.obs; // Start with false (show cache immediately)
  final _errorMessage = ''.obs;
  final Rxn<Home> _homeData = Rxn<Home>();
  final _isUpdating = false.obs; // Silent update flag

  bool get isLoading => _isLoading.value;
  bool get isUpdating => _isUpdating.value;
  String get errorMessage => _errorMessage.value;
  Home? get homeData => _homeData.value;

  // Default image dimensions
  static const double defaultImageWidth = 4096.0;
  static const double defaultImageHeight = 1920.0;

  @override
  void onInit() {
    super.onInit();
    _loadFromCacheAndUpdate();
  }

  // 🚀 CACHE-FIRST STRATEGY
  void _loadFromCacheAndUpdate() {
    // Step 1: Load from cache immediately (instant)
    _loadFromCache();
    
    // Step 2: Silent update from API
    _silentUpdateFromAPI();
  }

  void _loadFromCache() {
    final cachedData = _storageService.getHomeData();
    
    if (cachedData != null) {
      try {
        final homeDto = HomeDto.fromJson(cachedData);
        _homeData.value = homeDto.toEntity();
        print('✅ Home data loaded from cache (instant)');
      } catch (e) {
        print('❌ Cache parse error: $e');
        // If cache is corrupted, show loading
        _isLoading.value = true;
      }
    } else {
      // No cache, show loading
      _isLoading.value = true;
      print('⚠️ No cache found, loading from API...');
    }
  }

  Future<void> _silentUpdateFromAPI() async {
    try {
      _isUpdating.value = true;

      final result = await _getHomeDataUseCase.call();

      result.when(
        success: (home) {
          // Update UI with new data
          _homeData.value = home;
          
          // Save to cache for next time
          final homeDto = HomeDto(
            background: BackgroundDto(
              imageUrl: home.background.imageUrl,
              width: home.background.width,
              height: home.background.height,
            ),
            objects: home.objects.map((obj) => HomeObjectDto(
              id: obj.id,
              type: obj.type,
              imageUrl: obj.imageUrl,
              x: obj.x,
              y: obj.y,
              width: obj.width,
              height: obj.height,
              zIndex: obj.zIndex,
            )).toList(),
          );
          _storageService.saveHomeData(homeDto.toJson());
          
          print('✅ Home data silently updated from API');
        },
        error: (error) {
          print('⚠️ Silent update failed: ${error.message}');
          // Keep using cache, don't show error to user
          // Only show error if we don't have cache
          if (_homeData.value == null) {
            _errorMessage.value = error.message;
          }
        },
      );
    } catch (e) {
      print('⚠️ Silent update exception: $e');
      // Keep using cache, don't show error to user
      if (_homeData.value == null) {
        _errorMessage.value = 'Unexpected error: $e';
      }
    } finally {
      _isLoading.value = false;
      _isUpdating.value = false;
    }
  }

  // Manual refresh (pull to refresh)
  Future<void> refresh() async {
    _isLoading.value = true;
    await _silentUpdateFromAPI();
  }
}

