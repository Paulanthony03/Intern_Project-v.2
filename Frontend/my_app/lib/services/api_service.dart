import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.22.0.124:8080";

  // =========================
  // 🔹 REGISTER USER
  // =========================
  static Future<String?> register(
    String name,
    String email,
    String password,
    String internId,
    String school,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "intern_id": internId,
        "school": school,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return "success";
    } else {
      return data["error"];
    }
  }

  // =========================
  // 🔹 LOGIN USER
  // =========================
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["token"];
      } else {
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // =========================
  // 🔹 GET USER PROFILE
  // =========================
  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("USERS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Profile Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Profile Exception: $e");
      return null;
    }
  }

  static Future<List<dynamic>?> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("USERS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Get Users Error: $e");
      return null;
    }
  }
}
