import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pixel_love/core/env/env.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Set debug log level if needed
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize with App ID
    debugPrint('Initializing OneSignal with ID: ${Env.oneSignalKey}');
    OneSignal.initialize(Env.oneSignalKey);
    await OneSignal.Notifications.requestPermission(true);

    // Observer for subscription changes
    OneSignal.User.pushSubscription.addObserver((event) {
      debugPrint('OneSignal Subscription Changed:');
      debugPrint(' - ID: ${event.current.id}');
      debugPrint(' - Opted In: ${event.current.optedIn}');
    });

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

  static bool get isSubscribed =>
      OneSignal.User.pushSubscription.optedIn ?? false;
  static String? get subscriptionId => OneSignal.User.pushSubscription.id;
}
