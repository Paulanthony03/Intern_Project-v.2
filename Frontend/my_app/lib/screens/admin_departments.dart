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
  // ── THEME COLORS ──────────────────────────────────────
  static const cardBg      = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent      = Color.fromARGB(255, 212, 226, 74);
  static const textMain    = Color(0xFFFFFFFF);
  static const textMuted   = Color(0xFF888888);
  static const redBtn      = Color(0xFF8B1A1A);

  // ── DEPARTMENTS DATA ──────────────────────────────────
  final List<Map<String, dynamic>> _departments = [
    {
      "name": "Development Unit",
      "supervisor": "Mr. Lery Villanueva",
      "role": "Supervisor",
      "supervisor_id": "super_01",
      "active_interns": 12,
      "status": "ongoing",
    },
    {
      "name": "Technical Support",
      "supervisor": "Mr. Rayven Dela Cruz",
      "role": "Supervisor",
      "supervisor_id": "super_04",
      "active_interns": 0,
      "status": "done",
    },
    {
      "name": "Quality Assurance",
      "supervisor": "Mr. Renzy Rivera",
      "role": "Supervisor",
      "supervisor_id": "super_03",
      "active_interns": 0,
      "status": "done",
    },
    {
      "name": "Project Management Office",
      "supervisor": "Mrs. Lea Rose Arellano-Rosario",
      "role": "Supervisor",
      "supervisor_id": "super_02",
      "active_interns": 0,
      "status": "done",
    },
    {
      "name": "Business Relation Management",
      "supervisor": "Mr. Raymond R. Villapando",
      "role": "Supervisor",
      "supervisor_id": "super_01",
      "active_interns": 0,
      "status": "done",
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
      final name       = (d['name'] ?? '').toString().toLowerCase();
      final supervisor = (d['supervisor'] ?? '').toString().toLowerCase();
      return name.contains(q) || supervisor.contains(q);
    }).toList();
  }

  // ── STATUS BADGE ──────────────────────────────────────
  Widget _statusBadge(String status) {
    final isOngoing = status == 'ongoing';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOngoing
            ? const Color(0xFF1E3A1E)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isOngoing ? const Color(0xFF6FCF6F) : textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── DEPARTMENT CARD ───────────────────────────────────
  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    final name         = (dept['name']         ?? 'Unknown').toString();
    final supervisor   = (dept['supervisor']   ?? '').toString();
    final role         = (dept['role']         ?? '').toString();
    final supervisorId = (dept['supervisor_id']?? '').toString();
    final activeInterns= (dept['active_interns'] as int?) ?? 0;
    final status       = (dept['status']       ?? 'ongoing').toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ───────────────────────────
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

          const SizedBox(height: 16),

          // ── Supervisor Row ────────────────────────
          Row(
            children: [
              // Avatar circle
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
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Active Interns count
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
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Action Buttons ────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // TODO: navigate to edit screen
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.redAccent.withOpacity(0.16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  label: const Text(
                    'Trash/Archive',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _showArchiveDialog(name);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ARCHIVE CONFIRM DIALOG ────────────────────────────
  void _showArchiveDialog(String deptName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
        title: const Text(
          'Archive Department?',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to archive "$deptName"?',
          style: const TextStyle(color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: redBtn,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Archive',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
    final filtered = _filteredDepartments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Text(
            'Departments Overview',
            style: const TextStyle(
              color: textMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Search + Add Button Row ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              // Search bar
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
                      prefixIcon: Icon(Icons.search_rounded,
                          color: textMuted, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Add Department button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded,
                    color: Color(0xFF111111), size: 20),
                label: const Text(
                  'Add Department',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // TODO: Navigator.pushNamed(context, '/add-department');
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Cards Grid ────────────────────────────────
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
            childAspectRatio: 3.0, // ← adjust height here
          ),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _buildDepartmentCard(filtered[i]),
        ),
),
        // ── View Detailed Logs Button ──────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: borderColor),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: navigate to detailed logs
              },
              child: const Text(
                'View Detailed Logs',
                style: TextStyle(
                  color: textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}