import 'package:image/image.dart' as img;

/// Crop ảnh theo tỉ lệ [targetAspect] (height / width) ở giữa khung.
/// Trả về một [img.Image] mới đã được crop center.
img.Image cropCenterToAspect(img.Image source, {required double targetAspect}) {
  final width = source.width;
  final height = source.height;
  final currentAspect = height / width;

  int cropWidth = width;
  int cropHeight = height;

  if (currentAspect > targetAspect) {
    // Ảnh quá cao so với khung → crop bớt chiều cao
    cropHeight = (width * targetAspect).round();
  } else if (currentAspect < targetAspect) {
    // Ảnh quá rộng so với khung → crop bớt chiều rộng
    cropWidth = (height / targetAspect).round();
  } else {
    // Đã đúng tỉ lệ
    return source;
  }

  final offsetX = ((width - cropWidth) / 2).round();
  final offsetY = ((height - cropHeight) / 2).round();

  return img.copyCrop(
    source,
    x: offsetX,
    y: offsetY,
    width: cropWidth,
    height: cropHeight,
  );
}
