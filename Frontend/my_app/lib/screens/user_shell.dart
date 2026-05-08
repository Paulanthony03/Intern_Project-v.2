import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'user_dashboard.dart';
import 'user_profile.dart';
import 'user_calendar.dart';
import 'user_settings.dart';
import 'user_department.dart';

class UserAppShell extends StatefulWidget {
  const UserAppShell({super.key});

  @override
  State<UserAppShell> createState() => _UserAppShellState();
}

class _UserAppShellState extends State<UserAppShell> {

  // ── THEME TOGGLE ──────────────────────────────────────
  bool _isDarkMode = true;
  AppColors get _colors => _isDarkMode ? AppColors.dark : AppColors.light;

  // ── NAV ───────────────────────────────────────────────
  static const Map<String, String> _navTitles = {
    'dashboard':  'Welcome Back!',
    'profile':    'My Profile',
    'attendance': 'Calendar & Attendance',
    'settings':   'Account Settings',
    'departments': 'Departments',
  };

  bool _userMenuExpanded = true;
  String _selectedNav = 'dashboard';
  String? _hoveredNav;

  final List<String> _navKeys = [
    'dashboard',
    'profile',
    'attendance',
    'settings',
    'departments',
  ];

  // ── USER DATA ─────────────────────────────────────────
  String? _token;
  Map<String, dynamic> _userData = {
    'name':  '',
    'id':    '',
    'email': '',
  };

  int get _selectedIndex => _navKeys.indexOf(_selectedNav);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _token = token;

    if (token.isNotEmpty) {
      // Replace with your actual ApiService call:
      // final data = await ApiService.getProfile(token);
      // if (mounted) setState(() => _userData = data);
    }
  }

  // ── Called by child pages when profile is updated ─────
  void _onUserDataUpdated(Map<String, dynamic> updated) {
    setState(() => _userData = {..._userData, ...updated});
  }

  // ════════════════════════════════════════════════════════
  //  SIDEBAR
  // ════════════════════════════════════════════════════════
  Widget buildSidebar() {
    return Container(
      width: 220,
      color: _colors.sidebarBg,
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
                Text(
                  'Blacky',
                  style: TextStyle(
                    color: _colors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: _colors.borderColor, height: 1),
          const SizedBox(height: 12),

          _buildUserDropdownTile(),

          const SizedBox(height: 8),
          Divider(color: _colors.borderColor, height: 1),
          const SizedBox(height: 8),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _userMenuExpanded ? 1.0 : 0.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _userMenuExpanded ? 1 : 0,
                  child: Column(
                    children: [
                      _navItem(Icons.dashboard_rounded,      'Dashboard',            'dashboard'),
                      _navItem(Icons.person_rounded,         'My Profile',           'profile'),
                      _navItem(Icons.calendar_month_rounded, 'Calendar & Attendance','attendance'),
                      _navItem(Icons.settings_rounded,       'Account Settings',     'settings'),
                      _navItem(Icons.folder_rounded,     'Departments',       'departments'),
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
                      'Logout',
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

  Widget _buildUserDropdownTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () => setState(() => _userMenuExpanded = !_userMenuExpanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _colors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: _userMenuExpanded
                ? Border.all(color: _colors.accent.withOpacity(0.4))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _colors.borderColor,
                backgroundImage: (_userData['photo_url'] ?? '').isNotEmpty
                    ? NetworkImage(_userData['photo_url'])
                    : null,
                child: (_userData['photo_url'] ?? '').isEmpty
                    ? Icon(Icons.person, size: 16, color: _colors.accent)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['name']?.isNotEmpty == true
                          ? _userData['name']
                          : 'Intern',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _colors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'id: ${_userData['intern_id'] ?? _userData['id'] ?? '—'}',
                      style: TextStyle(color: _colors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _userMenuExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _userMenuExpanded ? _colors.accent : _colors.textMuted,
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
    final bool hovered  = _hoveredNav == key;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredNav = key),
        onExit:  (_) => setState(() => _hoveredNav = null),
        child: GestureDetector(
          onTap: () => setState(() => _selectedNav = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? _colors.accent.withOpacity(0.15)
                  : hovered
                      ? _colors.cardBg
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? _colors.accent.withOpacity(0.4)
                    : hovered
                        ? _colors.accent.withOpacity(0.2)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected || hovered ? _colors.accent : _colors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected || hovered ? _colors.accent : _colors.textMuted,
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
    color: _colors.pageBg,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            _navTitles[_selectedNav] ?? 'Welcome Back!',
            style: TextStyle(
              color: _colors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _isDarkMode = !_isDarkMode),
          child: Icon(
            _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: _colors.accent,
            size: 30,
          ),
        ),
      ],
    ),
  );
}
  // ════════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════════
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _colors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Logout', style: TextStyle(color: _colors.textMain)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: _colors.textMain)),
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
      backgroundColor: _colors.pageBg,
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
                      UserDashboard(
                        token: _token ?? '',
                        userData: _userData,
                        colors: _colors,
                        onUserDataChanged: _onUserDataUpdated,
                      ),
                      UserProfile(
                        token: _token ?? '',
                        userData: _userData,
                        colors: _colors,
                        onUserDataChanged: _onUserDataUpdated,
                      ),
                    UserCalendar(
                     token: _token ?? '',
                     colors: _colors,
           ),
                     UserSettings(
                      userData: _userData,
                      colors: _colors,
                     onUserDataChanged: _onUserDataUpdated,
                     ),
                      UserDepartment(
                        departments: [], // Pass actual department data here
                        isAdmin: false, // Set based on user role
                        onEditGrade: (deptId) {
                          // Implement grade editing logic here
                        },
                      ),
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