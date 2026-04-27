import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  DEPARTMENTS SCREEN
// ════════════════════════════════════════════════════════
class AdminDepartments extends StatefulWidget {
  const AdminDepartments({super.key});

  @override
  State<AdminDepartments> createState() => _AdminDepartmentsState();
}

class _AdminDepartmentsState extends State<AdminDepartments> {
  static const cardBg = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent = Color.fromARGB(255, 212, 226, 74);
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF888888);

  // ── Helpers ───────────────────────────────────────────

  /// Derives status purely from the current date vs the range.
  String _computeStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    if (today.isBefore(s)) return 'upcoming';
    if (!today.isAfter(e)) return 'ongoing';
    return 'done';
  }

  String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── Seed data ─────────────────────────────────────────
  final List<Map<String, dynamic>> _departments = [
    {
      "name": "Development Unit",
      "supervisor": "Mr. Lery Villanueva",
      "role": "Supervisor",
      "supervisor_id": "super_01",
      "active_interns": 12,
      "start_date": DateTime(2025, 1, 6),
      "end_date": DateTime(2025, 4, 30),
    },
    {
      "name": "Technical Support",
      "supervisor": "Mr. Rayven Dela Cruz",
      "role": "Supervisor",
      "supervisor_id": "super_04",
      "active_interns": 0,
      "start_date": DateTime(2024, 6, 1),
      "end_date": DateTime(2024, 9, 30),
    },
    {
      "name": "Quality Assurance",
      "supervisor": "Mr. Renzy Rivera",
      "role": "Supervisor",
      "supervisor_id": "super_03",
      "active_interns": 0,
      "start_date": DateTime(2024, 3, 1),
      "end_date": DateTime(2024, 6, 30),
    },
    {
      "name": "Project Management Office",
      "supervisor": "Mrs. Lea Rose Arellano-Rosario",
      "role": "Supervisor",
      "supervisor_id": "super_02",
      "active_interns": 0,
      "start_date": DateTime(2024, 1, 8),
      "end_date": DateTime(2024, 4, 30),
    },
    {
      "name": "Business Relation Management",
      "supervisor": "Mr. Raymond R. Villapando",
      "role": "Supervisor",
      "supervisor_id": "super_01",
      "active_interns": 0,
      "start_date": DateTime(2023, 6, 1),
      "end_date": DateTime(2023, 10, 31),
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDepartments {
    if (_searchQuery.isEmpty) return _departments;
    final q = _searchQuery.toLowerCase();
    return _departments.where((d) {
      final name = (d['name'] ?? '').toString().toLowerCase();
      final supervisor = (d['supervisor'] ?? '').toString().toLowerCase();
      return name.contains(q) || supervisor.contains(q);
    }).toList();
  }

  // ── Status badge ─────────────────────────────────────
  Widget _statusBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'ongoing':
        bg = const Color(0xFF1E3A1E);
        fg = const Color(0xFF6FCF6F);
        break;
      case 'upcoming':
        bg = const Color(0xFF1A2A3A);
        fg = const Color(0xFF6FB3CF);
        break;
      default: // done
        bg = const Color(0xFF2A2A2A);
        fg = textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Date picker helper ────────────────────────────────
  Future<DateTime?> _pickDate(
    BuildContext ctx,
    DateTime initial, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) => showDatePicker(
    context: ctx,
    initialDate: initial,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: accent,
          onPrimary: Color(0xFF111111),
          surface: cardBg,
          onSurface: textMain,
        ),
        dialogBackgroundColor: cardBg,
      ),
      child: child!,
    ),
  );

  // ── Date range row widget ─────────────────────────────
  Widget _dateRangeRow(DateTime start, DateTime end) => Row(
    children: [
      const Icon(Icons.calendar_today_rounded, color: textMuted, size: 14),
      const SizedBox(width: 6),
      Text(
        '${_fmt(start)}  →  ${_fmt(end)}',
        style: const TextStyle(color: textMuted, fontSize: 12),
      ),
    ],
  );

  // ── DETAIL POPUP ──────────────────────────────────────
  void _showDepartmentDialog(Map<String, dynamic> dept) {
    final name = (dept['name'] ?? 'Unknown').toString();
    final supervisor = (dept['supervisor'] ?? '').toString();
    final role = (dept['role'] ?? '').toString();
    final supervisorId = (dept['supervisor_id'] ?? '').toString();
    final activeInterns = (dept['active_interns'] as int?) ?? 0;
    final start = dept['start_date'] as DateTime;
    final end = dept['end_date'] as DateTime;
    final status = _computeStatus(start, end);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 440,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _dateRangeRow(start, end),
                    const SizedBox(height: 20),
                    const Divider(color: borderColor),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2A2A2A),
                            border: Border.all(color: borderColor),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: textMuted,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$supervisor ($role)',
                              style: const TextStyle(
                                color: textMain,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: $supervisorId',
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Interns',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                          Text(
                            activeInterns.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ADD DEPARTMENT DIALOG ─────────────────────────────
  void _showAddDepartmentDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final supervisorCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Supervisor');
    final supervisorIdCtrl = TextEditingController();
    final activeInternsCtrl = TextEditingController(text: '0');

    DateTime? startDate;
    DateTime? endDate;
    String? startErr;
    String? endErr;

    InputDecoration _fieldDecoration(String label, IconData icon) =>
        InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: textMuted, size: 18),
          filled: true,
          fillColor: const Color(0xFF111111),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // ── Tappable date button ──
          Widget dateTile({
            required String label,
            required DateTime? value,
            String? errorText,
            required VoidCallback onTap,
          }) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: errorText != null ? Colors.redAccent : borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: value != null ? accent : textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        value != null ? _fmt(value) : label,
                        style: TextStyle(
                          color: value != null ? textMain : textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          );

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 460,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Text(
                            'Add Department',
                            style: TextStyle(
                              color: textMain,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Status is set automatically from the date range.',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: borderColor),
                          const SizedBox(height: 20),

                          // Department Name
                          TextFormField(
                            controller: nameCtrl,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 14,
                            ),
                            decoration: _fieldDecoration(
                              'Department Name',
                              Icons.business_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Department name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Supervisor Name
                          TextFormField(
                            controller: supervisorCtrl,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 14,
                            ),
                            decoration: _fieldDecoration(
                              'Supervisor Name',
                              Icons.person_rounded,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Supervisor name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Role & Supervisor ID
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: roleCtrl,
                                  style: const TextStyle(
                                    color: textMain,
                                    fontSize: 14,
                                  ),
                                  decoration: _fieldDecoration(
                                    'Role',
                                    Icons.badge_rounded,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: supervisorIdCtrl,
                                  style: const TextStyle(
                                    color: textMain,
                                    fontSize: 14,
                                  ),
                                  decoration: _fieldDecoration(
                                    'Supervisor ID',
                                    Icons.tag_rounded,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Active Interns
                          TextFormField(
                            controller: activeInternsCtrl,
                            style: const TextStyle(
                              color: textMain,
                              fontSize: 14,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration(
                              'Active Interns',
                              Icons.groups_rounded,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Required';
                              if (int.tryParse(v.trim()) == null)
                                return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // ── Date Range pickers ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: dateTile(
                                  label: 'Start Date',
                                  value: startDate,
                                  errorText: startErr,
                                  onTap: () async {
                                    final picked = await _pickDate(
                                      ctx,
                                      startDate ?? DateTime.now(),
                                      lastDate: endDate,
                                    );
                                    if (picked != null) {
                                      setDialogState(() {
                                        startDate = picked;
                                        startErr = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: 14,
                                  left: 10,
                                  right: 10,
                                ),
                                child: Text(
                                  '→',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: dateTile(
                                  label: 'End Date',
                                  value: endDate,
                                  errorText: endErr,
                                  onTap: () async {
                                    final picked = await _pickDate(
                                      ctx,
                                      endDate ?? (startDate ?? DateTime.now()),
                                      firstDate: startDate,
                                    );
                                    if (picked != null) {
                                      setDialogState(() {
                                        endDate = picked;
                                        endErr = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          // ── Auto-status preview ──
                          if (startDate != null && endDate != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  'Auto status: ',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                _statusBadge(
                                  _computeStatus(startDate!, endDate!),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(color: borderColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    final textValid = formKey.currentState!
                                        .validate();
                                    bool datesValid = true;

                                    setDialogState(() {
                                      startErr = startDate == null
                                          ? 'Pick a start date'
                                          : null;
                                      endErr = endDate == null
                                          ? 'Pick an end date'
                                          : null;
                                      if (startErr != null || endErr != null) {
                                        datesValid = false;
                                      }
                                    });

                                    if (textValid && datesValid) {
                                      setState(
                                        () => _departments.add({
                                          "name": nameCtrl.text.trim(),
                                          "supervisor": supervisorCtrl.text
                                              .trim(),
                                          "role": roleCtrl.text.trim(),
                                          "supervisor_id": supervisorIdCtrl.text
                                              .trim(),
                                          "active_interns": int.parse(
                                            activeInternsCtrl.text.trim(),
                                          ),
                                          "start_date": startDate!,
                                          "end_date": endDate!,
                                        }),
                                      );
                                      Navigator.pop(ctx);
                                    }
                                  },
                                  child: const Text(
                                    'Add Department',
                                    style: TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 14,
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

                  // Close button
                  Positioned(
                    top: 12,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(
                        Icons.close,
                        color: textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── DEPARTMENT CARD ───────────────────────────────────
  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    final name = (dept['name'] ?? 'Unknown').toString();
    final supervisor = (dept['supervisor'] ?? '').toString();
    final role = (dept['role'] ?? '').toString();
    final supervisorId = (dept['supervisor_id'] ?? '').toString();
    final activeInterns = (dept['active_interns'] as int?) ?? 0;
    final start = dept['start_date'] as DateTime;
    final end = dept['end_date'] as DateTime;
    final status = _computeStatus(start, end);

    return _HoverCard(
      onTap: () => _showDepartmentDialog(dept),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: textMain,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 6),

            // Date range
            _dateRangeRow(start, end),
            const SizedBox(height: 12),

            // Supervisor row + intern count
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2A2A2A),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$supervisor ($role)',
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: $supervisorId',
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activeInterns.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Active Interns',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDepartments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: textMain, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search for department or supervisor...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: textMuted,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF111111),
                  size: 20,
                ),
                label: const Text(
                  'Add Department',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _showAddDepartmentDialog,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No departments found.',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildDepartmentCard(filtered[i]),
                ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  HOVER CARD WRAPPER
// ════════════════════════════════════════════════════════
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverCard({required this.child, required this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _hovered
                ? [
                    const BoxShadow(
                      color: Color.fromARGB(255, 212, 226, 74),
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Opacity(opacity: _hovered ? 0.85 : 1.0, child: widget.child),
        ),
      ),
    );
  }
}
