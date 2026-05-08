import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  final bool isAdmin;
  final String internName;
  final String token;
  final VoidCallback? onAttendanceChanged;

  const CalendarPage({
    Key? key,
    required this.isAdmin,
    required this.internName,
    required this.token,
    this.onAttendanceChanged,
  }) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // ─── COLORS ──────────────────────────────────────────────
  final Color pageBg = const Color(0xFF1A1A1A);
  final Color cardBg = const Color(0xFF222222);
  final Color accent = const Color(0xFFBFCF33);
  final Color textMain = Colors.white;
  final Color textMuted = const Color(0xFF888888);
  final Color borderColor = const Color(0xFF2E2E2E);
  final Color presentColor = const Color(0xFF4CAF50);
  final Color absentColor = const Color(0xFFE53935);

  // ─── STATE ───────────────────────────────────────────────
  DateTime _focusedMonth = DateTime.now();
  // key: "yyyy-MM-dd", value: "present" | "absent"
  Map<String, String> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance().then((_) {
      _autoMarkAbsent(); // runs AFTER data loads
    });
  }

  // ─── PERSISTENCE ─────────────────────────────────────────
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? widget.token;
  }

  Future<void> _loadAttendance() async {
    try {
      final token = await _getToken();
      final data = await ApiService.getAttendance(token);

      // DO NOT modify or guess missing days
      setState(() {
        _attendance = data;
      });
    } catch (e) {
      print("Failed to load attendance: $e");
    }
  }

  Future<void> _saveAttendance(String date, String status) async {
    try {
      final token = await _getToken();
      print(
        "=== SAVING ATTENDANCE: date=$date status=$status token=$token ===",
      );
      await ApiService.markAttendance(token, date, status);
      print("=== ATTENDANCE SAVED SUCCESSFULLY ===");
    } catch (e) {
      print("Failed to save attendance: $e");
    }
  }

  Future<void> _autoMarkAbsent() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);

      final List<MapEntry<String, String>> updates = [];

      for (
        DateTime day = start;
        day.isBefore(now);
        day = day.add(const Duration(days: 1))
      ) {
        if (_isWeekend(day)) continue;

        final key = _dateKey(day);

        // IMPORTANT: only mark absent if truly missing
        if (!_attendance.containsKey(key)) {
          updates.add(MapEntry(key, 'absent'));
        }
      }

      // update UI first (fast, no rebuild spam)
      setState(() {
        for (var entry in updates) {
          _attendance[entry.key] = entry.value;
        }
      });

      // THEN send to backend (sequential, stable)
      for (var entry in updates) {
        await _saveAttendance(entry.key, entry.value);
      }

      widget.onAttendanceChanged?.call();
    } catch (e) {
      print("Auto-mark absent failed: $e");
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────
  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isFuture(DateTime d) => d.isAfter(DateTime.now());

  bool _isWeekend(DateTime d) => d.weekday == 6 || d.weekday == 7;

  int get _presentCount =>
      _attendance.values.where((v) => v == 'present').length;

  int get _absentCount => _attendance.values.where((v) => v == 'absent').length;

  int get _totalMarked => _attendance.length;

  // ─── MARK ATTENDANCE ─────────────────────────────────────
  void _markAttendance(DateTime day) async {
    if (widget.isAdmin) return;
    if (_isFuture(day) || _isWeekend(day)) return;

    final key = _dateKey(day);

    setState(() {
      if (_attendance[key] == 'present') {
        // toggle OFF → becomes absent
        _attendance[key] = 'absent';
      } else {
        // toggle ON → present
        _attendance[key] = 'present';
      }
    });

    // save updated state
    await _saveAttendance(key, _attendance[key]!);

    widget.onAttendanceChanged?.call();
  }

  // ─── CALENDAR GRID ───────────────────────────────────────
  Widget _buildCalendar() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final startWeekday = firstDay.weekday % 7;

    final List<Widget> cells = [];

    // empty leading cells
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key = _dateKey(date);
      final status = _attendance[key];
      final today = _isToday(date);
      final future = _isFuture(date);
      final weekend = _isWeekend(date);

      cells.add(
        GestureDetector(
          onTap: () => _markAttendance(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: status == 'present'
                  ? presentColor.withOpacity(0.85)
                  : status == 'absent'
                  ? absentColor.withOpacity(0.85)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: today ? Border.all(color: accent, width: 2) : null,
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  color: status != null
                      ? Colors.white
                      : future || weekend
                      ? textMuted
                      : textMain,
                  fontSize: 11,
                  fontWeight: today ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // pad grid to full weeks
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }

    final headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final rows = cells.length ~/ 7;

    return Column(
      children: [
        Row(
          children: headers
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: Column(
            children: List.generate(rows, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(7, (c) {
                    final idx = r * 7 + c;
                    return Expanded(child: cells[idx]);
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  // ─── BUILD ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Header ──
          Text(
            "My Calendar",
            style: TextStyle(
              color: textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isAdmin
                ? "Viewing attendance records."
                : "Tap a day to mark your attendance.",
            style: TextStyle(color: textMuted, fontSize: 12),
          ),

          const SizedBox(height: 16),

          // ── Stat Cards ──
          Row(
            children: [
              _statCard(
                "$_presentCount",
                "Present",
                Icons.check_circle_rounded,
                presentColor,
              ),
              const SizedBox(width: 10),
              _statCard(
                "$_absentCount",
                "Absent",
                Icons.cancel_rounded,
                absentColor,
              ),
              const SizedBox(width: 10),
              _statCard(
                "$_totalMarked",
                "Marked",
                Icons.calendar_month_rounded,
                accent,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Calendar Card ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        }),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: accent,
                          size: 22,
                        ),
                      ),
                      Text(
                        "${_monthName(_focusedMonth.month)} ${_focusedMonth.year}",
                        style: TextStyle(
                          color: textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        }),
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: accent,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Expanded(child: _buildCalendar()),
                  const SizedBox(height: 8),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(presentColor, "Present"),
                      const SizedBox(width: 16),
                      _legendDot(absentColor, "Absent"),
                      const SizedBox(width: 16),
                      _legendDot(accent, "Today", isBorder: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: TextStyle(color: textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(4),
            border: isBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textMuted, fontSize: 12)),
      ],
    );
  }
}
