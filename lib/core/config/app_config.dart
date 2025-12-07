class AppConfig {
  static const String appName = 'Pixel Love';
  static const String appVersion = '1.0.0';

  static const int defaultPageSize = 20;
  static const int maxImageSizeMB = 10;

  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration cacheDuration = Duration(hours: 1);

  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];
}
