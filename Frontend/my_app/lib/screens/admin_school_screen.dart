import 'package:flutter/material.dart';
import 'app_theme.dart'; // 👈

class AdminSchools extends StatefulWidget {
  final AppColors colors; // 👈
  const AdminSchools({super.key, required this.colors}); // 👈

  @override
  State<AdminSchools> createState() => _AdminSchoolsState();
}

class _AdminSchoolsState extends State<AdminSchools> {

  AppColors get c => widget.colors; // 👈 shortcut

  final List<Map<String, dynamic>> _schools = [
    {
      "name": "Pamantasan ng Lungsod ng San Pablo",
      "since": "2022",
      "logo_url": "../assets/images/plsp.png",
    },
    {
      "name": "CARD-MRI Development Institute",
      "since": "2022",
      "logo_url": "../assets/images/cmdi.png",
    },
    {
      "name": "Laguna State Polytechnic University",
      "since": "2024",
      "logo_url": "../assets/images/lspu.png",
    },
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF2A3A6B),
    Color(0xFF1E4D3A),
    Color(0xFF4D2A1E),
    Color(0xFF3A2A5A),
    Color(0xFF1E3A4D),
  ];

  int? _hoveredIndex;

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return words
        .where((w) => w.isNotEmpty)
        .take(4)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  // ════════════════════════════════════════════════════════
  //  SCHOOL CARD
  // ════════════════════════════════════════════════════════
  Widget _buildSchoolCard(Map<String, dynamic> school, int index) {
    final name      = (school['name']     ?? 'Unknown School').toString();
    final since     = (school['since']    ?? '').toString();
    final logoUrl   = school['logo_url']  as String?;
    final isHovered = _hoveredIndex == index;
    final avatarBg  = _avatarColors[index % _avatarColors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit:  (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isHovered ? c.cardBg : c.cardBg, // 👈
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? c.accent.withOpacity(0.45) : c.borderColor, // 👈
          ),
        ),
        child: Row(
          children: [
            // ── Logo ──
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
                border: Border.all(color: c.borderColor), // 👈
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.asset(logoUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _initialsWidget(name, avatarBg))
                  : _initialsWidget(name, avatarBg),
            ),

            const SizedBox(width: 20),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toUpperCase(),
                      style: TextStyle(
                        color: c.textMain, // 👈
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      )),
                  if (since.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('since $since',
                        style: TextStyle(color: c.textMuted, fontSize: 13)), // 👈
                  ],
                ],
              ),
            ),

            // ── Chevron ──
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isHovered ? 1.0 : 0.3,
              child: Icon(Icons.chevron_right_rounded,
                  color: c.textMuted, size: 22), // 👈
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsWidget(String name, Color bg) {
    return Center(
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_schools.isEmpty) {
      return Center(
        child: Text('No schools found.',
            style: TextStyle(color: c.textMuted, fontSize: 14)), // 👈
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Schools (${_schools.length})',
                  style: TextStyle(
                    color: c.textMain, // 👈
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.add, color: c.pageBg, size: 20), // 👈
                label: Text('Add School',
                    style: TextStyle(
                      color: c.pageBg, // 👈
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
                onPressed: () =>
                    Navigator.pushNamed(context, '/add-school'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── List ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            itemCount: _schools.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _buildSchoolCard(_schools[i], i),
          ),
        ),
      ],
    );
  }
}