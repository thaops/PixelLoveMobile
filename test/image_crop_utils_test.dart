import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixel_love/features/pet_image/presentation/utils/image_crop_utils.dart';

void main() {
  const targetAspect = 4 / 3.5;

  double _aspect(img.Image image) => image.height / image.width;

  test('cropCenterToAspect giữ nguyên nếu đã đúng tỉ lệ', () {
    final source = img.Image(width: 400, height: (400 * targetAspect).round());

    final result = cropCenterToAspect(source, targetAspect: targetAspect);

    expect(result.width, source.width);
    expect(result.height, source.height);
    expect(_aspect(result), closeTo(targetAspect, 1e-6));
  });

  test('cropCenterToAspect crop bớt chiều cao khi ảnh quá cao', () {
    // Ảnh cao hơn nhiều so với tỉ lệ khung
    final source = img.Image(width: 400, height: 1000);

    final result = cropCenterToAspect(source, targetAspect: targetAspect);

    expect(result.width, 400);
    expect(_aspect(result), closeTo(targetAspect, 1e-6));
  });

  test('cropCenterToAspect crop bớt chiều rộng khi ảnh quá rộng', () {
    // Ảnh rộng hơn nhiều so với tỉ lệ khung
    final source = img.Image(width: 1000, height: 400);

    final result = cropCenterToAspect(source, targetAspect: targetAspect);

    expect(result.height, 400);
    expect(_aspect(result), closeTo(targetAspect, 1e-6));
  });
}
