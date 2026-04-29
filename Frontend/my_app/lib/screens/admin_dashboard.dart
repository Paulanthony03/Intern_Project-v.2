import 'package:flutter/material.dart';
import 'package:my_app/screens/landing_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final String token;
  final List<dynamic>? users;
  final List<Map<String, dynamic>> departments;
  final Future<void> Function()? onRefresh;

  const AdminDashboard({
    Key? key,
    required this.token,
    this.users,
    required this.departments,
    this.onRefresh,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ─── STATE ───────────────────────────────────────────────
  List<dynamic>? get users => widget.users;
  String fullName = "";
  String currentUserId = "";
  String searchQuery = "";
  int get departmentCount => widget.departments.length;
  int? hoveredIndex;

  // ─── FILTER STATE ────────────────────────────────────────
  String? selectedDepartment;
  String? selectedSchool;

  // ─── COLORS ──────────────────────────────────────────────
  final Color pageBg = const Color(0xFF1A1A1A);
  final Color sidebarBg = const Color(0xFF111111);
  final Color headerBg = const Color(0xFF1E1E1E);
  final Color cardBg = const Color(0xFF222222);
  final Color accent = const Color.fromARGB(255, 212, 226, 74);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);

  // ─── INIT ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final name =
        prefs.getString("full_name") ??
        prefs.getString("name") ??
        prefs.getString("username") ??
        "Admin";

    final userId = prefs.getString("user_id") ?? "";

    setState(() {
      fullName = name;
      currentUserId = userId;
    });
  }

  // ─── COMPUTED ────────────────────────────────────────────
  int get schoolCount {
    if (users == null) return 0;
    return users!.map((u) => (u["school"] ?? "")).toSet().length;
  }

  List<String> get allDepartments {
    if (users == null) return [];
    final list = users!
        .map((u) => (u["department"] ?? u["dept"] ?? "").toString().trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<String> get allSchools {
    if (users == null) return [];
    final list = users!
        .map((u) => (u["school"] ?? "").toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<dynamic> get filteredUsers {
    if (users == null) return [];
    return users!.where((u) {
      final name = (u["name"] ?? "").toLowerCase();
      final id = (u["intern_id"] ?? u["id"] ?? "").toString().toLowerCase();
      final matchSearch =
          searchQuery.isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());

      final dept = (u["department"] ?? u["dept"] ?? "").toString().trim();
      final matchDept =
          selectedDepartment == null || dept == selectedDepartment;

      final school = (u["school"] ?? "").toString().trim();
      final matchSchool = selectedSchool == null || school == selectedSchool;

      return matchSearch && matchDept && matchSchool;
    }).toList();
  }

  List<dynamic> get recentUsers {
    if (users == null || users!.isEmpty) return [];
    return List<dynamic>.from(users!).take(2).toList();
  }

  // ════════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════════
  Future<void> Logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LandingScreen()),
              );
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

  // ─── VIEW PROFILE DIALOG ─────────────────────────────────
  void showProfileDialog(Map<String, dynamic> user, int internNumber) {
    final String name = (user["name"] ?? "Unknown").toUpperCase();
    final String? photoUrl = user["photo_url"];

    final List<Map<String, String>> fields = [
      {"label": "Intern ID", "value": user["intern_id"]?.toString() ?? "-"},
      {"label": "Email", "value": user["email"]?.toString() ?? "-"},
      {"label": "School", "value": user["school"]?.toString() ?? "-"},
      {"label": "Program", "value": user["program"]?.toString() ?? "-"},
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
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
                                "Intern $internNumber",
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

                    ...fields.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _infoRow(f["label"]!, f["value"]!),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            '/edit-profile',
                            arguments: user,
                          );
                        },
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: pageBg,
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

  // ─── DELETE DIALOG ───────────────────────────────────────
  void showDeleteDialog(Map<String, dynamic> user) {
    final String name = user["name"] ?? "this intern";
    final String userId = user["id"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Intern",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete $name?\nThis cannot be undone.",
          style: TextStyle(color: textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteUser(widget.token, userId.toString());
                await widget.onRefresh?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name has been deleted."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete: $e"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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

  String timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year${(diff.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  // ════════════════════════════════════════════════════════
  //  STAT CARD
  // ════════════════════════════════════════════════════════
  Widget buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 12, color: textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user["name"] ?? "");
    final emailCtrl = TextEditingController(text: user["email"] ?? "");
    final schoolCtrl = TextEditingController(text: user["school"] ?? "");
    final programCtrl = TextEditingController(text: user["program"] ?? "");
    final deptCtrl = TextEditingController(
      text: user["department"] ?? user["dept"] ?? "",
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
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
                      Text(
                        "Edit intern profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Changes will be saved to the server.",
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: borderColor),
                      const SizedBox(height: 16),

                      _editField("Full name", nameCtrl),
                      const SizedBox(height: 12),
                      _editField("Email", emailCtrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _editField("School", schoolCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _editField("Program", programCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _editField("Department", deptCtrl),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      setLocal(() => isSaving = true);
                                      try {
                                        final updatedData = {
                                          "name": nameCtrl.text.trim(),
                                          "email": emailCtrl.text.trim(),
                                          "school": schoolCtrl.text.trim(),
                                          "program": programCtrl.text.trim(),
                                          "department": deptCtrl.text.trim(),
                                        };
                                        final userId =
                                            user["id"]?.toString() ?? "";
                                        await ApiService.updateUser(
                                          widget.token,
                                          userId,
                                          updatedData,
                                        );
                                        await widget.onRefresh?.call();
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${nameCtrl.text} updated successfully.",
                                            ),
                                            backgroundColor: accent,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Failed to save: $e"),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      } finally {
                                        setLocal(() => isSaving = false);
                                      }
                                    },
                              child: isSaving
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: pageBg,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Save changes",
                                      style: TextStyle(
                                        color: pageBg,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          style: TextStyle(color: textMain, fontSize: 13),
          cursorColor: accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: pageBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accent),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  RECENTLY ADDED INTERNS
  // ════════════════════════════════════════════════════════
  Widget buildRecentPanel() {
    final recent = recentUsers;
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
            "Recently Added Interns",
            style: TextStyle(
              color: textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (recent.isEmpty)
            Text(
              "No interns yet.",
              style: TextStyle(color: textMuted, fontSize: 13),
            )
          else
            ...recent.asMap().entries.map((e) {
              final user = e.value as Map<String, dynamic>;

              final name = user["name"] ?? "Unknown";
              final id = user["intern_id"] ?? user["id"] ?? "-";
              final photoUrl = user["photo_url"] as String?;
              final String? createdAt = user["created_at"];

              DateTime time;

              try {
                String raw = (createdAt ?? "").toString();
                raw = raw.replaceFirst(" ", "T");
                if (raw.endsWith("+08")) {
                  raw = raw + ":00";
                }
                time = DateTime.parse(raw);
              } catch (e) {
                print("Invalid date: $createdAt");
                time = DateTime.now();
              }

              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: borderColor,
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Icon(Icons.person, size: 18, color: textMuted)
                            : null,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: textMain,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timeAgo(time),
                              style: TextStyle(color: textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "id: $id",
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),

                  if (e.key < recent.length - 1)
                    Divider(color: borderColor, height: 20),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DEPARTMENT OVERVIEW
  // ════════════════════════════════════════════════════════
  Widget buildDepartmentOverview() {
    final now = DateTime.now();
    final ongoing = widget.departments.where((d) {
      final start = DateTime.parse(d['start_date']);
      final end = DateTime.parse(d['end_date']);
      return !now.isBefore(start) && !now.isAfter(end);
    }).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Department Overview",
                style: TextStyle(
                  color: textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ongoing.length} ongoing',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (ongoing.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No ongoing departments.',
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 97,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ongoing.length,
                itemBuilder: (context, index) {
                  final dept = ongoing[index];
                  final name = (dept['department_name'] ?? '').toString();
                  final supervisor = (dept['supervisor_name'] ?? '').toString();
                  final role = (dept['role'] ?? 'Supervisor').toString();
                  final isLast = index == ongoing.length - 1;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: textMain,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'ongoing',
                                  style: TextStyle(color: accent, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: textMuted,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supervisor,
                                  style: TextStyle(
                                    color: textMain,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  role.toLowerCase(),
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (!isLast) ...[
                        const SizedBox(height: 14),
                        Divider(color: borderColor, height: 1),
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              ),
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
              ],
            ),

            const Spacer(),

            Row(
              children: [
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
                      "View Profile",
                      style: TextStyle(
                        color: pageBg,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () => showEditDialog(user),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accent.withOpacity(0.5)),
                    ),
                    child: Icon(Icons.edit_rounded, size: 14, color: accent),
                  ),
                ),

                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => showDeleteDialog(user),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
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
    return _styledDropdown<String?>(
      value: selectedDepartment,
      hint: "All Departments",
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            "All Departments",
            style: TextStyle(color: textMain, fontSize: 13),
          ),
        ),
        ...allDepartments.map(
          (d) => DropdownMenuItem<String?>(
            value: d,
            child: Text(
              d,
              style: TextStyle(color: textMain, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => selectedDepartment = val),
    );
  }

  Widget _buildSchoolDropdown() {
    return _styledDropdown<String?>(
      value: selectedSchool,
      hint: "All Schools",
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            "All Schools",
            style: TextStyle(color: textMain, fontSize: 13),
          ),
        ),
        ...allSchools.map(
          (s) => DropdownMenuItem<String?>(
            value: s,
            child: Text(
              s,
              style: TextStyle(color: textMain, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => selectedSchool = val),
    );
  }

  Widget _styledDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            value: value,
            hint: Text(hint, style: TextStyle(color: textMain, fontSize: 13)),
            style: TextStyle(color: textMain, fontSize: 13),
            items: items,
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.zero,
              height: 40,
            ),
            iconStyleData: IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down, color: textMuted, size: 20),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2A2A2A),
              ),
              offset: const Offset(0, 0),
              direction: DropdownDirection.textDirection,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final filtered = filteredUsers;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildStatCard(
                        (users?.length ?? 0).toString().padLeft(2, '0'),
                        "Total Interns",
                        Icons.people_alt_rounded,
                      ),
                      buildStatCard(
                        departmentCount.toString().padLeft(2, '0'),
                        "Total Deptartmets",
                        Icons.folder_rounded,
                      ),
                      buildStatCard(
                        schoolCount.toString().padLeft(2, '0'),
                        "Partner Schools",
                        Icons.account_balance_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: buildRecentPanel()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: buildDepartmentOverview()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: TextField(
                                  cursorColor: const Color.fromARGB(
                                    114,
                                    114,
                                    114,
                                    114,
                                  ),
                                  onChanged: (val) =>
                                      setState(() => searchQuery = val),
                                  style: TextStyle(
                                    color: textMain,
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search for intern name or id....",
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: textMuted,
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 180,
                              child: _buildDepartmentDropdown(),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(width: 180, child: _buildSchoolDropdown()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.add, color: pageBg, size: 20),
                            label: Text(
                              "Add Intern",
                              style: TextStyle(
                                color: pageBg,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const AddInternDialog(),
                              );
                              if (result == true) {
                                await widget.onRefresh?.call();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                "No interns found.",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.9,
                                  ),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => buildProfileCard(
                                filtered[i] as Map<String, dynamic>,
                                i,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: buildRecentActivity()),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} // ← END of _AdminDashboardState

// ════════════════════════════════════════════════════════
//  ADD INTERN DIALOG — outside of _AdminDashboardState
// ════════════════════════════════════════════════════════
class AddInternDialog extends StatefulWidget {
  const AddInternDialog({super.key});

  @override
  State<AddInternDialog> createState() => _AddInternDialogState();
}

class _AddInternDialogState extends State<AddInternDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Color pageBg = const Color(0xFF1A1A1A);
  final Color cardBg = const Color(0xFF222222);
  final Color accent = const Color.fromARGB(255, 212, 226, 74);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // TODO: call your ApiService.register(...) here
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          style: TextStyle(color: textMain, fontSize: 13),
          cursorColor: accent,
          decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: pageBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '$label is required';
            if (label == 'Email' &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return 'Enter a valid email';
            }
            if (label == 'Password' && v.length < 6) {
              return 'Minimum 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Intern',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details for the new intern.',
                      style: TextStyle(fontSize: 12, color: textMuted),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: borderColor),
                    const SizedBox(height: 16),

                    _field(
                      'Full Name',
                      _nameController,
                      keyboard: TextInputType.name,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'Email',
                      _emailController,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'Password',
                      _passwordController,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: textMuted,
                          size: 18,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      color: pageBg,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Add Intern',
                                    style: TextStyle(
                                      color: pageBg,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Icon(Icons.close, color: textMuted, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
