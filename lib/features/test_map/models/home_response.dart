class HomeResponse {
  final BackgroundData background;
  final List<ObjectData> objects;

  HomeResponse({
    required this.background,
    required this.objects,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      background: BackgroundData.fromJson(json['background'] ?? {}),
      objects: (json['objects'] as List<dynamic>?)
              ?.map((item) => ObjectData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class BackgroundData {
  final String imageUrl;
  final double width;
  final double height;

  BackgroundData({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  factory BackgroundData.fromJson(Map<String, dynamic> json) {
    return BackgroundData(
      imageUrl: json['imageUrl'] ?? '',
      width: (json['width'] ?? 4096).toDouble(),
      height: (json['height'] ?? 1920).toDouble(),
    );
  }
}

class ObjectData {
  final String id;
  final String type;
  final String imageUrl;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;

  ObjectData({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
  });

  factory ObjectData.fromJson(Map<String, dynamic> json) {
    return ObjectData(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      zIndex: json['zIndex'] ?? 0,
    );
  }
}

