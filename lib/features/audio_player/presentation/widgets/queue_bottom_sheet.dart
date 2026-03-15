import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/features/audio_player/providers/audio_providers.dart';
import '../../domain/entities/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/full_queue_notifier.dart';

class QueueBottomSheet extends ConsumerStatefulWidget {
  final Function(Track) onPlay;
  final Function(String) onDelete;

  const QueueBottomSheet({
    super.key,
    required this.onPlay,
    required this.onDelete,
    @Deprecated('Use audioPlayerNotifierProvider') Track? currentTrack,
    @Deprecated('Queue is now managed by FullQueueNotifier') List<Track>? queue,
  });

  @override
  ConsumerState<QueueBottomSheet> createState() => _QueueBottomSheetState();
}

class _QueueBottomSheetState extends ConsumerState<QueueBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Sync search controller with persistent state
    final initialQuery = ref.read(fullQueueProvider).searchQuery ?? '';
    _searchController.text = initialQuery;
    
    // Fetch first page when opening
    Future.microtask(() => ref.read(fullQueueProvider.notifier).fetchQueue());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(fullQueueProvider.notifier).onSearch(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(fullQueueProvider.notifier).fetchQueue(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fullQueueProvider);
    final audioState = ref.watch(audioPlayerNotifierProvider);
    final currentTrack = audioState.currentTrack;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF18181A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (currentTrack != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListTile(
                  key: ValueKey(currentTrack.id),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: currentTrack.thumbnail,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white10),
                      errorWidget: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.white10,
                        child: const Icon(Icons.music_note, color: Colors.white38),
                      ),
                    ),
                  ),
                  title: Text(
                    currentTrack.title,
                    style: const TextStyle(
                      color: Colors.greenAccent, 
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text(
                    'Đang phát...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.equalizer, color: Colors.greenAccent),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Không có bài nào đang phát',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm trong danh sách phát...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Up Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.isLoading && state.tracks.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                  : state.tracks.isEmpty
                      ? const Center(
                          child: Text(
                            'Hàng đợi trống',
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.tracks.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.tracks.length) {
                               return const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 24),
                                 child: Center(child: CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 2)),
                               );
                            }

                            final track = state.tracks[index];
                            final isSelected = track.id == currentTrack?.id;

                            return Dismissible(
                              key: Key(track.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                ref.read(fullQueueProvider.notifier).removeTrack(track.id);
                                widget.onDelete(track.id);
                              },
                              child: ListTile(
                                onTap: () {
                                  widget.onPlay(track);
                                  // Silent sync after a delay to keep list clean
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (mounted) ref.read(fullQueueProvider.notifier).refresh();
                                  });
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: track.thumbnail,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: Colors.white10),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.white10,
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  track.title,
                                  style: TextStyle(
                                    color: isSelected ? Colors.greenAccent : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.status == 'ready'
                                          ? 'Sẵn sàng'
                                          : 'Đang xử lý... ${track.progress}%',
                                      style: TextStyle(
                                        color: track.status == 'ready'
                                            ? Colors.white54
                                            : Colors.orangeAccent.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (track.status != 'ready')
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          right: 24,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: track.progress / 100,
                                            backgroundColor: Colors.white10,
                                            valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                                  Colors.orangeAccent,
                                                ),
                                            minHeight: 2,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
