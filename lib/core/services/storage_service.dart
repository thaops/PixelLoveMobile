import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

class StorageService {
  final GetStorage _storage;

  StorageService(this._storage);

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write('access_token', token);
  }

  String? getToken() {
    return _storage.read<String>('access_token');
  }

  Future<void> removeToken() async {
    await _storage.remove('access_token');
  }

  // User management
  Future<void> saveUser(AuthUser user) async {
    await _storage.write('user_data', jsonEncode(user.toJson()));
  }

  AuthUser? getUser() {
    final userJson = _storage.read<String>('user_data');
    if (userJson == null || userJson.isEmpty) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await _storage.remove('user_data');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.erase();
  }

  // Check if user is logged in
  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Home data cache
  Future<void> saveHomeData(Map<String, dynamic> homeData) async {
    await _storage.write('home_data', jsonEncode(homeData));
    await _storage.write('home_data_timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getHomeData() {
    final homeJson = _storage.read<String>('home_data');
    if (homeJson == null || homeJson.isEmpty) return null;
    
    try {
      return jsonDecode(homeJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  DateTime? getHomeDataTimestamp() {
    final timestamp = _storage.read<String>('home_data_timestamp');
    if (timestamp == null) return null;
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  bool isHomeDataExpired({Duration expireAfter = const Duration(days: 1)}) {
    final timestamp = getHomeDataTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > expireAfter;
  }

  Future<void> clearHomeData() async {
    await _storage.remove('home_data');
    await _storage.remove('home_data_timestamp');
  }
}

