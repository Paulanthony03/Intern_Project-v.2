import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  final bool isAdmin;
  final String internName;

  const CalendarPage({
    Key? key,
    required this.isAdmin,
    required this.internName,
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
    _loadAttendance();
  }

  // ─── PERSISTENCE ─────────────────────────────────────────
  Future<void> _loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('attendance_${widget.internName}');
    if (raw != null) {
      setState(() {
        _attendance = Map<String, String>.from(jsonDecode(raw));
      });
    }
  }

  Future<void> _saveAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'attendance_${widget.internName}',
      jsonEncode(_attendance),
    );
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
  void _markAttendance(DateTime day, String status) async {
    if (widget.isAdmin) return; // admin view only
    if (_isFuture(day)) return; // can't mark future
    if (_isWeekend(day)) return; // no weekends

    final key = _dateKey(day);
    setState(() {
      if (_attendance[key] == status) {
        _attendance.remove(key); // toggle off
      } else {
        _attendance[key] = status;
      }
    });
    await _saveAttendance();
  }

  void _showDayDialog(DateTime day) {
    if (_isFuture(day) || _isWeekend(day)) return;

    final key = _dateKey(day);
    final current = _attendance[key];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_monthName(_focusedMonth.month)} ${day.day}, ${day.year}",
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isAdmin
                    ? "Attendance record"
                    : "Mark your attendance for this day.",
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (current != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: current == 'present'
                        ? presentColor.withOpacity(0.15)
                        : absentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: current == 'present'
                          ? presentColor.withOpacity(0.5)
                          : absentColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        current == 'present'
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: current == 'present'
                            ? presentColor
                            : absentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        current == 'present' ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: current == 'present'
                              ? presentColor
                              : absentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  "No record yet.",
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
              if (!widget.isAdmin) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: presentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          "Present",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _markAttendance(day, 'present');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: absentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          "Absent",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _markAttendance(day, 'absent');
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    // Build flat list of cells
    final List<Widget> cells = [];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key = _dateKey(date);
      final status = _attendance[key];
      final today = _isToday(date);
      final future = _isFuture(date);
      final weekend = _isWeekend(date);

      Color bgColor = Colors.transparent;
      if (status == 'present') bgColor = presentColor;
      if (status == 'absent') bgColor = absentColor;

      cells.add(
        GestureDetector(
          onTap: () => _showDayDialog(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(status != null ? 0.85 : 0),
              borderRadius: BorderRadius.circular(6),
              border: today
                  ? Border.all(color: accent, width: 2)
                  : status != null
                  ? Border.all(
                      color: status == 'present' ? presentColor : absentColor,
                      width: 1,
                    )
                  : null,
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

    // Pad to complete last row
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }

    final headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final rows = cells.length ~/ 7;

    return Column(
      children: [
        // Day headers
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
        // Day rows
        ...List.generate(rows, (r) {
          return Expanded(
            child: Row(
              children: List.generate(7, (c) {
                final idx = r * 7 + c;
                return Expanded(child: cells[idx]);
              }),
            ),
          );
        }),
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
