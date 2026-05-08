import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class UserDashboard extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final AppColors colors;
  final void Function(Map<String, dynamic>)? onUserDataChanged;

  const UserDashboard({
    Key? key,
    required this.token,
    required this.userData,
    required this.colors,
    this.onUserDataChanged,
  }) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {

  // ── shorthand getters so the rest of the code reads the same ──
  AppColors get c => widget.colors;

  // ─── STATE ────────────────────────────────────────────
  List<dynamic>? allUsers;
  bool isLoading = true;

  List<Map<String, dynamic>> departments = [
    {"name": "Development Unit", "status": "Ongoing",  "grade": 90, "supervisor": "Lery Villanueva"},
    {"name": "Tech Support",     "status": "Finished", "grade": 85, "supervisor": "Rayven Dela Cruz"},
    {"name": "QA",               "status": "Finished", "grade": 90, "supervisor": "Renzy Rivera"},
    {"name": "PMO",              "status": "Finished", "grade": 70, "supervisor": "Lea Rose Arellano-Rosario"},
    {"name": "BRM",              "status": "Finished", "grade": 91, "supervisor": "Raymond Villapando"},
  ];

  String searchQuery = '';
  String? selectedSort;
  int? hoveredIndex;
  int _presentCount = 0;

  // ─── INIT ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ─── LOAD DATA ────────────────────────────────────────
  Future<void> loadData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? widget.token;

    try {
      final users = await ApiService.getUsers(token);
      final seen = <String>{};
      final deduped = users?.where((u) {
        final id = u['id']?.toString() ?? '';
        return seen.add(id);
      }).toList();

      final internsOnly = deduped?.where((u) {
        final role = (u['role'] ?? u['user_type'] ?? '').toString().toLowerCase();
        return role != 'admin';
      }).toList();

      setState(() {
        allUsers = internsOnly;
        isLoading = false;
      });
      //await _loadPresentCount();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

 // Future<void> _loadPresentCount() async {
  //  final prefs = await SharedPreferences.getInstance();
  //  final token = prefs.getString('token') ?? widget.token;
 //   try {
 //    final attendance = await ApiService.getAttendance(token);
  //    setState(() {
 //       _presentCount = attendance.values.where((v) => v == 'present').length;
 //     });
//    } catch (_) {
//      setState(() => _presentCount = 0);
 //   }
  //}

  // ─── COMPUTED ─────────────────────────────────────────
  List<dynamic> get filteredUsers {
    if (allUsers == null) return [];
    var list = allUsers!.where((u) {
      final name = (u['name'] ?? '').toLowerCase();
      final id   = (u['intern_id'] ?? u['id'] ?? '').toString().toLowerCase();
      return searchQuery.isEmpty ||
             name.contains(searchQuery.toLowerCase()) ||
             id.contains(searchQuery.toLowerCase());
    }).toList();

    switch (selectedSort) {
      case 'name_asc':  list.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? '')); break;
      case 'name_desc': list.sort((a, b) => (b['name'] ?? '').compareTo(a['name'] ?? '')); break;
      case 'id_asc':
        list.sort((a, b) {
          final aId = int.tryParse((a['intern_id'] ?? a['id'] ?? '').toString()) ?? 0;
          final bId = int.tryParse((b['intern_id'] ?? b['id'] ?? '').toString()) ?? 0;
          return aId.compareTo(bId);
        });
        break;
      case 'id_desc':
        list.sort((a, b) {
          final aId = int.tryParse((a['intern_id'] ?? a['id'] ?? '').toString()) ?? 0;
          final bId = int.tryParse((b['intern_id'] ?? b['id'] ?? '').toString()) ?? 0;
          return bId.compareTo(aId);
        });
        break;
    }
    return list;
  }

  String get hoursRemaining {
    const total = 450;
    const perDay = 8;
    final remaining = total - (_presentCount * perDay);
    return '${remaining}h';
  }

  // ─── DIALOGS ──────────────────────────────────────────
  void showProfileDialog(Map<String, dynamic> user, int internNumber) {
    final name       = (user['name'] ?? 'Unknown').toUpperCase();
    final school     = user['school'] ?? '-';
    final email      = user['email'] ?? '-';
    final contact    = user['contact'] ?? user['contact_no'] ?? '-';
    final department = user['department'] ?? user['dept'] ?? '-';
    final photoUrl   = user['photo_url'] as String?;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.borderColor),
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
                          backgroundColor: c.borderColor,
                          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  (user['name'] ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(fontSize: 32, color: c.accent, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.textMain)),
                              const SizedBox(height: 6),
                              Text('Intern #$internNumber', style: TextStyle(fontSize: 13, color: c.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: c.borderColor),
                    const SizedBox(height: 16),
                    _infoRow('School:',      school),
                    const SizedBox(height: 12),
                    _infoRow('Department:',  department),
                    const SizedBox(height: 12),
                    _infoRow('Email:',       email),
                    const SizedBox(height: 12),
                    _infoRow('Contact No.:', contact),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.borderColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Close', style: TextStyle(color: c.textMuted, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12, right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: c.textMuted, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditGradeDialog(int index) {
    final controller = TextEditingController(text: departments[index]['grade'].toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.accent.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Grade', style: TextStyle(color: c.accent, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: c.textMain),
                decoration: InputDecoration(hintText: 'Enter grade', hintStyle: TextStyle(color: c.textMuted)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: TextStyle(color: c.textMuted)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: c.accent),
                      onPressed: () {
                        setState(() => departments[index]['grade'] = int.tryParse(controller.text) ?? 0);
                        Navigator.pop(ctx);
                      },
                      child: Text('Save', style: TextStyle(color: c.pageBg)),
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

  // ─── HELPERS ──────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: c.accent, fontSize: 13)),
        ),
        Expanded(child: Text(value, style: TextStyle(color: c.textMain, fontSize: 13))),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          hint: Text('Sort By', style: TextStyle(color: c.textMain, fontSize: 13)),
          dropdownColor: c.cardBg,
          iconEnabledColor: c.textMuted,
          iconSize: 20,
          style: TextStyle(color: c.textMain, fontSize: 13),
          items: const [
            DropdownMenuItem(value: 'name_asc',  child: Text('Name (A-Z)')),
            DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
            DropdownMenuItem(value: 'id_asc',    child: Text('ID (Ascending)')),
            DropdownMenuItem(value: 'id_desc',   child: Text('ID (Descending)')),
          ],
          onChanged: (val) => setState(() => selectedSort = val),
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, {bool isLast = false}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: c.accent, size: 22),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number, style: TextStyle(color: c.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label,  style: TextStyle(color: c.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user, int index) {
    final name      = user['name'] ?? 'Unknown';
    final internId  = user['intern_id']?.toString() ?? user['id']?.toString() ?? '-';
    final photoUrl  = user['photo_url'] as String?;
    final isHovered = hoveredIndex == index;

    final myId     = widget.userData['id']?.toString() ?? '';
    final cardId   = user['id']?.toString() ?? '';
    final isOwn    = myId.isNotEmpty && myId == cardId;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit:  (_) => setState(() => hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isHovered
              ? Border.all(color: c.accent, width: 1.5)
              : Border.all(color: c.borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: c.borderColor,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(Icons.person, size: 24, color: c.textMuted)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.textMain)),
                      const SizedBox(height: 2),
                      Text('id: $internId', style: TextStyle(fontSize: 11, color: c.textMuted)),
                    ],
                  ),
                ),
                if (isOwn)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.accent.withOpacity(0.5)),
                    ),
                    child: Text('You', style: TextStyle(color: c.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => showProfileDialog(user, index + 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('View Profile', style: TextStyle(color: c.pageBg, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
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
    if (isLoading) return Center(child: CircularProgressIndicator(color: c.accent));

    final filtered = filteredUsers;

    return Column(
      children: [
        // Stat cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              _buildStatCard((allUsers?.length ?? 0).toString().padLeft(2, '0'), 'Total Interns',  Icons.people_alt_rounded),
              _buildStatCard(departments.length.toString().padLeft(2, '0'),      'Total Depts.',   Icons.folder_rounded),
              _buildStatCard('450 hours',                                         'Duration',       Icons.timer_rounded),
              _buildStatCard(hoursRemaining,                                      'Hours Left',     Icons.hourglass_bottom_rounded, isLast: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Search + sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.borderColor),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    style: TextStyle(color: c.textMain, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search intern name or id...',
                      hintStyle: TextStyle(fontSize: 12, color: c.textMuted),
                      prefixIcon: Icon(Icons.search, color: c.textMuted, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildSortDropdown(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Intern list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: filtered.isEmpty
                ? Center(child: Text('No interns found.', style: TextStyle(color: c.textMuted, fontSize: 14)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 130,
                        child: _buildProfileCard(filtered[i] as Map<String, dynamic>, i),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}