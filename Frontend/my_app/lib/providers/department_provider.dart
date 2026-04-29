import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DepartmentProvider extends ChangeNotifier {
  List<dynamic> _departmentList = [];
  bool isLoading = false;

  List<dynamic> get departments => _departmentList;

  // ─────────────────────────────────────────
  // FETCH FROM DATABASE
  // ─────────────────────────────────────────
  Future<void> fetchDepartments(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getDepartments(token);

      _departmentList = data;
    } catch (e) {
      _departmentList = [];
      debugPrint("Fetch error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // CREATE (SYNC WITH DB)
  // ─────────────────────────────────────────
  Future<bool> createDepartment(String token, Map<String, dynamic> dept) async {
    final success = await ApiService.createDepartment(token, dept);

    if (success) {
      await fetchDepartments(token); // refresh from DB (IMPORTANT)
    }

    return success;
  }

  // ─────────────────────────────────────────
  // UPDATE (SYNC WITH DB)
  // ─────────────────────────────────────────
  Future<bool> updateDepartment(
    String token,
    String id,
    Map<String, dynamic> dept,
  ) async {
    final success = await ApiService.updateDepartment(token, id, dept);

    if (success) {
      await fetchDepartments(token);
    }

    return success;
  }

  // ─────────────────────────────────────────
  // LOCAL HELPERS (OPTIONAL ONLY)
  // ─────────────────────────────────────────
  void setDepartments(List<dynamic> data) {
    _departmentList = data;
    notifyListeners();
  }
}
