import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isGuestMode = false;
  String? _error;

  AuthProvider(this._authRepository);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuestMode => _isGuestMode;
  bool get isOfflineMode => _isGuestMode; // for backward compatibility
  String? get error => _error;

  String _formatError(Object e) {
    if (e is ApiException) {
      return e.message;
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  /// Real user login via Spring Boot API + Neon PostgreSQL
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _isGuestMode = false;
    notifyListeners();

    try {
      final data = await _authRepository.login(email.trim(), password);
      if (data['user'] != null && data['user'] is Map) {
        _user = _authRepository.parseUser(Map<String, dynamic>.from(data['user'] as Map));
      } else {
        _user = User(
          id: data['userId']?.toString() ?? '',
          name: email.split('@').first,
          email: email.trim(),
          role: data['role']?.toString() ?? AppConstants.roleConsumer,
        );
      }
      _isAuthenticated = true;
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
      _isGuestMode = false;
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Real user registration via Spring Boot API + Neon PostgreSQL
  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    _isGuestMode = false;
    notifyListeners();

    try {
      final data = await _authRepository.register(name.trim(), email.trim(), password, role);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Explicit One-Tap Guest / Demo Mode (does not call backend or create fake database users)
  void enterGuestMode() {
    _user = User(
      id: 'guest-demo-user',
      name: 'Guest Explorer',
      email: 'guest@carbonwise.demo',
      role: AppConstants.roleConsumer,
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    _isGuestMode = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authRepository.verifyOTP(email.trim(), otp.trim());
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.forgotPassword(email.trim());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _isAuthenticated = false;
    _isGuestMode = false;
    _error = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final hasToken = await _authRepository.isAuthenticated();
    if (hasToken) {
      _isAuthenticated = true;
      _isGuestMode = false;
      _user = await _authRepository.getCurrentUser();
    } else {
      _isAuthenticated = false;
      _isGuestMode = false;
      _user = null;
    }
    notifyListeners();
  }
}

