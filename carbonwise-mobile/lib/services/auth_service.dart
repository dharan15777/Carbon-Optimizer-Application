import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _userDataKey = 'user_data';

  AuthService(this._apiService);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/api/auth/login', data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    await _saveTokensAndUser(data);
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiService.post('/api/auth/register', data: {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role,
    });

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<bool> verifyOTP({required String email, required String otp}) async {
    final response = await _apiService.post('/api/auth/verifyOTP', data: {
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
    });
    if (response.data is bool) {
      return response.data as bool;
    }
    return response.data['verified'] == true;
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiService.post('/api/auth/forgotPassword', data: {
      'email': email.trim().toLowerCase(),
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove(_userDataKey);
  }

  Future<bool> isLoggedIn() async {
    return isAuthenticated();
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userDataKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      return User.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveTokensAndUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['token'] != null) {
      await prefs.setString(AppConstants.tokenKey, data['token'].toString());
    }
    if (data['refreshToken'] != null) {
      await prefs.setString(AppConstants.refreshTokenKey, data['refreshToken'].toString());
    }
    if (data['userId'] != null) {
      await prefs.setString(AppConstants.userIdKey, data['userId'].toString());
    }
    if (data['role'] != null) {
      await prefs.setString(AppConstants.userRoleKey, data['role'].toString());
    }
    if (data['user'] != null && data['user'] is Map) {
      await prefs.setString(_userDataKey, json.encode(data['user']));
    }
  }
}

