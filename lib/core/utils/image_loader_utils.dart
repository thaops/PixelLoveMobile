import 'dart:async';
import 'package:flutter/material.dart';

/// Helper class để load và đợi ảnh background render xong
class ImageLoaderUtils {
  /// Đợi ảnh được render lên UI (frame đầu tiên)
  /// Sử dụng ImageStreamListener để đảm bảo ảnh đã được vẽ
  static Future<bool> waitForImageToRender(
    ImageProvider imageProvider,
    BuildContext context, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<bool>();

    late ImageStreamListener listener;
    final imageStream = imageProvider.resolve(
      createLocalImageConfiguration(context),
    );

    Timer? timer;

    listener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) async {
        if (completer.isCompleted) return;

        timer?.cancel();

        // ⏱️ ĐỢI FRAME ĐẦU TIÊN ĐƯỢC VẼ
        await WidgetsBinding.instance.endOfFrame;

        completer.complete(true);
        imageStream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        if (completer.isCompleted) return;

        timer?.cancel();
        completer.complete(false);
        imageStream.removeListener(listener);
      },
    );

    imageStream.addListener(listener);

    timer = Timer(timeout, () {
      if (completer.isCompleted) return;

      completer.complete(false);
      imageStream.removeListener(listener);
    });

    return completer.future;
  }

}

