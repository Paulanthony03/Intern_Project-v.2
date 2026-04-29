import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import 'admin_interns_screen.dart';
import 'admin_school_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_departments_screen.dart';

// ════════════════════════════════════════════════════════
//  APP SHELL — Shared sidebar + top bar wrapper
// ════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // ── THEME COLORS ──
  static const pageBg = Color(0xFF111111);
  static const sidebarBg = Color.fromARGB(255, 0, 0, 0);
  static const headerBg = Color(0xFF111111);
  static const cardBg = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent = Color(0xFFBFCF33);
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF888888);

  static const Map<String, String> _navTitles = {
    'dashboard': 'Welcome Back, Admin!',
    'interns': 'Meet Our Interns!',
    'departments': 'Department Overview',
    'school': 'Our Partnered School',
    'settings': 'Account Settings',
  };

  bool _adminMenuExpanded = true;
  String _selectedNav = 'dashboard';
  String? _hoveredNav;

  // ── SHARED STATE ──────────────────────────────────────
  List<dynamic>? _users;
  String? _token; // null = still loading
  final Map<String, dynamic> _adminData = {
    'name': 'Admin Mc',
    'admin_id': 'admin_08',
    'email': 'admin@test.com',
    'username': 'admin@test.com',
    'password': '',
  };

  final List<String> _navKeys = [
    'dashboard',
    'interns',
    'departments',
    'school',
    'settings',
  ];

  List<Map<String, dynamic>> _departments = [];

  int get _selectedIndex => _navKeys.indexOf(_selectedNav);

  // ════════════════════════════════════════════════════════
  //  LOAD USERS (lifted from AdminDashboard)
  // ════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDepartments();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? '';
    _token = token;

    if (token.isNotEmpty) {
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

      if (mounted) {
        setState(() => _users = internsOnly ?? []);
      }
    } else {
      if (mounted) setState(() => _users = []);
    }
  }

  Future<void> _loadDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? '';

    if (token.isEmpty) return;

    final data = await ApiService.getDepartments(token);

    if (!mounted) return;

    setState(() {
      _departments = List<Map<String, dynamic>>.from(data);
    });
  }

  // ════════════════════════════════════════════════════════
  //  SIDEBAR
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
                const Text(
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
          ),

          const Divider(color: borderColor, height: 1),
          const SizedBox(height: 12),

          _buildAdminDropdownTile(),

          const SizedBox(height: 8),
          const Divider(color: borderColor, height: 1),
          const SizedBox(height: 8),

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
                      _navItem(
                        Icons.settings_rounded,
                        "Account Settings",
                        'settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Logout button
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
            child: GestureDetector(
              onTap: _showLogoutDialog,
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
                child: const Row(
                  children: [
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
                child: const Icon(Icons.person, size: 16, color: accent),
              ),
              const SizedBox(width: 10),
              const Expanded(
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

  Widget _navItem(IconData icon, String label, String key) {
    final bool selected = _selectedNav == key;
    final bool hovered = _hoveredNav == key;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredNav = key),
        onExit: (_) => setState(() => _hoveredNav = null),
        child: GestureDetector(
          onTap: () => setState(() => _selectedNav = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.15)
                  : hovered
                  ? const Color(0xFF222222)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? accent.withOpacity(0.4)
                    : hovered
                    ? accent.withOpacity(0.2)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected || hovered ? accent : textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected || hovered ? accent : textMuted,
                  ),
                ),
              ],
            ),
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
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _navTitles[_selectedNav] ?? 'Welcome Back, Admin!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
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
            child: const Icon(
              Icons.notifications_none_rounded,
              color: textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // AFTER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: borderColor,
                  child: const Icon(Icons.person, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Mc",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  LOGOUT DIALOG
  // ════════════════════════════════════════════════════════
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Logout", style: TextStyle(color: textMain)),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: textMain)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Row(
        children: [
          buildSidebar(),
          Expanded(
            child: Column(
              children: [
                buildTopBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      AdminDashboard(
                        token: _token ?? '',
                        users: _users,
                        departments: _departments,
                        onRefresh: _loadUsers,
                      ), // index 0
                      AdminInterns(
                        users: _users,
                        token: _token ?? '',
                        onRefresh: _loadUsers,
                      ), // index 1
                      AdminDepartments(
                        key: ValueKey(_departments.length),
                        onDepartmentsChanged: _loadDepartments,
                      ), // index 2
                      AdminSchools(), // index 3
                      AdminSettings(adminData: _adminData), // index 4
                    ],
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
