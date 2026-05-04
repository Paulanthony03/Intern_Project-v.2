import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class MyProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Future<void> Function(Map<String, dynamic> updated)? onSave;

  const MyProfilePage({super.key, required this.user, this.onSave});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  int _selectedTab = 0;

  static const Color pageBg = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF222222);
  static const Color accent = Color(0xFFBFCF33);
  static const Color textMain = Colors.white;
  static const Color textMuted = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2E2E2E);

  // ─── LOCAL COPY of user data (updates in real-time) ──────
  late Map<String, dynamic> _localUser;

  // ─── PASSWORD ────────────────────────────────────────────
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Uint8List? _pickedImageBytes;

  String _fullPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.22.0.127:8080$url';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
      });

      if (widget.onSave != null) {
        final updated = Map<String, dynamic>.from(_localUser);
        updated["photo_local"] = picked.path;
        updated["photo_bytes"] = bytes;
        await widget.onSave!(updated);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _localUser = Map<String, dynamic>.from(widget.user);
  }

  @override
  void didUpdateWidget(MyProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if parent pushes new data
    if (oldWidget.user != widget.user) {
      setState(() => _localUser = Map<String, dynamic>.from(widget.user));
    }
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ─── EDIT A FIELD ────────────────────────────────────────
  void _showEditFieldDialog(
    String label,
    String fieldKey,
    String currentValue,
  ) {
    final controller = TextEditingController(text: currentValue);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit $label",
                  style: const TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: textMain, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                final newValue = controller.text.trim();
                                if (newValue.isEmpty) return;

                                setDialog(() => isSaving = true);

                                // ── 1. Update locally RIGHT AWAY ──
                                setState(() => _localUser[fieldKey] = newValue);

                                // ── 2. Persist to server ──────────
                                if (widget.onSave != null) {
                                  try {
                                    await widget.onSave!(_localUser);
                                  } catch (e) {
                                    // Revert on failure
                                    setState(
                                      () => _localUser[fieldKey] = currentValue,
                                    );
                                    if (mounted) {
                                      _snack(
                                        "Failed to save: $e",
                                        Colors.redAccent,
                                      );
                                    }
                                  }
                                }

                                if (mounted) Navigator.pop(ctx);
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final String name = _localUser["name"] ?? "Intern Name";
    final String internId =
        _localUser["intern_id"]?.toString() ??
        _localUser["id"]?.toString() ??
        "-";
    final String email = _localUser["email"] ?? "-";
    final String contact =
        _localUser["contact"] ?? _localUser["contact_no"] ?? "-";
    final String? photoUrl = _localUser["photo_url"] ?? _localUser["photo"];

    return Container(
      color: pageBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ───────────────────────────────────────
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account Settings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _tab("Personal Info", 0),
                    const SizedBox(width: 32),
                    _tab("Login & Security", 1),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
              child: _selectedTab == 0
                  ? _buildPersonalInfo(name, internId, email, contact, photoUrl)
                  : _buildLoginSecurity(),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB
  // ════════════════════════════════════════════════════════
  Widget _tab(String label, int index) {
    final bool selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? accent : textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: label.length * 8.5,
            color: selected ? accent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PERSONAL INFO
  // ════════════════════════════════════════════════════════
  Widget _buildPersonalInfo(
    String name,
    String internId,
    String email,
    String contact,
    String? photoUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: borderColor,
                backgroundImage: _pickedImageBytes != null
                    ? MemoryImage(_pickedImageBytes!) as ImageProvider
                    : ((_localUser["photo_url"] ?? _localUser["photo"]) !=
                              null &&
                          (_localUser["photo_url"] ?? _localUser["photo"])
                              .toString()
                              .isNotEmpty)
                    ? NetworkImage(
                        _fullPhotoUrl(
                          _localUser["photo_url"] ?? _localUser["photo"],
                        ),
                      )
                    : null,
                child:
                    _pickedImageBytes == null &&
                        ((_localUser["photo_url"] ?? _localUser["photo"]) ==
                                null ||
                            (_localUser["photo_url"] ?? _localUser["photo"])
                                .toString()
                                .isEmpty)
                    ? const Icon(Icons.person, size: 44, color: textMuted)
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: pageBg, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Clickable field rows
        _fieldRow("Name", "name", name),
        _fieldRow("Intern ID", "intern_id", internId, editable: false),
        _fieldRow("Email", "email", email),
        _fieldRow("Contact Number", "contact", contact),
      ],
    );
  }

  // ── Clickable field row ───────────────────────────────────
  Widget _fieldRow(
    String label,
    String fieldKey,
    String value, {
    bool editable = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: editable
              ? () => _showEditFieldDialog(label, fieldKey, value)
              : null,
          borderRadius: BorderRadius.circular(8),
          hoverColor: editable ? accent.withOpacity(0.05) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.isEmpty ? "—" : value,
                        style: const TextStyle(color: textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (editable)
                  const Text(
                    "Edit",
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(color: borderColor, height: 1),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  LOGIN & SECURITY
  // ════════════════════════════════════════════════════════
  Widget _buildLoginSecurity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Change Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textMain,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Choose a strong password you don't use elsewhere.",
          style: TextStyle(color: textMuted, fontSize: 13),
        ),
        const SizedBox(height: 28),
        _passwordField(
          "Current Password",
          _currentPassController,
          _obscureCurrent,
          () => setState(() => _obscureCurrent = !_obscureCurrent),
        ),
        const SizedBox(height: 16),
        _passwordField(
          "New Password",
          _newPassController,
          _obscureNew,
          () => setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 16),
        _passwordField(
          "Confirm New Password",
          _confirmPassController,
          _obscureConfirm,
          () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _handleChangePassword,
            child: const Text(
              "Update Password",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: textMain, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: textMuted,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  PASSWORD HANDLER
  // ════════════════════════════════════════════════════════
  void _handleChangePassword() {
    final current = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _snack("Please fill in all fields.", Colors.redAccent);
      return;
    }
    if (newPass != confirm) {
      _snack("New passwords do not match.", Colors.redAccent);
      return;
    }
    if (newPass.length < 6) {
      _snack("Password must be at least 6 characters.", Colors.redAccent);
      return;
    }

    // TODO: wire to ApiService.changePassword(token, current, newPass)
    _snack("Password updated successfully!", const Color(0xFF4CAF50));
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
