import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.22.0.124:8080";

  // =========================
  // REGISTER USER
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
  // LOGIN USER (UPDATED)
  // =========================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "token": data["token"],
          "role": data["user"]["role"],
          "user": data["user"],
        };
      } else {
        print("Login Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // =========================
  // GET USER PROFILE
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

  static Future<void> createUser(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  static Future<void> updateUser(
    String token,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  static Future forgotPassword(String email) async {
    return await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
  }

  static Future verifyOtp(String email, String otp) async {
    return await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
  }

  static Future resetPassword(String email, String password) async {
    return await http.post(
      Uri.parse("$baseUrl/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "new_password": password}),
    );
  }

  static Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
