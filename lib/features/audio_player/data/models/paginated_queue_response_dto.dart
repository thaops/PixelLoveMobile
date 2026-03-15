import 'track_dto.dart';
import 'music_library_response_dto.dart'; // Reuse PaginationDto

class PaginatedQueueResponseDto {
  final List<TrackDto> data;
  final PaginationDto pagination;

  PaginatedQueueResponseDto({
    required this.data,
    required this.pagination,
  });

  factory PaginatedQueueResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedQueueResponseDto(
      data: (json['data'] as List? ?? [])
          .map((e) => TrackDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}
