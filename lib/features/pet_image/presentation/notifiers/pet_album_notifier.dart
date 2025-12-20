import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/domain/entities/pet_image.dart';
import 'package:pixel_love/features/pet_image/presentation/models/timeline_item.dart';
import 'package:pixel_love/features/pet_image/providers/pet_image_providers.dart';

/// Pet Album State
class PetAlbumState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<PetImage> images;
  final int total;
  final int currentPage;
  final bool hasMore;

  const PetAlbumState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.images = const [],
    this.total = 0,
    this.currentPage = 1,
    this.hasMore = true,
  });

  bool get isEmpty => images.isEmpty && !isLoading;

  PetAlbumState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<PetImage>? images,
    int? total,
    int? currentPage,
    bool? hasMore,
  }) {
    return PetAlbumState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      images: images ?? this.images,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Pet Album Notifier - Handles pagination and socket events for pet images
class PetAlbumNotifier extends Notifier<PetAlbumState> {
  static const int _pageSize = 20;

  @override
  PetAlbumState build() {
    // Setup socket listener
    _listenSocketEvents();
    
    // Load initial images
    loadImages();
    
    return const PetAlbumState();
  }

  void _listenSocketEvents() {
    final socketService = ref.read(socketServiceProvider);
    // Lắng nghe event ảnh mới từ BE để update album realtime
    socketService.onPetImageConsumed = _handlePetImageConsumed;
  }

  /// Load ảnh từ đầu (refresh)
  Future<void> loadImages({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state = state.copyWith(isLoading: true);
      }
      state = state.copyWith(errorMessage: null, currentPage: 1, hasMore: true);

      final getPetImagesUseCase = ref.read(getPetImagesUseCaseProvider);
      final result = await getPetImagesUseCase.call(page: 1, limit: _pageSize);

      result.when(
        success: (data) {
          state = state.copyWith(
            images: data.items,
            total: data.total,
            hasMore: data.items.length < data.total,
            currentPage: 1,
          );
        },
        error: (error) {
          state = state.copyWith(errorMessage: error.message);
          // Show snackbar sẽ được handle ở UI layer
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi không xác định: $e');
    } finally {
      if (showLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Load thêm ảnh (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);
      final nextPage = state.currentPage + 1;

      final getPetImagesUseCase = ref.read(getPetImagesUseCaseProvider);
      final result = await getPetImagesUseCase.call(
        page: nextPage,
        limit: _pageSize,
      );

      result.when(
        success: (data) {
          final newImages = [...state.images, ...data.items];
          state = state.copyWith(
            images: newImages,
            hasMore: newImages.length < data.total,
            currentPage: nextPage,
          );
        },
        error: (error) {
          // Không hiển thị snackbar khi load more lỗi, chỉ log
          print('Load more error: ${error.message}');
        },
      );
    } catch (e) {
      print('Load more exception: $e');
    } finally {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadImages(showLoading: false);
  }

  /// Build timeline items từ danh sách images
  List<TimelineItem> buildTimelineItems() {
    if (state.images.isEmpty) return [];

    // Lấy currentUser từ storage
    final storageService = ref.read(storageServiceProvider);
    final currentUser = storageService.getUser();
    final currentUserId = currentUser?.id ?? '';

    if (currentUserId.isEmpty) return [];

    final List<TimelineItem> items = [];
    final sortedImages = List<PetImage>.from(state.images)
      ..sort((a, b) => b.actionAt.compareTo(a.actionAt)); // Mới nhất trước

    DateTime? lastTimeHeader;
    const comboTimeWindow = Duration(hours: 3); // Combo trong 3 giờ

    for (int i = 0; i < sortedImages.length; i++) {
      final image = sortedImages[i];
      final isMe = image.userId == currentUserId;

      // Kiểm tra xem có cần TimeHeader không
      if (lastTimeHeader == null ||
          _shouldShowTimeHeader(lastTimeHeader, image.actionAt)) {
        items.add(TimeHeader(image.actionAt));
        lastTimeHeader = image.actionAt;
      }

      // Kiểm tra combo: 2 images từ 2 users trong cùng time window
      if (i < sortedImages.length - 1) {
        final nextImage = sortedImages[i + 1];
        final nextIsMe = nextImage.userId == currentUserId;
        final timeDiff = image.actionAt.difference(nextImage.actionAt).abs();

        // Combo: 2 users khác nhau và trong time window
        if (isMe != nextIsMe && timeDiff <= comboTimeWindow) {
          final comboImages = [image, nextImage];
          final totalExp = comboImages.fold<int>(
            0,
            (sum, img) => sum + img.totalExp,
          );

          items.add(
            ComboItem(
              images: comboImages,
              totalExp: totalExp,
              time: image.actionAt,
            ),
          );

          // Skip next image vì đã xử lý trong combo
          i++;
          continue;
        }
      }

      // Thêm image item bình thường
      items.add(
        ImageItem(
          image: image,
          isMe: isMe,
          userName: isMe ? currentUser?.name : null,
          userAvatar: isMe ? currentUser?.avatar : null,
          gender: _getUserGender(isMe),
        ),
      );
    }

    return items;
  }

  /// Kiểm tra xem có cần hiển thị TimeHeader không
  bool _shouldShowTimeHeader(DateTime lastTime, DateTime currentTime) {
    // Khác ngày
    if (lastTime.day != currentTime.day ||
        lastTime.month != currentTime.month ||
        lastTime.year != currentTime.year) {
      return true;
    }

    // Cách nhau > 3 giờ
    final diff = lastTime.difference(currentTime).abs();
    return diff.inHours >= 3;
  }

  /// Xác định gender của user
  String _getUserGender(bool isMe) {
    return isMe ? 'female' : 'male';
  }

  /// Handle socket event pet:image_consumed
  void _handlePetImageConsumed(Map<String, dynamic> data) {
    try {
      final imageUrl = data['imageUrl'] as String? ?? '';
      final fromUserId = data['fromUserId'] as String? ?? '';
      final actionAtStr = data['actionAt'] as String?;

      if (imageUrl.isEmpty || fromUserId.isEmpty || actionAtStr == null) {
        return;
      }

      final actionAt = DateTime.tryParse(actionAtStr);
      if (actionAt == null) {
        return;
      }

      final baseExp = (data['baseExp'] as num?)?.toInt() ?? 20;
      final bonusExp = (data['bonusExp'] as num?)?.toInt() ?? 0;

      final newImage = PetImage(
        imageUrl: imageUrl,
        userId: fromUserId,
        actionAt: actionAt,
        takenAt: null,
        baseExp: baseExp,
        bonusExp: bonusExp,
        mood: data['mood'] as String?,
        text: data['text'] as String?,
        createdAt: DateTime.now(),
      );

      // Thêm ảnh mới vào danh sách hiện tại
      final newImages = [newImage, ...state.images];
      state = state.copyWith(
        images: newImages,
        total: state.total + 1,
      );
    } catch (e) {
      print('Error handling pet:image_consumed event: $e');
    }
  }
}

