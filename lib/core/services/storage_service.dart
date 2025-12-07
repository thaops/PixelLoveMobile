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
}

