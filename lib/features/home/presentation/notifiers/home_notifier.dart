import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

/// Home State
class HomeState {
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final Home? homeData;

  const HomeState({
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.homeData,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    Home? homeData,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
      homeData: homeData ?? this.homeData,
    );
  }
}

/// Home Notifier - Handles cache-first strategy for home data
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Load from cache and update from API after build completes
    // Use Future.microtask to avoid reading state before initialization
    Future.microtask(() {
      // Load cache first (synchronous)
      _loadFromCache();
      // Then update from API (asynchronous)
      _silentUpdateFromAPI();
    });
    
    return const HomeState();
  }

  void _loadFromCache() {
    final storageService = ref.read(storageServiceProvider);
    final cachedData = storageService.getHomeData();
    
    if (cachedData != null) {
      try {
        final homeDto = HomeDto.fromJson(cachedData);
        final home = homeDto.toEntity();
        state = state.copyWith(homeData: home);
        print('✅ Home data loaded from cache (instant)');
      } catch (e) {
        print('❌ Cache parse error: $e');
        // If cache is corrupted, show loading
        state = state.copyWith(isLoading: true);
      }
    } else {
      // No cache, show loading
      state = state.copyWith(isLoading: true);
      print('⚠️ No cache found, loading from API...');
    }
  }

  Future<void> _silentUpdateFromAPI() async {
    try {
      state = state.copyWith(isUpdating: true);

      final getHomeDataUseCase = ref.read(getHomeDataUseCaseProvider);
      final result = await getHomeDataUseCase.call();

      result.when(
        success: (home) {
          // Update UI with new data
          state = state.copyWith(homeData: home);
          
          // Save to cache for next time
          final storageService = ref.read(storageServiceProvider);
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
          storageService.saveHomeData(homeDto.toJson());
          
          print('✅ Home data silently updated from API');
        },
        error: (error) {
          print('⚠️ Silent update failed: ${error.message}');
          // Keep using cache, don't show error to user
          // Only show error if we don't have cache
          if (state.homeData == null) {
            state = state.copyWith(errorMessage: error.message);
          }
        },
      );
    } catch (e) {
      print('⚠️ Silent update exception: $e');
      // Keep using cache, don't show error to user
      if (state.homeData == null) {
        state = state.copyWith(errorMessage: 'Unexpected error: $e');
      }
    } finally {
      state = state.copyWith(
        isLoading: false,
        isUpdating: false,
      );
    }
  }

  // Manual refresh (pull to refresh)
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _silentUpdateFromAPI();
  }

  // Default image dimensions
  static const double defaultImageWidth = 4096.0;
  static const double defaultImageHeight = 1920.0;
}

