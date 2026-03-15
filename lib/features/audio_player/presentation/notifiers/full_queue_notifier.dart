import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/music_library_response.dart'; // Pagination
import '../../domain/repositories/audio_repository.dart';
import '../../providers/audio_providers.dart';

class FullQueueState {
  final List<Track> tracks;
  final Pagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? searchQuery;
  final String? errorMessage;

  FullQueueState({
    this.tracks = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.searchQuery,
    this.errorMessage,
  });

  FullQueueState copyWith({
    List<Track>? tracks,
    Pagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? searchQuery,
    String? errorMessage,
  }) {
    return FullQueueState(
      tracks: tracks ?? this.tracks,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FullQueueNotifier extends Notifier<FullQueueState> {
  late final AudioRepository _repository;

  @override
  FullQueueState build() {
    _repository = ref.watch(audioRepositoryProvider);
    return FullQueueState();
  }

  Future<void> fetchQueue({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (state.isLoadingMore || state.pagination == null) return;
      if (state.pagination!.page >= state.pagination!.totalPages) return;
      
      state = state.copyWith(isLoadingMore: true);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final nextPage = isLoadMore ? (state.pagination!.page + 1) : 1;
    final result = await _repository.getQueue(
      page: nextPage,
      search: state.searchQuery,
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          tracks: isLoadMore ? [...state.tracks, ...response.data] : response.data,
          pagination: response.pagination,
          isLoading: false,
          isLoadingMore: false,
        );
      },
      error: (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> refresh() async {
    await fetchQueue();
  }

  void removeTrack(String trackId) {
    state = state.copyWith(
      tracks: state.tracks.where((t) => t.id != trackId).toList(),
    );
  }

  void onSearch(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query, tracks: []);
    fetchQueue();
  }
}

final fullQueueProvider = NotifierProvider<FullQueueNotifier, FullQueueState>(
  FullQueueNotifier.new,
);
