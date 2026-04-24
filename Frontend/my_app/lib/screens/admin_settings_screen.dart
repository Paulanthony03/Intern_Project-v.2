import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  HOVER EDIT BUTTON
// ════════════════════════════════════════════════════════
class _HoverEditButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverEditButton({required this.onTap});

  @override
  State<_HoverEditButton> createState() => _HoverEditButtonState();
}

class _HoverEditButtonState extends State<_HoverEditButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'Edit',
          style: TextStyle(
            color: _hovered
                ? const Color.fromARGB(255, 212, 226, 74)
                : const Color(0xFF888888),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  SETTINGS SCREEN
// ════════════════════════════════════════════════════════
class AdminSettings extends StatefulWidget {
  final Map<String, dynamic>? adminData;
  const AdminSettings({super.key, this.adminData});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings>
    with SingleTickerProviderStateMixin {
  // ── THEME COLORS ──────────────────────────────────────
  static const pageBg = Color(0xFF111111);
  static const cardBg = Color(0xFF1A1A1A);
  static const borderColor = Color(0xFF2A2A2A);
  static const accent = Color.fromARGB(255, 212, 226, 74);
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF888888);

  late TabController _tabController;

  // ── EDITABLE FIELDS STATE ─────────────────────────────
  late Map<String, String> _personalInfo;
  late Map<String, String> _loginInfo;

  String? _editingField;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  // ── CHANGE PASSWORD DIALOG ────────────────────────────
  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Change Password',
            style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(
                controller: currentCtrl,
                label: 'Current Password',
                obscure: obscureCurrent,
                onToggle: () =>
                    setLocal(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: newCtrl,
                label: 'New Password',
                obscure: obscureNew,
                onToggle: () => setLocal(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: confirmCtrl,
                label: 'Confirm New Password',
                obscure: obscureConfirm,
                onToggle: () =>
                    setLocal(() => obscureConfirm = !obscureConfirm),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: textMuted)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                setState(() => _loginInfo['password'] = newCtrl.text);
                Navigator.pop(ctx);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: pageBg, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: textMain, fontSize: 14),
      cursorColor: accent,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF111111),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent.withOpacity(0.6)),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final data = widget.adminData ?? {};

    _personalInfo = {
      'name': (data['name'] ?? 'Admin').toString(),
      'admin_id': (data['admin_id'] ?? 'admin_08').toString(),
      'email': (data['email'] ?? 'admin@test.com').toString(),
      'contact_number': (data['contact_number'] ?? '').toString(),
    };

    _loginInfo = {
      'username': (data['username'] ?? 'admin@test.com').toString(),
      'password': (data['password'] ?? '').toString(),
    };

    for (final key in [..._personalInfo.keys, ..._loginInfo.keys]) {
      _controllers[key] = TextEditingController();
      _focusNodes[key] = FocusNode();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) c.dispose();
    for (final f in _focusNodes.values) f.dispose();
    super.dispose();
  }

  // ── EDIT HELPERS ──────────────────────────────────────
  void _startEdit(String field, String currentValue) {
    setState(() {
      _editingField = field;
      _controllers[field]!.text = currentValue;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[field]?.requestFocus();
    });
  }

  void _commitEdit(String field, bool isPersonal) {
    final newVal = _controllers[field]!.text.trim();
    setState(() {
      if (isPersonal) {
        _personalInfo[field] = newVal.isEmpty ? _personalInfo[field]! : newVal;
      } else {
        _loginInfo[field] = newVal.isEmpty ? _loginInfo[field]! : newVal;
      }
      _editingField = null;
    });
  }

  void _cancelEdit() => setState(() => _editingField = null);

  // ── FIELD ROW ─────────────────────────────────────────
  Widget _buildFieldRow({
    required String label,
    required String field,
    required String value,
    required bool isPersonal,
    bool obscure = false,
  }) {
    final isEditing = _editingField == field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label
              Text(
                label,
                style: const TextStyle(
                  color: textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),

              // Edit / Save / Cancel
              if (!isEditing)
                _HoverEditButton(onTap: () => _startEdit(field, value))
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: _cancelEdit,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _commitEdit(field, isPersonal),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Value / inline text field
        if (!isEditing)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              obscure ? '•' * 9 : value,
              style: const TextStyle(color: textMuted, fontSize: 14),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _controllers[field],
              focusNode: _focusNodes[field],
              obscureText: obscure,
              style: const TextStyle(color: textMain, fontSize: 14),
              cursorColor: accent,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                filled: true,
                fillColor: cardBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent.withOpacity(0.6)),
                ),
              ),
              onSubmitted: (_) => _commitEdit(field, isPersonal),
            ),
          ),

        const Divider(color: borderColor, thickness: 1, height: 1),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  PERSONAL INFO TAB
  // ════════════════════════════════════════════════════════
  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardBg,
                    border: Border.all(
                      color: accent.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.person, color: textMuted, size: 56),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: image picker
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: pageBg, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: pageBg,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _buildFieldRow(
            label: 'Name',
            field: 'name',
            value: _personalInfo['name']!,
            isPersonal: true,
          ),
          _buildFieldRow(
            label: 'Admin ID',
            field: 'admin_id',
            value: _personalInfo['admin_id']!,
            isPersonal: true,
          ),
          _buildFieldRow(
            label: 'Email',
            field: 'email',
            value: _personalInfo['email']!,
            isPersonal: true,
          ),
          _buildFieldRow(
            label: 'Contact Number',
            field: 'contact_number',
            value: _personalInfo['contact_number']!,
            isPersonal: true,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  LOGIN & SECURITY TAB
  // ════════════════════════════════════════════════════════
  Widget _buildLoginSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldRow(
            label: 'Username',
            field: 'username',
            value: _loginInfo['username']!,
            isPersonal: false,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _HoverEditButton(onTap: _showChangePasswordDialog),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  '•••••••••',
                  style: TextStyle(color: textMuted, fontSize: 14),
                ),
              ),
              const Divider(color: borderColor, thickness: 1, height: 1),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: accent,
          unselectedLabelColor: textMuted,
          indicatorColor: accent,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Login & Security'),
          ],
        ),

        const Divider(color: borderColor, height: 1, thickness: 1),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildPersonalInfoTab(), _buildLoginSecurityTab()],
          ),
        ),
      ],
    );
  }
}
