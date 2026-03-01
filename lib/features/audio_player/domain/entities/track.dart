class Track {
  final String id;
  final String title;
  final String thumbnail;
  final String audioUrl;
  final num duration;
  final String status;
  final int progress;

  Track({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.audioUrl,
    required this.duration,
    required this.status,
    this.progress = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
