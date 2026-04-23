import 'package:flutter/material.dart';

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

  void showDepartmentDialog(String name, String status, String grade) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(name, style: TextStyle(color: accent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row("Status", status),
            _row("Grade", grade), // ✅ only shown here
            _row("Supervisor", "Lery Villanueva"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Close", style: TextStyle(color: accent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: accent)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textMain)),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
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
                    Text(
                      dept["name"],
                      style: TextStyle(
                        color: textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dept["status"],
                      style: TextStyle(color: accent, fontSize: 12),
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
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showDepartmentDialog(
                        dept["name"],
                        dept["status"],
                        dept["grade"].toString(),
                      );
                    },
                    child: const Text("View"),
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
