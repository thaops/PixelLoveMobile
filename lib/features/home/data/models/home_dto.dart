import 'package:pixel_love/features/home/domain/entities/home.dart';

class HomeDto {
  final BackgroundDto background;
  final List<HomeObjectDto> objects;

  HomeDto({
    required this.background,
    required this.objects,
  });

  factory HomeDto.fromJson(Map<String, dynamic> json) {
    return HomeDto(
      background: BackgroundDto.fromJson(json['background'] ?? {}),
      objects: (json['objects'] as List<dynamic>?)
              ?.map((item) => HomeObjectDto.fromJson(item))
              .toList() ??
          [],
    );
  }

  Home toEntity() {
    return Home(
      background: background.toEntity(),
      objects: objects.map((obj) => obj.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background.toJson(),
      'objects': objects.map((obj) => obj.toJson()).toList(),
    };
  }
}

class BackgroundDto {
  final String imageUrl;
  final double width;
  final double height;

  BackgroundDto({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  factory BackgroundDto.fromJson(Map<String, dynamic> json) {
    return BackgroundDto(
      imageUrl: json['imageUrl'] ?? '',
      width: (json['width'] ?? 4096).toDouble(),
      height: (json['height'] ?? 1920).toDouble(),
    );
  }

  Background toEntity() {
    return Background(
      imageUrl: imageUrl,
      width: width,
      height: height,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'width': width,
      'height': height,
    };
  }
}

class HomeObjectDto {
  final String id;
  final String type;
  final String imageUrl;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;

  HomeObjectDto({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
  });

  factory HomeObjectDto.fromJson(Map<String, dynamic> json) {
    return HomeObjectDto(
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

  HomeObject toEntity() {
    return HomeObject(
      id: id,
      type: type,
      imageUrl: imageUrl,
      x: x,
      y: y,
      width: width,
      height: height,
      zIndex: zIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'imageUrl': imageUrl,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'zIndex': zIndex,
    };
  }
}

