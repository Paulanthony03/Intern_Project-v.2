import 'package:flutter/material.dart';

// 🔹 Paul's custom carousel card design
// Edit colors, layout, fonts freely — only this card is affected

class PaulCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const PaulCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = user["name"] ?? "Paul";
    final String school = user["school"] ?? "";
    final String internId = user["intern_id"] ?? "";
    final String? photoUrl = user["photo_url"];

    // ✏️ Paul: customize your card colors here
    const Color bgColor = Color(0xFF3B1A1A);       // deeper dark maroon
    const Color textColor = Colors.white;
    const Color avatarBg = Color(0xFFE8DADA);
    const Color avatarTextColor = Color(0xFF6B1A1A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: avatarBg,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? Text(name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: avatarTextColor))
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text(school,
                      style: TextStyle(
                          color: textColor.withOpacity(0.75), fontSize: 12)),
                  Text("ID: $internId",
                      style: TextStyle(
                          color: textColor.withOpacity(0.75), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}