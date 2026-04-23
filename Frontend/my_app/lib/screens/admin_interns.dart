import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  INTERNS SCREEN
// ════════════════════════════════════════════════════════
class AdminInterns extends StatefulWidget {
  const AdminInterns({super.key});

  @override
  State<AdminInterns> createState() => _AdminInternsState();
}

class _AdminInternsState extends State<AdminInterns> {
  // ── THEME COLORS (match your admin_dashboard colors) ──
  static const pageBg = Color(0xFF111111);
  static const cardBg = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent =  Color.fromARGB(255, 212, 226, 74); 
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF888888);

  String searchQuery = '';
  String? selectedDepartment;
  String? selectedSchool;
  int? hoveredIndex;

  // Replace with your actual data source / API call
  List<Map<String, dynamic>> users = [
    {"name": "Omabay, Raven E.", "intern_id": "Intern 1", "photo_url": ""},
    {"name": "Manguiat, Paul", "intern_id": "Intern 2", "photo_url": ""},
    {"name": "Lumayot, Mc", "intern_id": "Intern 3", "photo_url": ""},
    {"name": "De Castro, Marie", "intern_id": "Intern 4", "photo_url": ""},
    {"name": "Pujeda, Princess", "intern_id": "Intern 5", "photo_url": ""},
  ];

  List<String> get allDepartments =>
      users.map((u) => u["department"] as String? ?? "").toSet().toList();

  List<String> get allSchools =>
      users.map((u) => u["school"] as String? ?? "").toSet().toList();

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((u) {
      final name = (u["name"] ?? "").toString().toLowerCase();
      final id = (u["intern_id"] ?? "").toString().toLowerCase();
      final dept = u["department"] as String?;
      final school = u["school"] as String?;
      final matchesSearch =
          searchQuery.isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          id.contains(searchQuery.toLowerCase());
      final matchesDept =
          selectedDepartment == null || dept == selectedDepartment;
      final matchesSchool =
          selectedSchool == null || school == selectedSchool;
      return matchesSearch && matchesDept && matchesSchool;
    }).toList();
  }

  // ════════════════════════════════════════════════════════
  //  PROFILE CARD
  // ════════════════════════════════════════════════════════
  Widget buildProfileCard(Map<String, dynamic> user, int index) {
    final name = user["name"] ?? "Unknown";
    final id = user["intern_id"] ?? user["id"] ?? "-";
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
            // Main card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: borderColor,
                    backgroundImage:
                        photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                    child:
                        photoUrl == null || photoUrl.isEmpty
                            ? Icon(Icons.person, size: 36, color: textMuted)
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
                    id,
                    style: const TextStyle(color: textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // View Profile link (always visible)
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/profile', arguments: user),
                    child: const Text(
                      "View Profile",
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hover overlay with View + Delete buttons
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
                      // View button
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
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/profile',
                            arguments: user,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Delete button
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
                          onPressed: () => _confirmDelete(index),
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
  //  ADD INTERN CARD
  // ════════════════════════════════════════════════════════
  Widget buildAddInternCard() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/register'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: textMuted, size: 44),
              SizedBox(height: 12),
              Text(
                "Add Intern",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DELETE CONFIRMATION
  // ════════════════════════════════════════════════════════
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Delete Intern",
          style: TextStyle(color: textMain),
        ),
        content: const Text(
          "Are you sure you want to delete this intern?",
          style: TextStyle(color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() => users.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: textMain),
            ),
          ),
        ],
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
            child: Text(d, style: const TextStyle(color: textMain, fontSize: 13)),
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
            child: Text(s, style: const TextStyle(color: textMain, fontSize: 13)),
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
          hint: Text(hint, style: const TextStyle(color: textMain, fontSize: 13)),
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

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── SEARCH + FILTER + ADD INTERN ROW ──
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
        child: Row(
          children: [
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
                          hintStyle: TextStyle(fontSize: 12, color: textMuted),
                          prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

      // ── INTERN GRID ──
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length + 1,
                  itemBuilder: (_, i) {
                    if (i == filtered.length) return buildAddInternCard();
                    return buildProfileCard(filtered[i], i);
                  },
                ),
        ),
      ),
    ],
  );
}
}