import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class SwipeTemporaryImageCard extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final Uint8List imageBytes;
  final String? caption;
  final DateTime capturedAt;
  final String Function(DateTime) formatDateTime;
  final bool isUploading;
  final int sensorRotation;
  final SensorPosition sensorPosition;

  const SwipeTemporaryImageCard({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.imageBytes,
    this.caption,
    required this.capturedAt,
    required this.formatDateTime,
    this.isUploading = false,
    this.sensorRotation = 0,
    this.sensorPosition = SensorPosition.back,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(maxWidth: cardWidth, maxHeight: cardHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔥 Tự động xoay và lật ảnh dựa trên metadata để hiển thị đúng hướng ngay lập tức
            Center(
              child: RotatedBox(
                quarterTurns: sensorRotation ~/ 90,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      sensorPosition == SensorPosition.front ? -1.0 : 1.0,
                      1.0,
                    ),
                  child: Image.memory(
                    imageBytes,
                    width: cardWidth,
                    height: cardHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (caption != null && caption!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isUploading
                                ? Colors.white.withOpacity(0.3)
                                : AppColors.primaryPink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUploading
                                    ? Icons.access_time_rounded
                                    : Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isUploading ? 'Đang gửi...' : '+20 EXP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.today,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDateTime(capturedAt),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
