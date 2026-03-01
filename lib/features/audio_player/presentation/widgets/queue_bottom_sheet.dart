import 'package:flutter/material.dart';
import '../../domain/entities/track.dart';

class QueueBottomSheet extends StatelessWidget {
  final Track? currentTrack;
  final List<Track> queue;
  final Function(String) onPlay;
  final Function(String) onDelete;

  const QueueBottomSheet({
    super.key,
    this.currentTrack,
    required this.queue,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentTrack!.thumbnail,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.white10,
                    child: const Icon(Icons.music_note, color: Colors.white38),
                  ),
                ),
              ),
              title: Text(
                currentTrack!.title,
                style: const TextStyle(color: Colors.greenAccent),
              ),
              subtitle: const Text(
                'Đang phát...',
                style: TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(Icons.waves, color: Colors.greenAccent),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không có bài nào đang phát',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            child: queue.isEmpty
                ? const Center(
                    child: Text(
                      'Hàng đợi trống',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final track = queue[index];
                      return Dismissible(
                        key: Key(track.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => onDelete(track.id),
                        child: ListTile(
                          onTap: () => onPlay(track.id),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              track.thumbnail,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
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
                            style: const TextStyle(color: Colors.white),
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
    );
  }
}
