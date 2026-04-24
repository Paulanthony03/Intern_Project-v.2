import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  INTERNS SCREEN
// ════════════════════════════════════════════════════════
class AdminInterns extends StatefulWidget {
  final List<dynamic>? users;
  final void Function(Map<String, dynamic> user, int index)? onView;
  final void Function(Map<String, dynamic> user)? onDelete;

  const AdminInterns({
    super.key,
    required this.users,
    this.onView,
    this.onDelete,
  });

  @override
  State<AdminInterns> createState() => _AdminInternsState();
}

class _AdminInternsState extends State<AdminInterns> {
  // ── THEME COLORS ──────────────────────────────────────
  static const pageBg = Color(0xFF111111);
  static const cardBg = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent = Color.fromARGB(255, 212, 226, 74);
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF888888);

  String searchQuery = '';
  String? selectedDepartment;
  String? selectedSchool;
  int? hoveredIndex;

  // ── COMPUTED FROM PASSED-IN USERS ─────────────────────
  List<dynamic> get _users => widget.users ?? [];

  List<String> get allDepartments {
    final list = _users
        .map((u) => (u["department"] ?? u["dept"] ?? "").toString().trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<String> get allSchools {
    final list = _users
        .map((u) => (u["school"] ?? "").toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<dynamic> get filteredUsers {
    return _users.where((u) {
      final name = (u["name"] ?? "").toString().toLowerCase();
      final id = (u["intern_id"] ?? u["id"] ?? "").toString().toLowerCase();
      final matchesSearch =
          searchQuery.isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());

      final dept = (u["department"] ?? u["dept"] ?? "").toString().trim();
      final matchesDept =
          selectedDepartment == null || dept == selectedDepartment;

      final school = (u["school"] ?? "").toString().trim();
      final matchesSchool = selectedSchool == null || school == selectedSchool;

      return matchesSearch && matchesDept && matchesSchool;
    }).toList();
  }

  // ════════════════════════════════════════════════════════
  //  PROFILE CARD
  // ════════════════════════════════════════════════════════
  Widget buildProfileCard(Map<String, dynamic> user, int index) {
    final name = user["name"] ?? "Unknown";
    final id = user["intern_id"]?.toString() ?? user["id"]?.toString() ?? "-";
    final photoUrl = user["photo_url"] as String?;
    final isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFF222222) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? accent.withOpacity(0.4) : borderColor,
          ),
        ),
        child: Stack(
          children: [
            // ── Card content ──────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: borderColor,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 36, color: textMuted)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "id: $id",
                      style: const TextStyle(color: textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Hover overlay ─────────────────────────
            if (isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.visibility,
                            color: pageBg,
                            size: 16,
                          ),
                          label: const Text(
                            "View",
                            style: TextStyle(
                              color: pageBg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => widget.onView?.call(user, index),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: textMain,
                            size: 16,
                          ),
                          label: const Text(
                            "Delete",
                            style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => widget.onDelete?.call(user),
                        ),
                      ),
                    ],
                  ),
                ),
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
        const DropdownMenuItem<String?>(
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
              style: const TextStyle(color: textMain, fontSize: 13),
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
        const DropdownMenuItem<String?>(
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
              style: const TextStyle(color: textMain, fontSize: 13),
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
          hint: Text(
            hint,
            style: const TextStyle(color: textMain, fontSize: 13),
          ),
          dropdownColor: const Color(0xFF2A2A2A),
          iconEnabledColor: textMuted,
          iconSize: 20,
          style: const TextStyle(color: textMain, fontSize: 13),
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

    // ── Loading state ──────────────────────────────────
    if (widget.users == null) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Text(
            'Meet our Interns!',
            style: const TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // ── SEARCH + FILTER + ADD INTERN ROW ──────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Row(
            children: [
              const SizedBox(height: 20),
              Expanded(
                flex: 8,
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
                          style: const TextStyle(color: textMain, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: "Search for intern name or id....",
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
                            contentPadding: EdgeInsets.symmetric(vertical: 13),
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
                flex: 4,
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
                    icon: const Icon(Icons.add, color: pageBg, size: 20),
                    label: const Text(
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
        ),

        const SizedBox(height: 20),

        // ── INTERN GRID ───────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      "No interns found.",
                      style: TextStyle(color: textMuted, fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return buildProfileCard(
                        Map<String, dynamic>.from(filtered[i]),
                        i,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
