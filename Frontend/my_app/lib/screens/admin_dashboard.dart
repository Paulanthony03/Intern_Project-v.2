import 'package:flutter/material.dart';
import 'package:my_app/screens/landing_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final String token;
  final List<dynamic>? users;
  final Future<void> Function()? onRefresh;

  const AdminDashboard({
    Key? key,
    required this.token,
    this.users,
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
  int departmentCount = 5;
  int? hoveredIndex;
 
  // ─── FILTER STATE ────────────────────────────────────────
  String? selectedDepartment;
  String? selectedSchool;

  // ─── COLORS ──────────────────────────────────────────────
  final Color pageBg = const Color(0xFF1A1A1A);
  final Color sidebarBg = const Color(0xFF111111);
  final Color headerBg = const Color(0xFF1E1E1E);
  final Color cardBg = const Color(0xFF222222);
  final Color accent =  const Color.fromARGB(255, 212, 226, 74);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);

  // ─── INIT ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
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
    return List<dynamic>.from(users!).reversed.take(2).toList();
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
              final daysAgo = e.key + 3;
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
                              "$daysAgo days ago",
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
       // Fixed upper sections
           Padding(
               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        // Stat cards
                        Row(
                          children: [
                            buildStatCard(
                               (users?.length ?? 0).toString().padLeft(2, '0'),
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
                            Expanded(flex: 4, child: buildDepartmentOverview()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Search + filter row
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
                                        cursorColor: const Color.fromARGB(114, 114, 114, 114),
                                        onChanged: (val) => setState(() => searchQuery = val),
                                        style: TextStyle(color: textMain, fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: "Search for intern name or id....",
                                          hintStyle: TextStyle(fontSize: 12, color: textMuted),
                                          prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  _buildDepartmentDropdown(),
                                  const SizedBox(width: 14),
                                  _buildSchoolDropdown(),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  onPressed: () => Navigator.pushNamed(context, '/register'),
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
                          Expanded(
                            flex: 8,
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      "No interns found.",
                                      style: TextStyle(color: textMuted, fontSize: 14),
                                    ),
                                  )
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          Expanded(
                            flex: 4,
                            child: buildRecentActivity(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            );
    },
    );
  }
}