import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  // Allow external callers to set an error (or info) message and notify listeners.
  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  bool get isLoggedIn => _service.isLoggedIn();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.login(username, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.register(username, password);
      _errorMessage = "Registrasi berhasil! Silakan login.";
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}