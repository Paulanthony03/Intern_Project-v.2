import 'package:flutter/material.dart';
import 'package:my_app/screens/login_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final String token;

  const AdminDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic>? users;
  String fullName = "";
  String currentUserId = "";
  String searchQuery = "";
  int departmentCount = 5;
  int? hoveredIndex;

  final Color pageBg = const Color(0xFF1A1A1A);
  final Color headerBg = const Color(0xFF2A2A2A);
  final Color cardBg = const Color(0xFF2E2E2E);
  final Color accent = const Color(0xFFD4E24A);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF3A3A3A);

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

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

      // 🔹 Filter out admin accounts — only show intern cards
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

  int get schoolCount {
    if (users == null) return 0;
    return users!.map((u) => (u["school"] ?? "")).toSet().length;
  }

  List<dynamic> get filteredUsers {
    if (users == null) return [];
    if (searchQuery.isEmpty) return users!;
    return users!.where((u) {
      final name = (u["name"] ?? "").toLowerCase();
      final id = (u["intern_id"] ?? "").toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());
    }).toList();
  }

  // 🔹 LOGOUT — goes to login/register page
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
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  void showEditDepartmentDialog() {
    final controller = TextEditingController(text: departmentCount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Edit Department Count",
          style: TextStyle(color: accent, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textMain),
          decoration: InputDecoration(
            labelText: "Number of departments",
            labelStyle: TextStyle(color: textMuted),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accent),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accent),
            onPressed: () async {
              final val = int.tryParse(controller.text);
              if (val != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt("department_count", val);
                setState(() => departmentCount = val);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              "Save",
              style: TextStyle(color: pageBg, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 VIEW PROFILE DIALOG
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Intern $internNumber",
                                style: TextStyle(
                                  fontSize: 14,
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

                    // 🔹 Admin can edit any intern's profile
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
                top: 14,
                right: 18,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Text(
                    "X",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 DELETE CONFIRMATION DIALOG
  void showDeleteDialog(Map<String, dynamic> user) {
    final String name = user["name"] ?? "this intern";
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
          "Are you sure you want to delete $name? This cannot be undone.",
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
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString("token");

                if (token != null) {
                  await ApiService.deleteUser(
                    token,
                    int.parse(user['id'].toString()),
                  );

                  setState(() {
                    users!.removeWhere((u) => u['id'] == user['id']);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$name has been deleted.")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Delete failed")));
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
          width: 100,
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

  // 🔹 HEADER — dropdown with Profile and Logout only
  Widget buildHeader() {
    return Container(
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // LEFT — logo + site name
          Image.asset('../assets/images/mylogo.png', height: 36),
          const SizedBox(width: 10),
          Text(
            "Blacky",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textMain,
              letterSpacing: 1,
            ),
          ),

          // MIDDLE — empty spacer
          const Spacer(),

          // RIGHT — dropdown menu
          PopupMenuButton<String>(
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor),
            ),
            offset: const Offset(0, 52),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(
                  context,
                  '/admin-profile',
                  arguments: {"name": fullName},
                );
              } else if (value == 'logout') {
                showLogoutDialog();
              }
            },
            itemBuilder: (ctx) => [
              // Profile card at top of dropdown
              PopupMenuItem(
                enabled: false,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: borderColor,
                      child: Icon(Icons.person, size: 28, color: accent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fullName,
                      style: TextStyle(
                        color: textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Administrator",
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              PopupMenuDivider(height: 1),

              // View admin profile
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      color: accent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "My Profile",
                      style: TextStyle(color: textMain, fontSize: 13),
                    ),
                  ],
                ),
              ),

              PopupMenuDivider(height: 1),

              // Logout
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 10),
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
            ],

            child: Row(
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.account_circle, color: accent, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 STAT CARD
  Widget buildStatCard(
    String value,
    String label, {
    bool adminEditable = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: adminEditable ? showEditDepartmentDialog : null,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (adminEditable) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.edit, size: 12, color: accent),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 INTERN CARD — edit & delete icons appear on hover
  Widget buildProfileCard(Map<String, dynamic> user, int index) {
    final String name = user["name"] ?? "Unknown";
    final String? photoUrl = user["photo_url"];
    final bool isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: GestureDetector(
        onTap: () => showProfileDialog(user, index + 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isHovered ? cardBg.withOpacity(0.85) : cardBg,
            borderRadius: BorderRadius.circular(14),
            border: isHovered
                ? Border.all(color: accent, width: 1.5)
                : Border.all(color: borderColor, width: 0.5),
          ),
          child: Stack(
            children: [
              // Card content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: borderColor,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Icon(Icons.person, size: 28, color: textMuted)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Intern ${index + 1}",
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "View Profile",
                    style: TextStyle(
                      fontSize: 11,
                      color: accent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: accent,
                    ),
                  ),
                ],
              ),

              // 🔹 Edit & Delete icons — appear on hover
              if (isHovered)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      // Edit
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-profile',
                            arguments: user,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.edit, size: 14, color: pageBg),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delete
                      GestureDetector(
                        onTap: () => showDeleteDialog(user),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 ADD INTERN CARD
  Widget buildAddInternCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/register'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 32, color: textMuted),
            const SizedBox(height: 10),
            Text(
              "Add Intern",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredUsers;

    final List<Widget> gridItems = [
      ...List.generate(
        filtered.length,
        (i) => buildProfileCard(filtered[i] as Map<String, dynamic>, i),
      ),
      buildAddInternCard(), // 🔹 always show on admin page
    ];

    return Scaffold(
      backgroundColor: pageBg,
      body: users == null
          ? Center(child: CircularProgressIndicator(color: accent))
          : Column(
              children: [
                buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildStatCard(
                                users!.length.toString(),
                                "Total Interns",
                              ),
                              buildStatCard(
                                departmentCount.toString(),
                                "Departments",
                                adminEditable: true,
                              ),
                              buildStatCard(
                                schoolCount.toString(),
                                "Schools/University",
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Divider(color: borderColor),
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: borderColor),
                              ),
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => searchQuery = val),
                                style: TextStyle(color: textMain, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Search for intern name or id",
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: textMuted,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: accent,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          gridItems.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Text(
                                      "No interns found.",
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: GridView.count(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.6,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: gridItems,
                                  ),
                                ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
