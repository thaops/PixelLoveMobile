import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/core/services/cloudinary_upload_service.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:pixel_love/core/services/socket_service.dart';

// ============================================
// Core Providers (Global, Permanent)
// ============================================

/// SharedPreferences provider
/// Note: SharedPreferences must be initialized in main() before ProviderScope
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// StorageService provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

/// DioApi provider (singleton)
final dioApiProvider = Provider<DioApi>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return DioApi(storageService);
});

/// SocketService provider (singleton)
final socketServiceProvider = Provider<SocketService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return SocketService(storageService);
});

/// CloudinaryUploadService provider (singleton)
final cloudinaryUploadServiceProvider = Provider<CloudinaryUploadService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return CloudinaryUploadService(storageService);
});

