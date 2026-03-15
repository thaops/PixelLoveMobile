import 'track_dto.dart';

class PaginationDto {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationDto({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class MusicLibraryResponseDto {
  final List<TrackDto> data;
  final PaginationDto pagination;

  MusicLibraryResponseDto({
    required this.data,
    required this.pagination,
  });

  factory MusicLibraryResponseDto.fromJson(Map<String, dynamic> json) {
    return MusicLibraryResponseDto(
      data: (json['data'] as List? ?? [])
          .map((e) => TrackDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}
