import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_department_page.dart';

class UserDashboard extends StatefulWidget {
  final String token;

  const UserDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // ─── STATE ───────────────────────────────────────────────
  Map<String, dynamic>? userProfile;
  List<dynamic>? allUsers;
  bool isLoading = true;
  bool isSaving = false;
  bool get isAdmin {
    final role = (userProfile?["role"] ?? userProfile?["user_type"] ?? "")
        .toString()
        .toLowerCase();
    return role == "admin";
  }

  List<Map<String, dynamic>> departments = [
    {
      "name": "Development Unit",
      "status": "Ongoing",
      "grade": 90,
      "supervisor": "Lery Villanueva",
    },
    {
      "name": "Tech Support",
      "status": "Finished",
      "grade": 85,
      "supervisor": "Rayven Dela Cruz",
    },
    {
      "name": "QA",
      "status": "Finished",
      "grade": 88,
      "supervisor": "Renzy Rivera",
    },
    {
      "name": "PMO",
      "status": "Finished",
      "grade": 87,
      "supervisor": "Lea Rose Arellano-Rosario",
    },
    {
      "name": "BRM",
      "status": "Finished",
      "grade": 89,
      "supervisor": "Raymond Villapando",
    },
  ];

  String searchQuery = "";
  String? selectedDepartment;
  String? selectedSchool;
  int? hoveredIndex;
  String _selectedNav = 'dashboard';

  // Edit controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _schoolController;
  late TextEditingController _departmentController;

  // ─── COLORS ──────────────────────────────────────────────
  final Color pageBg = const Color(0xFF1A1A1A);
  final Color sidebarBg = const Color(0xFF111111);
  final Color headerBg = const Color(0xFF1E1E1E);
  final Color cardBg = const Color(0xFF222222);
  final Color accent = const Color(0xFFBFCF33);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);

  // ─── INIT ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _contactController = TextEditingController();
    _schoolController = TextEditingController();
    _departmentController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _schoolController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  // ─── LOAD DATA ───────────────────────────────────────────
  Future<void> loadData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? widget.token;

    try {
      final profile = await ApiService.getProfile(token);
      if (profile != null) _populateControllers(profile);

      final users = await ApiService.getUsers(token);
      final seen = <String>{};
      final deduped = users?.where((u) {
        final id = u["id"]?.toString() ?? "";
        return seen.add(id);
      }).toList();

      final internsOnly = deduped?.where((u) {
        final role = (u["role"] ?? u["user_type"] ?? "")
            .toString()
            .toLowerCase();
        return role != "admin";
      }).toList();

      setState(() {
        userProfile = profile;
        allUsers = internsOnly;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    _nameController.text = data["name"] ?? "";
    _emailController.text = data["email"] ?? "";
    _contactController.text = data["contact"] ?? data["contact_no"] ?? "";
    _schoolController.text = data["school"] ?? "";
    _departmentController.text = data["department"] ?? data["dept"] ?? "";
  }

  // ─── COMPUTED ────────────────────────────────────────────
  List<String> get allDepartments {
    if (allUsers == null) return [];
    return allUsers!
        .map((u) => (u["department"] ?? u["dept"] ?? "").toString().trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get allSchools {
    if (allUsers == null) return [];
    return allUsers!
        .map((u) => (u["school"] ?? "").toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<dynamic> get filteredUsers {
    if (allUsers == null) return [];
    var list = allUsers!.where((u) {
      final name = (u["name"] ?? "").toLowerCase();
      final id = (u["intern_id"] ?? u["id"] ?? "").toString().toLowerCase();
      final matchSearch =
          searchQuery.isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());
      final school = (u["school"] ?? "").toString().trim();
      final matchSchool = selectedSchool == null || school == selectedSchool;
      return matchSearch && matchSchool;
    }).toList();

    switch (selectedDepartment) {
      case "name_asc":
        list.sort((a, b) => (a["name"] ?? "").compareTo(b["name"] ?? ""));
        break;
      case "name_desc":
        list.sort((a, b) => (b["name"] ?? "").compareTo(a["name"] ?? ""));
        break;
      case "id_asc":
        list.sort((a, b) {
          final aId =
              int.tryParse((a["intern_id"] ?? a["id"] ?? "").toString()) ?? 0;
          final bId =
              int.tryParse((b["intern_id"] ?? b["id"] ?? "").toString()) ?? 0;
          return aId.compareTo(bId);
        });
        break;
      case "id_desc":
        list.sort((a, b) {
          final aId =
              int.tryParse((a["intern_id"] ?? a["id"] ?? "").toString()) ?? 0;
          final bId =
              int.tryParse((b["intern_id"] ?? b["id"] ?? "").toString()) ?? 0;
          return bId.compareTo(aId);
        });
        break;
    }

    return list;
  }

  List<dynamic> get recentUsers {
    if (allUsers == null || allUsers!.isEmpty) return [];
    return List<dynamic>.from(allUsers!).reversed.take(2).toList();
  }

  int get schoolCount {
    if (allUsers == null) return 0;
    return allUsers!.map((u) => (u["school"] ?? "")).toSet().length;
  }

  int get departmentCount {
    return departments.length;
  }

  String get internshipDuration {
    return "450 hours";
  }

  // ─── SAVE PROFILE ────────────────────────────────────────
  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? widget.token;
    final userId =
        userProfile?["id"]?.toString() ??
        userProfile?["user_id"]?.toString() ??
        prefs.getString("user_id") ??
        "";

    final updated = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "contact": _contactController.text.trim(),
      "school": _schoolController.text.trim(),
      "department": _departmentController.text.trim(),
    };

    print("=== SAVING PROFILE ===");
    print("userId: $userId");
    print("token: $token");
    print("updated: $updated");

    try {
      print("=== SAVING PROFILE ===");
      print("userId: $userId");
      print("token: $token");
      print("updated: $updated");

      await ApiService.updateProfile(token, updated);
      print("=== UPDATE DONE ===");

      await loadData();
      print("=== PROFILE AFTER RELOAD: $userProfile ===");
    } catch (e) {
      print("=== SAVE ERROR: $e ===");
      setState(() => isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────
  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Log Out",
          style: TextStyle(color: accent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("No", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              "Yes",
              style: TextStyle(color: pageBg, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── VIEW PROFILE DIALOG (read-only for other interns) ───
  void showProfileDialog(Map<String, dynamic> user, int internNumber) {
    final String name = (user["name"] ?? "Unknown").toUpperCase();
    final String school = user["school"] ?? "-";
    final String email = user["email"] ?? "-";
    final String contact = user["contact"] ?? user["contact_no"] ?? "-";
    final String department = user["department"] ?? user["dept"] ?? "-";
    final String? photoUrl = user["photo_url"];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: borderColor,
                          backgroundImage:
                              photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  (user["name"] ?? "U")[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Intern #$internNumber",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: borderColor),
                    const SizedBox(height: 16),
                    _infoRow("School:", school),
                    const SizedBox(height: 12),
                    _infoRow("Department:", department),
                    const SizedBox(height: 12),
                    _infoRow("Email:", email),
                    const SizedBox(height: 12),
                    _infoRow("Contact No.:", contact),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borderColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDepartmentDialog(String name, String status, String grade) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: accent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Department Details",
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),

                    const SizedBox(height: 16),
                    Divider(color: borderColor),

                    const SizedBox(height: 16),

                    _infoRow("Status:", status),
                    const SizedBox(height: 12),
                    _infoRow("Grade:", grade), // ✅ FIXED
                    const SizedBox(height: 12),
                    _infoRow("Supervisor:", "Lery Villanueva"),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: pageBg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditGradeDialog(int index) {
    final controller = TextEditingController(
      text: departments[index]["grade"].toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Grade",
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  hintText: "Enter grade",
                  hintStyle: TextStyle(color: textMuted),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text("Cancel", style: TextStyle(color: textMuted)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accent),
                      onPressed: () {
                        setState(() {
                          departments[index]["grade"] =
                              int.tryParse(controller.text) ?? 0;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text("Save", style: TextStyle(color: pageBg)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EDIT OWN PROFILE DIALOG ─────────────────────────────
  Future<void> showEditOwnProfileDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit My Profile",
                      style: TextStyle(
                        color: accent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Only you can edit your own profile.",
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: borderColor),
                    const SizedBox(height: 16),
                    _editField(
                      "Full Name",
                      _nameController,
                      Icons.person_rounded,
                    ),
                    const SizedBox(height: 14),
                    _editField("Email", _emailController, Icons.email_rounded),
                    const SizedBox(height: 14),
                    _editField(
                      "Contact No.",
                      _contactController,
                      Icons.phone_rounded,
                    ),
                    const SizedBox(height: 14),
                    _editField(
                      "School",
                      _schoolController,
                      Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 14),
                    _editField(
                      "Department",
                      _departmentController,
                      Icons.folder_rounded,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: borderColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (userProfile != null) {
                                _populateControllers(userProfile!);
                              }
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatefulBuilder(
                            builder: (context, setDialogState) =>
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          Navigator.pop(ctx);
                                          await saveProfile();
                                        },
                                  child: isSaving
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: pageBg,
                                          ),
                                        )
                                      : Text(
                                          "Save Changes",
                                          style: TextStyle(
                                            color: pageBg,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: textMain, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 16, color: accent),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accent,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: textMain, fontSize: 13)),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  MY PROFILE PAGE
  // ════════════════════════════════════════════════════════
  Widget buildMyProfile() {
    if (userProfile == null) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    final name = userProfile!["name"] ?? "User";
    final email = userProfile!["email"] ?? "-";
    final school = userProfile!["school"] ?? "-";
    final department =
        userProfile!["department"] ?? userProfile!["dept"] ?? "-";
    final contact =
        userProfile!["contact"] ?? userProfile!["contact_no"] ?? "-";
    final String? photoUrl = userProfile!["photo_url"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: borderColor,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: accent)
                      : null,
                ),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(email, style: TextStyle(color: textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Divider(color: borderColor),
            const SizedBox(height: 20),
            _infoRow("School:", school),
            const SizedBox(height: 12),
            _infoRow("Department:", department),
            const SizedBox(height: 12),
            _infoRow("Email:", email),
            const SizedBox(height: 12),
            _infoRow("Contact:", contact),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await showEditOwnProfileDialog();
                if (mounted) setState(() {});
              },
              child: Text(
                "Edit Profile",
                style: TextStyle(color: pageBg, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SIDEBAR
  // ════════════════════════════════════════════════════════
  Widget buildSidebar() {
    final name = userProfile?["name"] ?? "User";
    final internId = userProfile?["intern_id"] ?? userProfile?["id"] ?? "-";
    final photoUrl = userProfile?["photo_url"] as String?;

    return Container(
      width: 210,
      color: sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Image.asset('../assets/images/mylogo.png', height: 36),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "blacky",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "intern portal",
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          // User avatar card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: borderColor,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Icon(Icons.person, size: 18, color: accent)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textMain,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "id: $internId",
                          style: TextStyle(color: textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          _navItem(Icons.dashboard_rounded, "Dashboard", 'dashboard'),
          _navItem(Icons.person_rounded, "My Profile", 'profile'),
          _navItem(Icons.person_rounded, "Departments", 'departments'),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
            child: GestureDetector(
              onTap: showLogoutDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    String key, {
    VoidCallback? onTap,
  }) {
    final bool selected = _selectedNav == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNav = key);
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: accent.withOpacity(0.4))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: selected ? accent : textMuted),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? accent : textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TOP BAR
  // ════════════════════════════════════════════════════════
  Widget buildTopBar() {
    final name = userProfile?["name"] ?? "User";
    final String? photoUrl = userProfile?["photo_url"];

    return Container(
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Text(
            "Welcome Back, ${name.toString().toUpperCase()}!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Own profile shortcut
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: borderColor,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Icon(Icons.person, color: accent, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                  color: textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  RECENT ACTIVITY
  // ════════════════════════════════════════════════════════
  Widget buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: TextStyle(
              color: textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: borderColor, height: 24),
          Center(
            child: Text(
              "no new notifications",
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  INTERN CARD
  // ════════════════════════════════════════════════════════
  Widget buildProfileCard(Map<String, dynamic> user, int index) {
    final String name = user["name"] ?? "Unknown";
    final String internId =
        user["intern_id"]?.toString() ?? user["id"]?.toString() ?? "-";
    final String? photoUrl = user["photo_url"];
    final bool isHovered = hoveredIndex == index;

    final String myId =
        userProfile?["id"]?.toString() ??
        userProfile?["user_id"]?.toString() ??
        "";
    final String cardUserId = user["id"]?.toString() ?? "";
    final bool isOwnCard = myId.isNotEmpty && myId == cardUserId;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isHovered
              ? Border.all(color: accent, width: 1.5)
              : Border.all(color: borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: borderColor,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(Icons.person, size: 24, color: textMuted)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "id: $internId",
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ),
                if (isOwnCard)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accent.withOpacity(0.5)),
                    ),
                    child: Text(
                      "You",
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () => showProfileDialog(user, index + 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOwnCard ? "View Profile" : "View Profile",
                      style: TextStyle(
                        color: pageBg,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DROPDOWNS
  // ════════════════════════════════════════════════════════
  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDepartment,
          hint: Text(
            "Sort By",
            style: TextStyle(color: textMain, fontSize: 13),
          ),
          dropdownColor: const Color(0xFF2A2A2A),
          iconEnabledColor: textMuted,
          iconSize: 20,
          style: TextStyle(color: textMain, fontSize: 13),
          items: [
            DropdownMenuItem(
              value: "name_asc",
              child: Text(
                "Name (A-Z)",
                style: TextStyle(color: textMain, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: "name_desc",
              child: Text(
                "Name (Z-A)",
                style: TextStyle(color: textMain, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: "id_asc",
              child: Text(
                "ID (Ascending)",
                style: TextStyle(color: textMain, fontSize: 13),
              ),
            ),
            DropdownMenuItem(
              value: "id_desc",
              child: Text(
                "ID (Descending)",
                style: TextStyle(color: textMain, fontSize: 13),
              ),
            ),
          ],
          onChanged: (val) => setState(() => selectedDepartment = val),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  STAT CARDS ROW
  // ════════════════════════════════════════════════════════
  Widget buildStatCard(
    String number,
    String label,
    IconData icon, {
    bool isLast = false,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DASHBOARD PAGE (full, self-contained)
  // ════════════════════════════════════════════════════════
  Widget buildDashboard() {
    final filtered = filteredUsers;

    return Column(
      children: [
        // Stat cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              buildStatCard(
                (allUsers?.length ?? 0).toString().padLeft(2, '0'),
                "Total Interns",
                Icons.people_alt_rounded,
              ),
              buildStatCard(
                departmentCount.toString().padLeft(2, '0'),
                "Total Depts.",
                Icons.folder_rounded,
              ),
              buildStatCard(
                internshipDuration,
                "Duration",
                Icons.timer_rounded,
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Search + filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    style: TextStyle(color: textMain, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search for intern name or id....",
                      hintStyle: TextStyle(fontSize: 12, color: textMuted),
                      prefixIcon: Icon(
                        Icons.search,
                        color: textMuted,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildDepartmentDropdown(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Intern grid + recent activity
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            "No interns found.",
                            style: TextStyle(color: textMuted, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              height: 140, // 👉 controls "long box" height
                              child: buildProfileCard(
                                filtered[i] as Map<String, dynamic>,
                                i,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: buildRecentActivity()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accent))
          : Row(
              children: [
                // SIDEBAR
                buildSidebar(),

                // MAIN CONTENT
                Expanded(
                  child: Column(
                    children: [
                      buildTopBar(),
                      Expanded(
                        child: _selectedNav == 'dashboard'
                            ? buildDashboard()
                            : _selectedNav == 'profile'
                            ? buildMyProfile()
                            : DepartmentPage(
                                departments: departments,
                                isAdmin: isAdmin,
                                onEditGrade: showEditGradeDialog,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
