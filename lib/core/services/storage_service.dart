import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_love/features/auth/domain/entities/auth_user.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString('access_token', token);
  }

  String? getToken() {
    return _prefs.getString('access_token');
  }

  Future<void> removeToken() async {
    await _prefs.remove('access_token');
  }

  // User management
  Future<void> saveUser(AuthUser user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  AuthUser? getUser() {
    final userJson = _prefs.getString('user_data');
    if (userJson == null || userJson.isEmpty) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await _prefs.remove('user_data');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Home data cache
  Future<void> saveHomeData(Map<String, dynamic> homeData) async {
    await _prefs.setString('home_data', jsonEncode(homeData));
    await _prefs.setString('home_data_timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getHomeData() {
    final homeJson = _prefs.getString('home_data');
    if (homeJson == null || homeJson.isEmpty) return null;
    
    try {
      return jsonDecode(homeJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  DateTime? getHomeDataTimestamp() {
    final timestamp = _prefs.getString('home_data_timestamp');
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
    await _prefs.remove('home_data');
    await _prefs.remove('home_data_timestamp');
  }
}

