import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'app_theme.dart';

class UserCalendar extends StatefulWidget {
  final String token;
  final AppColors colors;
  final VoidCallback? onAttendanceChanged;

  const UserCalendar({
    Key? key,
    required this.token,
    required this.colors,
    this.onAttendanceChanged,
  }) : super(key: key);

  @override
  State<UserCalendar> createState() => _UserCalendarState();
}

class _UserCalendarState extends State<UserCalendar> {
  // ── shorthand ────────────────────────────────────────────
  AppColors get c => widget.colors;

  // ── fixed semantic colors (not theme-dependent) ──────────
  final Color presentColor = const Color(0xFF4CAF50);
  final Color absentColor  = const Color(0xFFE53935);

  // ─── STATE ───────────────────────────────────────────────
  DateTime _focusedMonth = DateTime.now();
  Map<String, String> _attendance = {}; // "yyyy-MM-dd" → "present"|"absent"
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  // ─── TOKEN ───────────────────────────────────────────────
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? widget.token;
  }

  // ─── LOAD ────────────────────────────────────────────────
  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      final data  = await ApiService.getAttendance(token);
      setState(() {
        _attendance = data;
        _isLoading  = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Failed to load attendance: $e');
    }
  }

  // ─── SAVE ────────────────────────────────────────────────
  Future<void> _saveAttendance(String date, String status) async {
    try {
      final token = await _getToken();
      await ApiService.markAttendance(token, date, status);
    } catch (e) {
      debugPrint('Failed to save attendance: $e');
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────
  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isFuture(DateTime d) {
    final today = DateTime.now();
    return d.isAfter(DateTime(today.year, today.month, today.day));
  }

  bool _isWeekend(DateTime d) => d.weekday == 6 || d.weekday == 7;

  int get _presentCount => _attendance.values.where((v) => v == 'present').length;
  int get _absentCount  => _attendance.values.where((v) => v == 'absent').length;
  int get _totalMarked  => _attendance.length;

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }

  // ─── MARK ATTENDANCE ─────────────────────────────────────
  void _markAttendance(DateTime day, String status) async {
    if (_isFuture(day) || _isWeekend(day)) return;

    final key         = _dateKey(day);
    final isToggleOff = _attendance[key] == status;

    setState(() {
      if (isToggleOff) {
        _attendance.remove(key);
      } else {
        _attendance[key] = status;
      }
    });

    await _saveAttendance(key, isToggleOff ? '' : status);
    widget.onAttendanceChanged?.call();
  }

  // ─── DAY DIALOG ──────────────────────────────────────────
  void _showDayDialog(DateTime day) {
    if (_isFuture(day) || _isWeekend(day)) return;

    final key     = _dateKey(day);
    final current = _attendance[key];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: c.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.accent.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date header ──
              Text(
                '${_monthName(_focusedMonth.month)} ${day.day}, ${day.year}',
                style: TextStyle(color: c.accent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Mark your attendance for this day.',
                style: TextStyle(color: c.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // ── Current status badge ──
              if (current != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        color: current == 'present' ? presentColor : absentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        current == 'present' ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: current == 'present' ? presentColor : absentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      // ── Clear button ──
                      GestureDetector(
                        onTap: () {
                          _markAttendance(day, current);
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: c.textMuted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text('No record yet.', style: TextStyle(color: c.textMuted, fontSize: 13)),

              const SizedBox(height: 20),

              // ── Present / Absent buttons ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: presentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      label: const Text('Present', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      label: const Text('Absent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        _markAttendance(day, 'absent');
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Close button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.bold)),
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
    final firstDay     = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth  = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    final List<Widget> cells = [];

    // Leading blank cells
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date    = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key     = _dateKey(date);
      final status  = _attendance[key];
      final today   = _isToday(date);
      final future  = _isFuture(date);
      final weekend = _isWeekend(date);

      Color bgColor = Colors.transparent;
      if (status == 'present') bgColor = presentColor;
      if (status == 'absent')  bgColor = absentColor;

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
                  ? Border.all(color: c.accent, width: 2)
                  : status != null
                      ? Border.all(
                          color: status == 'present' ? presentColor : absentColor,
                          width: 1,
                        )
                      : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: status != null
                      ? Colors.white
                      : future || weekend
                          ? c.textMuted
                          : c.textMain,
                  fontSize: 11,
                  fontWeight: today ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Trailing blank cells to fill last row
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }

    final headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final rows    = cells.length ~/ 7;

    return Column(
      children: [
        // Day-of-week headers
        Row(
          children: headers.map((d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: TextStyle(color: c.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 4),

        // Week rows
        ...List.generate(rows, (r) => Expanded(
          child: Row(
            children: List.generate(7, (col) {
              return Expanded(child: cells[r * 7 + col]);
            }),
          ),
        )),
      ],
    );
  }

  // ─── STAT CARD ───────────────────────────────────────────
  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: c.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: c.textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── LEGEND DOT ──────────────────────────────────────────
  Widget _legendDot(Color color, String label, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(4),
            border: isBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: c.textMuted, fontSize: 12)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.accent));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subtitle ──
          Text(
            'Tap a day to mark your attendance.',
            style: TextStyle(color: c.textMuted, fontSize: 12),
          ),

          const SizedBox(height: 16),

          // ── Stat Cards ──
          Row(
            children: [
              _statCard('$_presentCount', 'Present', Icons.check_circle_rounded, presentColor),
              const SizedBox(width: 10),
              _statCard('$_absentCount',  'Absent',  Icons.cancel_rounded,       absentColor),
              const SizedBox(width: 10),
              _statCard('$_totalMarked',  'Marked',  Icons.calendar_month_rounded, c.accent),
            ],
          ),

          const SizedBox(height: 16),

          // ── Calendar Card ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: c.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.borderColor),
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
                        icon: Icon(Icons.chevron_left_rounded, color: c.accent, size: 22),
                      ),
                      Text(
                        '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                        style: TextStyle(color: c.textMain, fontSize: 14, fontWeight: FontWeight.bold),
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
                        icon: Icon(Icons.chevron_right_rounded, color: c.accent, size: 22),
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
                      _legendDot(presentColor, 'Present'),
                      const SizedBox(width: 16),
                      _legendDot(absentColor,  'Absent'),
                      const SizedBox(width: 16),
                      _legendDot(c.accent,     'Today', isBorder: true),
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
}