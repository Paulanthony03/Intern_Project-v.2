import 'package:flutter/material.dart';
import 'package:my_app/screens/landing_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final String token;

  const AdminDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ─── STATE ───────────────────────────────────────────────
  List<dynamic>? users;
  String fullName = "";
  String currentUserId = "";
  String searchQuery = "";
  int departmentCount = 5;
  int? hoveredIndex;

  // Sidebar: is the Admin dropdown expanded?
  bool _adminMenuExpanded = true;
  // Which nav item is highlighted
  String _selectedNav = 'dashboard';

  // ─── FILTER STATE ────────────────────────────────────────
  String? selectedDepartment;
  String? selectedSchool;

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
    loadUsers();
  }

  // ─── LOAD USERS ──────────────────────────────────────────
  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final name =
        prefs.getString("full_name") ??
        prefs.getString("name") ??
        prefs.getString("username") ??
        "Admin";
    final userId = prefs.getString("user_id") ?? "";
    final savedDept = prefs.getInt("department_count");

    if (token != null) {
      final data = await ApiService.getUsers(token);

      final seen = <String>{};
      final deduped = data?.where((u) {
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
        users = internsOnly;
        fullName = name;
        currentUserId = userId;
        if (savedDept != null) departmentCount = savedDept;
      });
    }
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return "${diff.inDays} days ago";
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

    List<dynamic> sorted = List.from(users!);

    sorted.sort((a, b) {
      DateTime parseDate(dynamic val) {
        try {
          String raw = (val ?? "").toString();

          raw = raw.replaceFirst(" ", "T");

          if (raw.endsWith("+08")) {
            raw = raw + ":00";
          }

          return DateTime.parse(raw);
        } catch (_) {
          return DateTime(2000); // fallback old date
        }
      }

      final aDate = parseDate(a["created_at"]);
      final bDate = parseDate(b["created_at"]);

      return bDate.compareTo(aDate); // 🔥 newest FIRST
    });

    return sorted.take(2).toList();
  }

  // ════════════════════════════════════════════════════════
  //  LOGOUT — clears prefs and goes directly to /login
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
    final String school = user["school"] ?? "-";
    final String email = user["email"] ?? "-";
    final String contact = user["contact"] ?? user["contact_no"] ?? "-";
    final String? photoUrl = user["photo_url"];

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
                    // Avatar + name row
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
                    _infoRow("School:", school),
                    const SizedBox(height: 12),
                    _infoRow("Email:", email),
                    const SizedBox(height: 12),
                    _infoRow("Contact No.:", contact),
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
              // Close button
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
              Navigator.of(ctx).pop(); // close dialog FIRST

              await Future.delayed(
                Duration(milliseconds: 100),
              ); // ensures UI clears

              try {
                await ApiService.deleteUser(widget.token, userId.toString());
                await loadUsers();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name has been deleted."),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete: $e"),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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

  // ════════════════════════════════════════════════════════
  //  SIDEBAR — Admin tile is a real animated dropdown
  // ════════════════════════════════════════════════════════
  Widget buildSidebar() {
    return Container(
      width: 210,
      color: sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + brand
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
                      "Blacky",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          // ── Admin dropdown tile ──────────────────────
          _buildAdminDropdownTile(),

          const SizedBox(height: 8),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 8),

          // ── Nav items (shown always, but can be inside dropdown) ──
          // Per the request: the Admin dropdown contains all items below it.
          // We show them as an animated expanding section.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _adminMenuExpanded ? 1.0 : 0.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _adminMenuExpanded ? 1 : 0,
                  child: Column(
                    children: [
                      _navItem(
                        Icons.dashboard_rounded,
                        "Dashboard",
                        'dashboard',
                      ),
                      _navItem(Icons.people_alt_rounded, "Interns", 'interns'),
                      _navItem(
                        Icons.folder_rounded,
                        "Departments",
                        'departments',
                      ),
                      _navItem(
                        Icons.account_balance_rounded,
                        "School",
                        'school',
                      ),
                      _navItem(Icons.settings_rounded, "Settings", 'settings'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Logout button ────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
            child: GestureDetector(
              onTap: showLogoutDialog, // shows confirm dialog → then /login
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
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 10),
                    const Text(
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

  // ── Admin dropdown trigger tile ──────────────────────────
  Widget _buildAdminDropdownTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () => setState(() => _adminMenuExpanded = !_adminMenuExpanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: _adminMenuExpanded
                ? Border.all(color: accent.withOpacity(0.4))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: borderColor,
                child: Icon(Icons.person, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "profile",
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _adminMenuExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _adminMenuExpanded ? accent : textMuted,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Individual nav item ──────────────────────────────────
  Widget _navItem(IconData icon, String label, String key) {
    final bool selected = _selectedNav == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNav = key);
          if (key == 'interns') Navigator.pushNamed(context, '/interns');
          if (key == 'departments')
            Navigator.pushNamed(context, '/departments');
          if (key == 'school') Navigator.pushNamed(context, '/schools');
          if (key == 'settings') Navigator.pushNamed(context, '/settings');
          // 'dashboard' stays on this page
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: accent.withOpacity(0.4))
                : Border.all(color: const Color.fromRGBO(0, 0, 0, 0)),
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
    return Container(
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Text(
            "Welcome Back, Admin!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          const Spacer(),
          // Notification bell
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
          // Admin info
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/admin-profile',
              arguments: {"name": fullName},
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: borderColor,
                  child: Icon(Icons.person, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? "Admin Mc" : fullName,
                      style: TextStyle(
                        color: textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "id: admin_08",
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  STAT CARD — read-only, no edit on any card
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
            "Department Overview",
            style: TextStyle(
              color: textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Development Unit",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "ongoing",
                    style: TextStyle(color: accent, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),
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
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mr. Lery Villanueva",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "supervisor",
                    style: TextStyle(color: accent, fontSize: 11),
                  ),
                ],
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
            // ── Top: Avatar + name + id ───────────────
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

            // ── Bottom: View Profile | edit | delete ──
            Row(
              children: [
                // View Profile
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

                // Edit → /edit-profile
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/edit-profile',
                    arguments: user,
                  ),
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

                // Delete → confirm dialog
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
  //  WORKING DROPDOWNS
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
            child: Text(d, style: TextStyle(color: textMain, fontSize: 13)),
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
            child: Text(s, style: TextStyle(color: textMain, fontSize: 13)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: textMain, fontSize: 13)),
          dropdownColor: const Color(0xFF2A2A2A),
          iconEnabledColor: textMuted,
          iconSize: 20,
          style: TextStyle(color: textMain, fontSize: 13),
          items: items,
          onChanged: onChanged,
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

    return Scaffold(
      backgroundColor: pageBg,
      body: users == null
          ? Center(child: CircularProgressIndicator(color: accent))
          : Row(
              children: [
                // ── SIDEBAR ──────────────────────────────
                buildSidebar(),

                // ── MAIN CONTENT ─────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      // Fixed top bar
                      buildTopBar(),

                      // Fixed upper sections
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            // Stat cards (all read-only)
                            Row(
                              children: [
                                buildStatCard(
                                  users!.length.toString().padLeft(2, '0'),
                                  "Total Interns",
                                  Icons.people_alt_rounded,
                                ),
                                buildStatCard(
                                  departmentCount.toString().padLeft(2, '0'),
                                  "Total Depts.",
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

                            // Middle row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 8, child: buildRecentPanel()),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: buildDepartmentOverview(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Search + filter row
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: TextField(
                                      cursorColor: Color.fromARGB(
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 13,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                _buildDepartmentDropdown(),
                                const SizedBox(width: 14),
                                _buildSchoolDropdown(),
                                const SizedBox(width: 14),

                                Expanded(
                                  flex: 4, // 👈 matches 1/3 like the stat cards
                                  child: SizedBox(
                                    height: 44, // 👈 matches search bar height
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        color: pageBg,
                                        size: 20,
                                      ),
                                      label: Text(
                                        "Add Intern",
                                        style: TextStyle(
                                          color: pageBg,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pushNamed(context, ''),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // ── SCROLLABLE INTERN GRID + FIXED RIGHT PANEL ──
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Only intern grid scrolls
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

                              // Recent Activity panel is fixed (not scrolling)
                              Expanded(flex: 4, child: buildRecentActivity()),
                            ],
                          ),
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
