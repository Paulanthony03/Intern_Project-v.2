import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  APP COLORS — Light & Dark
// ════════════════════════════════════════════════════════
class AppColors {
  final Color pageBg;
  final Color cardBg;
  final Color sidebarBg;
  final Color headerBg;
  final Color borderColor;
  final Color textMain;
  final Color textMuted;
  final Color accent;


  const AppColors({
    required this.pageBg,
    required this.cardBg,
    required this.sidebarBg,
    required this.headerBg,
    required this.borderColor,
    required this.textMain,
    required this.textMuted,
    required this.accent,
  });

  // ── DARK THEME ──────────────────────────────────────
  static const dark = AppColors(
    pageBg:      Color(0xFF111111),
    cardBg:      Color(0xFF1A1A1A),
    sidebarBg:   Color(0xFF000000),
    headerBg:    Color(0xFF111111),
    borderColor: Color(0xFF2A2A2A),
    textMain:    Color(0xFFFFFFFF),
    textMuted:   Color(0xFF888888),
    accent:      Color(0xFFD4E24A)
  );

  // ── LIGHT THEME ─────────────────────────────────────
  static const light = AppColors(
    pageBg:      Color(0xFFF4F4F4),
    cardBg:      Color(0xFFFFFFFF),
    sidebarBg:   Color(0xFFEAEAEA),
    headerBg:    Color(0xFFFFFFFF),
    borderColor: Color(0xFFDDDDDD),
    textMain:    Color(0xFF111111),
    textMuted:   Color(0xFF666666),
    accent:      Color(0xFF2B1DB5),
  );
}