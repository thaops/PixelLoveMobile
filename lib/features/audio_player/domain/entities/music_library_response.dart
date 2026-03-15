import 'track.dart';

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class MusicLibraryResponse {
  final List<Track> data;
  final Pagination pagination;

  MusicLibraryResponse({
    required this.data,
    required this.pagination,
  });
}
