import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_interns.dart';

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
  static const pageBg     = Color(0xFF111111);
  static const sidebarBg  = Color(0xFF151515);
  static const headerBg   = Color(0xFF151515);
  static const cardBg     = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent     = Color(0xFFBFCF33);
  static const textMain   = Color(0xFFFFFFFF);
  static const textMuted  = Color(0xFF888888);

  bool _adminMenuExpanded = false;
  String _selectedNav = 'dashboard';

  final List<String> _navKeys = [
    'dashboard',
    'interns',
    'departments',
    'school',
    'settings',
  ];

  int get _selectedIndex => _navKeys.indexOf(_selectedNav);

  @override
  void initState() {
    super.initState();
    // Auto-expand admin menu if a nav item is selected
    _adminMenuExpanded = true;
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
                      _navItem(Icons.dashboard_rounded, "Dashboard", 'dashboard'),
                      _navItem(Icons.people_alt_rounded, "Interns", 'interns'),
                      _navItem(Icons.folder_rounded, "Departments", 'departments'),
                      _navItem(Icons.account_balance_rounded, "School", 'school'),
                      _navItem(Icons.settings_rounded, "Settings", 'settings'),
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNav = key);
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
    return Container(
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Text(
            "Welcome Back, Admin!",
            style: const TextStyle(
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
            child: const Icon(
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
              arguments: {"name": "Admin Mc"},
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: borderColor,
                  child: const Icon(Icons.person, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     "Admin Mc",
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "id: admin_08",
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
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
        // Shared sidebar
        buildSidebar(),

        // Main content area
        Expanded(
          child: Column(
            children: [
              // Shared top bar
              buildTopBar(),

              // Screen content
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    AdminDashboard(token: ''),   // index 0 - dashboard
                    AdminInterns(),     // index 1 - interns
                    const Placeholder(), // index 2 - departments
                    const Placeholder(), // index 3 - school
                    const Placeholder(), // index 4 - settings
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