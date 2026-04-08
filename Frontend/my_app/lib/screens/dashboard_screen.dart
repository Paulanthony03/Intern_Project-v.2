import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profiles/raven.dart';
import '../profiles/mc.dart';
import '../profiles/paul.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic>? users;
  String fullName = "";        // 🔹 will show the logged-in user's full name
  String currentUserId = "";
  bool isAdmin = false;
  String searchQuery = "";
  int departmentCount = 5;

  final Color maroon = const Color(0xFF6B1A1A);
  final Color cardBg = const Color.fromARGB(255, 234, 228, 228);
  final Color pageBg = const Color.fromARGB(255, 255, 235, 235);
  final Color headerBg = const Color.fromARGB(255, 214, 178, 178);

  // 🔹 Match by intern_id to give custom carousel card design
  // Update these IDs to match your actual database intern_ids
  Map<String, Widget Function(Map<String, dynamic>)> get featuredBuilders => {
    "2026-123": (user) => PaulCard(user: user),
    "2026-124": (user) => McCard(user: user),
    "2026-125": (user) => RavenCard(user: user),
  };

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final name = prefs.getString("full_name")      // try full_name first
        ?? prefs.getString("name")
        ?? prefs.getString("username")
        ?? "User";
    final userId = prefs.getString("user_id") ?? "";
    final admin = prefs.getBool("is_admin") ?? false;
    final savedDept = prefs.getInt("department_count");

    if (token != null) {
      final data = await ApiService.getUsers(token);

      // Remove duplicates by id
      final seen = <String>{};
      final deduped = data ?. where((u) {
        final id = u["id"]?.toString() ?? "";
        return seen.add(id);
      }).toList();

      setState(() {
        users = deduped;
        fullName = name;
        currentUserId = userId;
        isAdmin = admin;
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

  // 🔹 LOGOUT DIALOG
  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Log Out",
            style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("No", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 ADMIN: Edit department count
  void showEditDepartmentDialog() {
    final controller = TextEditingController(text: departmentCount.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Edit Department Count",
            style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Number of departments",
            labelStyle: TextStyle(color: maroon),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: maroon)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: maroon),
            onPressed: () async {
              final val = int.tryParse(controller.text);
              if (val != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt("department_count", val);
                setState(() => departmentCount = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔹 PROFILE EXPANDED DIALOG — matches the picture you showed
  void showProfileDialog(Map<String, dynamic> user, int internNumber) {
    final String name = (user["name"] ?? "Unknown").toUpperCase();
    final String school = user["school"] ?? "-";
    final String email = user["email"] ?? "-";
    final String contact = user["contact"] ?? user["contact_no"] ?? "-";
    final String? photoUrl = user["photo_url"];
    final String userId = user["id"]?.toString() ?? "";
    final bool isMyCard = userId == currentUserId;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: photo + name + intern number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: maroon,
                          backgroundImage: photoUrl != null &&
                                  photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  (user["name"] ?? "U")[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: maroon,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Intern $internNumber",
                              style: TextStyle(
                                fontSize: 15,
                                color: maroon.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Divider(color: maroon.withOpacity(0.2)),
                    const SizedBox(height: 16),

                    // Info rows
                    _infoRow("School:", school),
                    const SizedBox(height: 12),
                    _infoRow("Email:", email),
                    const SizedBox(height: 12),
                    _infoRow("Contact No.:", contact),

                    const SizedBox(height: 24),

                    // Edit button — only for own card
                    if (isMyCard)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(context, '/edit-profile',
                                arguments: user);
                          },
                          child: const Text(
                            "Edit My Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // X close button
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
                        color: maroon),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: maroon,
                  fontSize: 14)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: maroon.withOpacity(0.85), fontSize: 14)),
        ),
      ],
    );
  }

  // 🔹 HEADER — shows the logged-in user's actual name
  Widget buildHeader() {
    return Container(
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Image.asset('assets/images/mylogo.png', height: 36),
          const SizedBox(width: 8),
          Text(
            "InternShip",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: maroon,
                letterSpacing: 1.2),
          ),
          const Spacer(),
          Icon(Icons.account_circle, color: maroon, size: 26),
          const SizedBox(width: 6),
          Text(
            fullName,   // 🔹 actual name from login
            style: TextStyle(
                fontWeight: FontWeight.bold, color: maroon, fontSize: 13),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: showLogoutDialog,
            child: Icon(Icons.logout, color: maroon, size: 24),
          ),
        ],
      ),
    );
  }

  // 🔹 STAT CARD
  Widget buildStatCard(String value, String label,
      {bool adminEditable = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: adminEditable && isAdmin ? showEditDepartmentDialog : null,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: maroon)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: maroon,
                          letterSpacing: 0.8)),
                  if (adminEditable && isAdmin) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.edit, size: 12, color: maroon),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 CAROUSEL CARD — custom design for featured 3, default for rest
  Widget buildCarouselCard(Map<String, dynamic> user) {
    final internId = user["intern_id"]?.toString() ?? "";
    if (featuredBuilders.containsKey(internId)) {
      return featuredBuilders[internId]!(user);
    }
    return _DefaultCarouselCard(user: user, maroon: maroon, cardBg: cardBg);
  }

  // 🔹 PROFILE CARD — 3 visible at a time, click VIEW PROFILE to expand
  Widget buildProfileCard(Map<String, dynamic> user, int index) {
    final String name = user["name"] ?? "Unknown";
    final String? photoUrl = user["photo_url"];
    final String userId = user["id"]?.toString() ?? "";
    final bool isMyCard = userId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isMyCard
            ? Border.all(color: maroon, width: 2.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: maroon,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(height: 14),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: maroon)),
          const SizedBox(height: 4),
          Text("Intern ${index + 1}",
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => showProfileDialog(user, index + 1),
            child: Text("VIEW PROFILE",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: maroon,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredUsers;
    final screenWidth = MediaQuery.of(context).size.width;
    // 🔹 Show exactly 3 cards per view
    final cardWidth = (screenWidth - 48) / 3;

    return Scaffold(
      backgroundColor: pageBg,
      body: users == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // STAT CARDS
                          Row(children: [
                            buildStatCard(
                                users!.length.toString(), "Total Interns"),
                            buildStatCard(departmentCount.toString(),
                                "Department",
                                adminEditable: true),
                            buildStatCard(
                                schoolCount.toString(), "School/University"),
                          ]),
                          const SizedBox(height: 16),
                          Divider(color: Colors.black.withOpacity(0.3)),
                          const SizedBox(height: 10),

                          // SEARCH
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 260,
                              decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(30)),
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: "Search name or Intern ID",
                                  hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: maroon.withOpacity(0.5)),
                                  prefixIcon: Icon(Icons.search,
                                      color: maroon, size: 20),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔹 PROFILE CARDS — 3 per row, scroll horizontally
                          filtered.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Text("No interns found.",
                                        style:
                                            TextStyle(color: Colors.grey)),
                                  ),
                                )
                              : SizedBox(
                                  height: 260,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filtered.length,
                                    itemBuilder: (ctx, index) {
                                      return SizedBox(
                                        width: cardWidth, // 🔹 exactly 3 fit
                                        child: buildProfileCard(
                                          filtered[index]
                                              as Map<String, dynamic>,
                                          index,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: maroon,
              child: const Icon(Icons.person_add, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/register'),
            )
          : null,
    );
  }
}

// 🔹 Default carousel card for non-featured interns
class _DefaultCarouselCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Color maroon;
  final Color cardBg;

  const _DefaultCarouselCard(
      {required this.user, required this.maroon, required this.cardBg});

  @override
  Widget build(BuildContext context) {
    final String name = user["name"] ?? "Unknown";
    final String? photoUrl = user["photo_url"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: maroon,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Text(name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: maroon)),
                  const SizedBox(height: 4),
                  Text(user["school"] ?? "",
                      style: TextStyle(
                          color: maroon.withOpacity(0.65), fontSize: 12)),
                  Text("ID: ${user["intern_id"] ?? ""}",
                      style: TextStyle(
                          color: maroon.withOpacity(0.65), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}