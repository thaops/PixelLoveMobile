import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final DioApi _dioApi;
  final StorageService _storageService;

  NotificationService(this._dioApi, this._storageService) {
    if (OneSignal.User.pushSubscription.id != null) {
      syncDevice();
    }

    OneSignal.User.pushSubscription.addObserver((state) {
      if (state.current.id != state.previous.id && state.current.id != null) {
        syncDevice();
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('Foreground notification: ${event.notification.title}');
      event.notification.display();
    });
  }

  static Future<void> initialize() async {
    debugPrint('Initializing OneSignal with ID: ${Env.oneSignalKey}');
    OneSignal.initialize(Env.oneSignalKey);
    await OneSignal.Notifications.requestPermission(true);

    OneSignal.User.pushSubscription.addObserver((event) {
      debugPrint('OneSignal Subscription Changed: ${event.current.id}');
    });
  }

  Future<String> _getDeviceId() async {
    String? storedId = _storageService.getDeviceId();
    if (storedId != null) return storedId;

    final deviceInfo = DeviceInfoPlugin();
    String deviceId = const Uuid().v4();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? deviceId;
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    await _storageService.saveDeviceId(deviceId);
    return deviceId;
  }

  Future<void> syncDevice() async {
    try {
      final deviceId = await _getDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();
      final onesignalPlayerId = OneSignal.User.pushSubscription.id;

      if (onesignalPlayerId == null) {
        debugPrint('OneSignal Player ID not available yet');
        return;
      }

      final body = {
        "deviceId": deviceId,
        "platform": Platform.isIOS ? "ios" : "android",
        "onesignalPlayerId": onesignalPlayerId,
        "appVersion": packageInfo.version,
      };

      await _dioApi.post(
        '/devices/register',
        data: body,
        fromJson: (json) => json,
      );
      debugPrint('Device registered successfully');
    } catch (e) {
      debugPrint('Error syncing device: $e');
    }
  }

  Future<void> ping() async {
    try {
      final deviceId = await _getDeviceId();
      await _dioApi.post(
        '/devices/ping',
        data: {"deviceId": deviceId},
        fromJson: (json) => json,
      );
    } catch (e) {
      debugPrint('Error pinging device: $e');
    }
  }

  Future<void> logoutDevice() async {
    try {
      final deviceId = await _getDeviceId();
      await _dioApi.post(
        '/devices/logout',
        data: {"deviceId": deviceId},
        fromJson: (json) => json,
      );
      OneSignal.logout();
    } catch (e) {
      debugPrint('Error logging out device: $e');
    }
  }

  static Future<void> login(String userId) async {
    OneSignal.login(userId);
  }

  static bool get isSubscribed =>
      OneSignal.User.pushSubscription.optedIn ?? false;
  static String? get subscriptionId => OneSignal.User.pushSubscription.id;
}
