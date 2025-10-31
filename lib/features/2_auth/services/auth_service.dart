import 'package:hive_flutter/hive_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService {
  final Box _usersBox = Hive.box('users');
  final Box _sessionBox = Hive.box('session');

  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  Future<bool> register(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception("Username dan password tidak boleh kosong");
    }

    if (_usersBox.containsKey(username)) {
      throw Exception("Username sudah terpakai");
    }

    final hashedPassword = _hashPassword(password);
    await _usersBox.put(username, hashedPassword);
    return true;
  }

  Future<bool> login(String username, String password) async {
    if (!_usersBox.containsKey(username)) {
      throw Exception("Username tidak ditemukan");
    }

    final String storedHash = _usersBox.get(username);

    if (BCrypt.checkpw(password, storedHash)) {
      await _sessionBox.put("currentUser", username);
      return true;
    } else {
      throw Exception("Password salah");
    }
  }

  Future<void> logout() async {
    await _sessionBox.delete("currentUser");
  }

  String? getCurrentUser() {
    return _sessionBox.get("currentUser");
  }

  bool isLoggedIn() {
    return _sessionBox.containsKey("currentUser");
  }
}
