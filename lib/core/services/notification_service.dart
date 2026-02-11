import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pixel_love/core/env/env.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Set debug log level if needed
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize with App ID
    OneSignal.initialize("60defdbb-19b7-43bb-9447-183d69b855d6");

    // Request permissions
    await OneSignal.Notifications.requestPermission(true);

    // Listeners example
    OneSignal.Notifications.addClickListener((event) {
      // Handle notification click
    });
  }

  static Future<void> login(String userId) async {
    OneSignal.login(userId);
  }

  static Future<void> logout() async {
    OneSignal.logout();
  }
}
