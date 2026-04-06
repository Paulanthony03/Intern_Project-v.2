import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveSession(String token, String role) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'role', value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
