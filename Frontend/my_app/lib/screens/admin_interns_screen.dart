import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../services/api_service.dart';

// ════════════════════════════════════════════════════════
//  INTERNS SCREEN
// ════════════════════════════════════════════════════════
class AdminInterns extends StatefulWidget {
  final List<dynamic>? users;
  final String token;
  final Future<void> Function()? onRefresh;

  const AdminInterns({
    super.key,
    required this.users,
    required this.token,
    this.onRefresh,
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
  //  VIEW PROFILE DIALOG
  // ════════════════════════════════════════════════════════
  void _showProfileDialog(Map<String, dynamic> user, int internNumber) {
    final String name = (user["name"] ?? "Unknown").toUpperCase();
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
                                  style: const TextStyle(
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Intern $internNumber",
                                style: const TextStyle(
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
                    const Divider(color: borderColor),
                    const SizedBox(height: 16),
                    _infoRow("Email:", user["email"] ?? "-"),
                    const SizedBox(height: 12),
                    _infoRow("School:", user["school"] ?? "-"),
                    const SizedBox(height: 12),
                    _infoRow("Program:", user["program"] ?? "-"),
                    const SizedBox(height: 12),
                    _infoRow(
                      "Department:",
                      user["department"] ?? user["dept"] ?? "-",
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
                          Navigator.pop(ctx); // close view dialog
                          showEditDialog(user); // open edit dialog
                        },
                        child: const Text(
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
                  child: const Icon(Icons.close, color: textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DELETE DIALOG
  // ════════════════════════════════════════════════════════
  void _showDeleteDialog(Map<String, dynamic> user) {
    final String name = user["name"] ?? "this intern";
    final String userId = user["id"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Intern",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete $name?\nThis cannot be undone.",
          style: const TextStyle(color: textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: textMuted)),
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
                await ApiService.deleteUser(widget.token, userId);
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

  // ════════════════════════════════════════════════════════
  //  EDIT DIALOG
  // ════════════════════════════════════════════════════════
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
                      const Text(
                        "Edit intern profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Changes will be saved to the server.",
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: borderColor),
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
                                side: const BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
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
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: pageBg,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
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
                    child: const Icon(Icons.close, color: textMuted, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────
  Widget _editField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: textMain, fontSize: 13),
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
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accent),
            ),
          ),
        ),
      ],
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: accent,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: textMain, fontSize: 13),
          ),
        ),
      ],
    );
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

            // ── Hover overlay — View + Delete only ────
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
                          onPressed: () => _showProfileDialog(user, index + 1),
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
                          onPressed: () => _showDeleteDialog(user),
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
        const DropdownMenuItem<String?>(
          value: null,
          child: Text(
            "All Schools",
            style: TextStyle(color: textMain, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ...allSchools.map(
          (s) => DropdownMenuItem<String?>(
            value: s,
            child: Text(
              s,
              style: const TextStyle(color: textMain, fontSize: 13),
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
              maxHeight: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2A2A2A),
              ),
              // ✅ This forces the menu to ALWAYS open downward
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

    if (widget.users == null) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
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
                    SizedBox(width: 180, child: _buildDepartmentDropdown()),
                    const SizedBox(width: 14),
                    SizedBox(width: 180, child: _buildSchoolDropdown()),
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
        ),
        const SizedBox(height: 20),
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
                    itemBuilder: (_, i) => buildProfileCard(
                      Map<String, dynamic>.from(filtered[i]),
                      i,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

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
