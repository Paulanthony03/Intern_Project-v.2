import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentPage extends StatefulWidget {
  final List<Map<String, dynamic>> departments;
  final bool isAdmin;
  final Function(int) onEditGrade;

  const DepartmentPage({
    Key? key,
    required this.departments,
    required this.isAdmin,
    required this.onEditGrade,
  }) : super(key: key);

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final Color cardBg = const Color(0xFF222222);
  final Color accent = const Color(0xFFBFCF33);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);

  // tracks which department index the intern is enrolled in (-1 = none)
  int? enrolledIndex;

  @override
  void initState() {
    super.initState();
    _loadEnrolledIndex();
  }

  Future<void> _loadEnrolledIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enrolledIndex = prefs.getInt('enrolled_department');
    });
  }

  Future<void> _enroll(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('enrolled_department', index);
    setState(() => enrolledIndex = index);
    if (!mounted) return;
    Navigator.pop(context); // close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Enrolled in ${widget.departments[index]["name"]} successfully!",
        ),
        backgroundColor: accent,
      ),
    );
  }

  void showEnrollDialog(int index) {
    final dept = widget.departments[index];
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enroll in Department",
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You need to enroll before you can view this department.",
                style: TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              _row("Department", dept["name"]),
              const SizedBox(height: 24),
              _row("Supervisor", dept["supervisor"] ?? "-"),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: borderColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _enroll(index),
                      child: Text(
                        "Enroll",
                        style: TextStyle(
                          color: cardBg,
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
    );
  }

  void showDepartmentDialog(int index) {
    final dept = widget.departments[index];
    final String name = dept["name"];
    final String status = dept["status"];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Department Details",
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Divider(color: borderColor),
              const SizedBox(height: 12),
              _row("Status", status),
              _row("Supervisor", dept["supervisor"] ?? "-"),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: cardBg,
                      fontWeight: FontWeight.bold,
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textMain, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: widget.departments.asMap().entries.map((entry) {
        final i = entry.key;
        final dept = entry.value;
        final bool isEnrolled = enrolledIndex == i;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEnrolled ? accent.withOpacity(0.5) : borderColor,
            ),
          ),
          child: Row(
            children: [
              // LEFT ICON
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.apartment_rounded, color: accent),
              ),

              const SizedBox(width: 12),

              // MIDDLE INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dept["name"],
                          style: TextStyle(
                            color: textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isEnrolled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: accent.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              "Enrolled",
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // RIGHT ACTIONS
              Row(
                children: [
                  if (widget.isAdmin)
                    IconButton(
                      icon: Icon(Icons.edit, color: accent, size: 18),
                      onPressed: () => widget.onEditGrade(i),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnrolled ? accent : borderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (isEnrolled) {
                        showDepartmentDialog(i);
                      } else {
                        showEnrollDialog(i);
                      }
                    },
                    child: Text(
                      isEnrolled ? "View" : "Enroll",
                      style: TextStyle(
                        color: isEnrolled ? cardBg : textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
