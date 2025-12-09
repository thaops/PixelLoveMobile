import 'package:equatable/equatable.dart';

class Home extends Equatable {
  final Background background;
  final List<HomeObject> objects;

  const Home({
    required this.background,
    required this.objects,
  });

  @override
  List<Object?> get props => [background, objects];
}

class Background extends Equatable {
  final String imageUrl;
  final double width;
  final double height;

  const Background({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [imageUrl, width, height];
}

class HomeObject extends Equatable {
  final String id;
  final String type;
  final String imageUrl;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;

  const HomeObject({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.zIndex,
  });

  @override
  List<Object?> get props => [id, type, imageUrl, x, y, width, height, zIndex];
}

