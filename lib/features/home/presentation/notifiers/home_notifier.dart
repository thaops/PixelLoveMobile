import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/data/models/home_dto.dart';
import 'package:pixel_love/features/home/domain/entities/home.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

/// Home State
class HomeState {
  final bool isUpdating;
  final String? errorMessage;
  final Home? homeData;

  const HomeState({this.isUpdating = false, this.errorMessage, this.homeData});

  HomeState copyWith({bool? isUpdating, String? errorMessage, Home? homeData}) {
    return HomeState(
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
    // Load from cache immediately (synchronous) để tránh hiển thị loading khi quay về
    final storageService = ref.read(storageServiceProvider);
    final cachedData = storageService.getHomeData();

    Home? cachedHome;
    if (cachedData != null) {
      try {
        final homeDto = HomeDto.fromJson(cachedData);
        cachedHome = homeDto.toEntity();
        print('✅ Home data loaded from cache (instant)');
      } catch (e) {
        print('❌ Cache parse error: $e');
      }
    }

    // Nếu có cache, trả về state với data ngay
    // Nếu không có cache, load từ API (không có loading state)
    if (cachedHome != null) {
      // Load cache xong, update từ API sau (silent)
      Future.microtask(() {
        _silentUpdateFromAPI();
      });
      return HomeState(homeData: cachedHome);
    } else {
      // Không có cache, load từ API (không hiển thị loading)
      Future.microtask(() {
        _loadFromCache();
        _silentUpdateFromAPI();
      });
      return const HomeState();
    }
  }

  void _loadFromCache() {
    // Chỉ load từ cache nếu chưa có data trong state
    if (state.homeData != null) return;

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
        // If cache is corrupted, không set loading (sẽ load từ API)
      }
    } else {
      // No cache, load từ API (không set loading)
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
            objects: home.objects
                .map(
                  (obj) => HomeObjectDto(
                    id: obj.id,
                    type: obj.type,
                    imageUrl: obj.imageUrl,
                    x: obj.x,
                    y: obj.y,
                    width: obj.width,
                    height: obj.height,
                    zIndex: obj.zIndex,
                  ),
                )
                .toList(),
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
      state = state.copyWith(isUpdating: false);
    }
  }

  // Manual refresh (pull to refresh)
  Future<void> refresh() async {
    await Future.wait([
      _silentUpdateFromAPI(),
      ref.read(streakNotifierProvider.notifier).fetchStreak(),
    ]);
  }

  // Default image dimensions
  static const double defaultImageWidth = 4096.0;
  static const double defaultImageHeight = 1920.0;
}
