import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Map<String, dynamic>> login(String email, String password) {
    return _authService.login(email: email, password: password);
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) {
    return _authService.register(name: name, email: email, password: password, role: role);
  }

  Future<bool> verifyOTP(String email, String otp) {
    return _authService.verifyOTP(email: email, otp: otp);
  }

  Future<void> forgotPassword(String email) {
    return _authService.forgotPassword(email: email);
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<bool> isAuthenticated() {
    return _authService.isAuthenticated();
  }

  Future<String?> getUserRole() {
    return _authService.getUserRole();
  }

  Future<User?> getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Future<String?> getToken() {
    return _authService.getToken();
  }

  User parseUser(Map<String, dynamic> data) {
    return User.fromJson(data);
  }
}

