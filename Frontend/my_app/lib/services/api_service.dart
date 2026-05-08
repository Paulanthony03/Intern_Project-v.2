import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.22.0.124:8080/api";

  // =========================
  // REGISTER USER
  // =========================
  static Future<String?> register(
    String name,
    String email,
    String password,
    String internId,
    String school,
    String program,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name":      name,
        "email":     email,
        "password":  password,
        "intern_id": internId,
        "school":    school,
        "program":   program,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return "success";
    return data["error"];
  }

  // =========================
  // LOGIN USER
  // =========================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "token": data["token"],
          "role":  data["user"]["role"],
          "user":  data["user"],
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
        Uri.parse('$baseUrl/profile'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("PROFILE RESPONSE: ${response.body}");

      if (response.statusCode == 200) return jsonDecode(response.body);
      print("Profile Error: ${response.body}");
      return null;
    } catch (e) {
      print("Profile Exception: $e");
      return null;
    }
  }

  // =========================
  // UPDATE USER PROFILE
  // =========================
  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to update profile: ${response.body}");
  }

  // =========================
  // UPLOAD PROFILE PHOTO
  // =========================
  static Future<Map<String, dynamic>> uploadPhotoBytes(
    String token,
    Uint8List bytes,
    String filename,
  ) async {
    final uri     = Uri.parse('$baseUrl/profile/photo');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Photo upload failed: ${response.body}");
  }

  // =========================
  // GET ALL USERS
  // =========================
  static Future<List<dynamic>?> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("USERS RESPONSE: ${response.body}");

      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      print("Get Users Error: $e");
      return null;
    }
  }

  // =========================
  // CREATE USER
  // =========================
  static Future<void> createUser(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  // =========================
  // UPDATE USER (admin)
  // =========================
  static Future<void> updateUser(
    String token,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  // =========================
  // DELETE USER
  // =========================
  static Future<void> deleteUser(String token, String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete user");
    }
  }

  // =========================
  // ATTENDANCE — GET
  // Returns Map<String, String>  e.g. { "2025-05-01": "present", ... }
  // =========================
  static Future<Map<String, String>> getAttendance(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance'),
        headers: {"Authorization": "Bearer $token"},
      );

      print("ATTENDANCE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);

        // Accept either a plain Map or a list of {date, status} objects
        if (raw is Map) {
          return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
        }

        if (raw is List) {
          final Map<String, String> result = {};
          for (final item in raw) {
            final date   = item['date']?.toString()   ?? '';
            final status = item['status']?.toString() ?? '';
            if (date.isNotEmpty && status.isNotEmpty) {
              result[date] = status;
            }
          }
          return result;
        }

        return {};
      }

      print("Attendance Error: ${response.body}");
      return {};
    } catch (e) {
      print("getAttendance Exception: $e");
      return {};
    }
  }

  // =========================
  // ATTENDANCE — MARK / CLEAR
  // Pass status="" to clear the record for that date
  // =========================
  static Future<void> markAttendance(
    String token,
    String date,
    String status,
  ) async {
    try {
      // Empty status means the user wants to clear the record
      if (status.isEmpty) {
        await http.delete(
          Uri.parse('$baseUrl/attendance/$date'),
          headers: {"Authorization": "Bearer $token"},
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {
          "Content-Type":  "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"date": date, "status": status}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("markAttendance Error: ${response.body}");
      }
    } catch (e) {
      print("markAttendance Exception: $e");
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // VERIFY OTP
  // =========================
  static Future<bool> verifyOTP(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return res.statusCode == 200;
  }

  // =========================
  // RESET PASSWORD
  // =========================
  static Future<bool> resetPassword(String email, String newPassword) async {
    final res = await http.post(
      Uri.parse("$baseUrl/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "new_password": newPassword}),
    );

    print("RESET STATUS: ${res.statusCode}");
    print("RESET BODY: ${res.body}");

    return res.statusCode == 200;
  }

  // =========================
  // DEPARTMENTS — GET
  // =========================
  static Future<List<dynamic>> getDepartments(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/departments"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(res.body);
  }

  // =========================
  // DEPARTMENTS — CREATE
  // =========================
  static Future<bool> createDepartment(
    String token,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/departments"),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  // =========================
  // DEPARTMENTS — UPDATE
  // =========================
  static Future<bool> updateDepartment(
    String token,
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/departments/$id"),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // =========================
  // DEPARTMENTS — DELETE
  // =========================
  static Future<bool> deleteDepartment(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/departments/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // ADMIN PROFILE — UPDATE
  // =========================
  static Future<bool> updateAdminProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final res = await http.put(
      Uri.parse("$baseUrl/admin/profile"),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // =========================
  // SEND REGISTRATION OTP
  // =========================
  static Future<Map<String, dynamic>?> sendRegistrationOtp(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send-registration-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print("Send OTP error: $e");
      return null;
    }
  }

  // =========================
  // VERIFY REGISTRATION OTP
  // =========================
  static Future<http.Response> verifyRegistrationOtp(
    String email,
    String otp,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-registration-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    return res;
  }
}