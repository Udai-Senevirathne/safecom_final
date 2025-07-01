import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../Core/error/exceptions.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheUserData(UserModel user);
  Future<UserModel?> getCachedUserData();
  Future<void> clearCachedUserData();
  Future<void> setLoginStatus(bool isLoggedIn);
  Future<bool> getLoginStatus();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'CACHED_USER';
  static const String _loginStatusKey = 'LOGIN_STATUS';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUserData(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user data');
    }
  }

  @override
  Future<UserModel?> getCachedUserData() async {
    try {
      final userJsonString = sharedPreferences.getString(_cachedUserKey);
      if (userJsonString == null) return null;

      final userJson = json.decode(userJsonString);
      return UserModel.fromJson(userJson);
    } catch (e) {
      throw CacheException('Failed to get cached user data');
    }
  }

  @override
  Future<void> clearCachedUserData() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user data');
    }
  }

  @override
  Future<void> setLoginStatus(bool isLoggedIn) async {
    try {
      await sharedPreferences.setBool(_loginStatusKey, isLoggedIn);
    } catch (e) {
      throw CacheException('Failed to set login status');
    }
  }

  @override
  Future<bool> getLoginStatus() async {
    try {
      return sharedPreferences.getBool(_loginStatusKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to get login status');
    }
  }
}
