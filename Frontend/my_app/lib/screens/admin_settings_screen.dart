import 'package:flutter/material.dart';
import 'app_theme.dart';

// ════════════════════════════════════════════════════════
//  HOVER EDIT BUTTON
// ════════════════════════════════════════════════════════
class _HoverEditButton extends StatefulWidget {
  final VoidCallback onTap;
  final AppColors colors;
  const _HoverEditButton({required this.onTap, required this.colors});

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
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'Edit',
          style: TextStyle(
            color: _hovered ? widget.colors.accent : widget.colors.textMuted, // 👈
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
  final AppColors colors; // 👈

  const AdminSettings({
    super.key,
    this.adminData,
    required this.colors, // 👈
  });

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings>
    with SingleTickerProviderStateMixin {

  AppColors get c => widget.colors; // 👈 shortcut

  late TabController _tabController;

  late Map<String, String> _personalInfo;
  late Map<String, String> _loginInfo;

  String? _editingField;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  // ════════════════════════════════════════════════════════
  //  CHANGE PASSWORD DIALOG
  // ════════════════════════════════════════════════════════
  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew     = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: c.cardBg, // 👈
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('Change Password',
              style: TextStyle(color: c.textMain, // 👈
                  fontWeight: FontWeight.bold)),
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
              child: Text('Cancel',
                  style: TextStyle(color: c.textMuted)), // 👈
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
              child: Text('Save',
                  style: TextStyle(color: c.pageBg, // 👈
                      fontWeight: FontWeight.bold)),
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
      style: TextStyle(color: c.textMain, fontSize: 14), // 👈
      cursorColor: c.accent,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.textMuted, fontSize: 13), // 👈
        filled: true,
        fillColor: c.pageBg, // 👈
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.borderColor), // 👈
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.accent.withOpacity(0.6)),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              color: c.textMuted, size: 18), // 👈
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
      'name':           (data['name']           ?? 'Admin').toString(),
      'admin_id':       (data['admin_id']       ?? 'admin_08').toString(),
      'email':          (data['email']          ?? 'admin@test.com').toString(),
      'contact_number': (data['contact_number'] ?? '').toString(),
    };

    _loginInfo = {
      'username': (data['username'] ?? 'admin@test.com').toString(),
      'password': (data['password'] ?? '').toString(),
    };

    for (final key in [..._personalInfo.keys, ..._loginInfo.keys]) {
      _controllers[key] = TextEditingController();
      _focusNodes[key]  = FocusNode();
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
        _personalInfo[field] =
            newVal.isEmpty ? _personalInfo[field]! : newVal;
      } else {
        _loginInfo[field] =
            newVal.isEmpty ? _loginInfo[field]! : newVal;
      }
      _editingField = null;
    });
  }

  void _cancelEdit() => setState(() => _editingField = null);

  // ════════════════════════════════════════════════════════
  //  FIELD ROW
  // ════════════════════════════════════════════════════════
  Widget _buildFieldRow({
    required String label,
    required String field,
    required String value,
    required bool isPersonal,
    bool obscure = false,
    bool isLast  = false,
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
              Text(label,
                  style: TextStyle(
                    color: c.textMain, // 👈
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  )),

              // Edit / Save / Cancel
              if (!isEditing)
                _HoverEditButton(
               onTap: () {},
               colors: c,)
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: _cancelEdit,
                      child: Text('Cancel',
                          style: TextStyle(color: c.textMuted, // 👈
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _commitEdit(field, isPersonal),
                      child: Text('Save',
                          style: TextStyle(color: c.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: c.textMuted, fontSize: 14), // 👈
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _controllers[field],
              focusNode:  _focusNodes[field],
              obscureText: obscure,
              style: TextStyle(color: c.textMain, fontSize: 14), // 👈
              cursorColor: c.accent,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                filled: true,
                fillColor: c.cardBg, // 👈
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.borderColor), // 👈
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: c.accent.withOpacity(0.6)),
                ),
              ),
              onSubmitted: (_) => _commitEdit(field, isPersonal),
            ),
          ),

        Divider(color: c.borderColor, thickness: 1, height: 1), // 👈
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  PERSONAL INFO
  // ════════════════════════════════════════════════════════
  Widget _buildPersonalInfoContent() {
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg, // 👈
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderColor), // 👈
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFieldRow(label: 'Name',           field: 'name',
              value: _personalInfo['name']!,           isPersonal: true),
          _buildFieldRow(label: 'Admin ID',        field: 'admin_id',
              value: _personalInfo['admin_id']!,       isPersonal: true),
          _buildFieldRow(label: 'Email',           field: 'email',
              value: _personalInfo['email']!,          isPersonal: true),
          _buildFieldRow(label: 'Contact Number',  field: 'contact_number',
              value: _personalInfo['contact_number']!, isPersonal: true,
              isLast: true),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  LOGIN & SECURITY
  // ════════════════════════════════════════════════════════
  Widget _buildLoginSecurityContent() {
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg, // 👈
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderColor), // 👈
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFieldRow(label: 'Username', field: 'username',
              value: _loginInfo['username']!, isPersonal: false),
          // Password row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Password',
                        style: TextStyle(
                          color: c.textMain, // 👈
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    _HoverEditButton(onTap: _showChangePasswordDialog, colors: c),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 20),
                child: Text('•••••••••',
                    style: TextStyle(color: c.textMuted, fontSize: 14)), // 👈
              ),
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
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1450),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Avatar ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 175, height: 175,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.cardBg, // 👈
                          border: Border.all(
                            color: c.accent.withOpacity(0.6),
                            width: 3,
                          ),
                        ),
                        child: Icon(Icons.person,
                            color: c.textMuted, size: 68), // 👈
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: image picker
                          },
                          child: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: c.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c.pageBg, width: 2), // 👈
                            ),
                            child: Icon(Icons.camera_alt,
                                color: c.pageBg, size: 25), // 👈
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Two Columns ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left — Personal Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Info',
                              style: TextStyle(
                                color: c.textMain, // 👈
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 14),
                          _buildPersonalInfoContent(),
                        ],
                      ),
                    ),

                    const SizedBox(width: 50),

                    // Right — Login & Security
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login & Security',
                              style: TextStyle(
                                color: c.textMain, // 👈
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 14),
                          _buildLoginSecurityContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}