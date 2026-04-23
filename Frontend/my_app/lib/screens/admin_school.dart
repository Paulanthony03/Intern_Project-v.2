import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  SCHOOLS SCREEN
// ════════════════════════════════════════════════════════
class AdminSchools extends StatefulWidget {
  final List<dynamic> schools; // Expecting a list of maps with keys like 'name', 'since', 'logo_url'

  const AdminSchools({super.key, required this.schools});

  @override
  State<AdminSchools> createState() => _AdminSchoolsState();
}

class _AdminSchoolsState extends State<AdminSchools> {
  // ── THEME COLORS ──────────────────────────────────────
  static const pageBg      = Color(0xFF111111);
  static const cardBg      = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent      = Color.fromARGB(255, 212, 226, 74);
  static const textMain    = Color(0xFFFFFFFF);
  static const textMuted   = Color(0xFF888888);

  // Avatar background colors (cycles through the list)
  static const List<Color> _avatarColors = [
    Color(0xFF2A3A6B),
    Color(0xFF1E4D3A),
    Color(0xFF4D2A1E),
    Color(0xFF3A2A5A),
    Color(0xFF1E3A4D),
  ];

  int? _hoveredIndex;

  // ── HELPERS ───────────────────────────────────────────
  List<dynamic> get _schools => widget.schools;

  /// Returns up to 4 uppercase initials from the school name.
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
    final name     = (school['name']     ?? 'Unknown School').toString();
    final since    = (school['since']    ?? '').toString();
    final logoUrl  = school['logo_url']  as String?;
    final isHovered = _hoveredIndex == index;
    final avatarBg  = _avatarColors[index % _avatarColors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit:  (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/school-detail',
          arguments: school,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFF222222) : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? accent.withOpacity(0.45) : borderColor,
            ),
          ),
          child: Row(
            children: [
              // ── Logo / Avatar ────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarBg,
                  border: Border.all(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _initialsWidget(name, avatarBg),
                      )
                    : _initialsWidget(name, avatarBg),
              ),

              const SizedBox(width: 20),

              // ── Text ─────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (since.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'since $since',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Chevron ──────────────────────────────
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isHovered ? 1.0 : 0.3,
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
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
    // ── Empty ──────────────────────────────────────────
    if (_schools.isEmpty) {
      return const Center(
        child: Text(
          'No schools found.',
          style: TextStyle(color: textMuted, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schools (${_schools.length})',
                style: const TextStyle(
                  color: textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, color: pageBg, size: 20),
                label: const Text(
                  'Add School',
                  style: TextStyle(
                    color: pageBg,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, '/add-school'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── List ──────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            itemCount: _schools.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _buildSchoolCard(
              Map<String, dynamic>.from(_schools[i]),
              i,
            ),
          ),
        ),
      ],
    );
  }
}