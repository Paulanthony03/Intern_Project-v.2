import 'package:flutter/material.dart';

class MyProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onEditPressed;

  // ─── COLORS (matches UserDashboard theme) ────────────────
  static const Color pageBg = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF222222);
  static const Color accent = Color(0xFFBFCF33);
  static const Color textMain = Colors.white;
  static const Color textMuted = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2E2E2E);

  const MyProfilePage({super.key, required this.user, this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    // ─── DATA (matches all key variants used in UserDashboard) ───
    final String name = user["name"] ?? "Intern Name";
    final String department = user["department"] ?? user["dept"] ?? "-";
    final String internId =
        user["intern_id"]?.toString() ??
        user["id"]?.toString() ??
        user["studentId"]?.toString() ??
        "-";
    final String school = user["school"] ?? "-";
    final String email = user["email"] ?? "-";
    final String contact = user["contact"] ?? user["contact_no"] ?? "-";
    final String start = user["startDate"] ?? user["start_date"] ?? "-";
    final String end = user["endDate"] ?? user["end_date"] ?? "-";
    final String supervisor = user["supervisor"] ?? "-";
    final String role = user["role"] ?? user["user_type"] ?? "Intern";
    final String? photoUrl = user["photo_url"] ?? user["photo"];

    return Container(
      color: pageBg,
      padding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page heading ──────────────────────────────
            Text(
              "My Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "View and manage your personal information.",
              style: TextStyle(color: textMuted, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // ── Main card ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LEFT: avatar + name + edit ──────────
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: borderColor,
                          backgroundImage:
                              photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "I",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accent.withOpacity(0.4)),
                          ),
                          child: Text(
                            role[0].toUpperCase() +
                                role.substring(1).toLowerCase(),
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          department,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),

                        const SizedBox(height: 24),

                        Divider(color: borderColor),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              Icons.edit_rounded,
                              color: pageBg,
                              size: 16,
                            ),
                            label: Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: pageBg,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: onEditPressed,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 30),

                  // Vertical divider
                  Container(width: 1, color: borderColor),

                  const SizedBox(width: 30),

                  // ── RIGHT: details ───────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader("Personal Information"),
                        const SizedBox(height: 16),
                        _infoRow(Icons.badge_rounded, "Intern ID", internId),
                        _divider(),
                        _infoRow(Icons.person_rounded, "Full Name", name),
                        _divider(),
                        _infoRow(Icons.email_rounded, "Email", email),
                        _divider(),
                        _infoRow(Icons.phone_rounded, "Contact No.", contact),

                        const SizedBox(height: 28),

                        _sectionHeader("Internship Information"),
                        const SizedBox(height: 16),
                        _infoRow(
                          Icons.account_balance_rounded,
                          "School",
                          school,
                        ),
                        _divider(),
                        _infoRow(
                          Icons.folder_rounded,
                          "Department",
                          department,
                        ),
                        _divider(),
                        _infoRow(
                          Icons.person_outline_rounded,
                          "Supervisor",
                          supervisor,
                        ),
                        _divider(),
                        _infoRow(
                          Icons.calendar_today_rounded,
                          "Internship Start",
                          start,
                        ),
                        _divider(),
                        _infoRow(Icons.event_rounded, "Internship End", end),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textMain,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: borderColor, height: 1);
}
