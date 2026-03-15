import '../entities/track.dart';
import '../entities/music_library_response.dart'; // Reuse Pagination

class PaginatedQueueResponse {
  final List<Track> data;
  final Pagination pagination;

  PaginatedQueueResponse({
    required this.data,
    required this.pagination,
  });
}
