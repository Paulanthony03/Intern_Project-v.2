import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'app_theme.dart';

class UserProfile extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final AppColors colors;
  final void Function(Map<String, dynamic>)? onUserDataChanged;

  const UserProfile({
    super.key,
    required this.token,
    required this.userData,
    required this.colors,
    this.onUserDataChanged,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  AppColors get c => widget.colors;

  int _selectedTab = 0;

  // Local copy — updates instantly, then syncs to server via onUserDataChanged
  late Map<String, dynamic> _localUser;

  // Password controllers
  final _currentPassController  = TextEditingController();
  final _newPassController      = TextEditingController();
  final _confirmPassController  = TextEditingController();
  bool _obscureCurrent  = true;
  bool _obscureNew      = true;
  bool _obscureConfirm  = true;

  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _localUser = Map<String, dynamic>.from(widget.userData);
  }

  @override
  void didUpdateWidget(UserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userData != widget.userData) {
      setState(() => _localUser = Map<String, dynamic>.from(widget.userData));
    }
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  String _fullPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://10.22.0.127:8080$url';
  }

  Future<void> _pickImage() async {
   final picker = ImagePicker();
   final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
   if (picked != null) {
   final bytes = await picked.readAsBytes();
   setState(() => _pickedImageBytes = bytes);
   final updated = Map<String, dynamic>.from(_localUser);
   updated['photo_local'] = picked.path;
  updated['photo_bytes'] = bytes;
  widget.onUserDataChanged?.call(updated);
}
}

  void _showEditFieldDialog(String label, String fieldKey, String currentValue) {
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
              color: c.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit $label', style: TextStyle(color: c.accent, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: c.pageBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.accent.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(color: c.textMain, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: c.textMuted)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                final newValue = controller.text.trim();
                                if (newValue.isEmpty) return;
                                setDialog(() => isSaving = true);
                                setState(() => _localUser[fieldKey] = newValue);
                                widget.onUserDataChanged?.call(_localUser);
                                if (mounted) Navigator.pop(ctx);
                              },
                        child: isSaving
                            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.pageBg))
                            : Text('Save', style: TextStyle(color: c.pageBg, fontWeight: FontWeight.bold)),
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
    final name      = _localUser['name']      ?? 'Intern Name';
    final internId  = _localUser['intern_id']?.toString() ?? _localUser['id']?.toString() ?? '-';
    final email     = _localUser['email']     ?? '-';
    final contact   = _localUser['contact']   ?? _localUser['contact_no'] ?? '-';
    final photoUrl  = _localUser['photo_url'] ?? _localUser['photo'];

    return Container(
      color: c.pageBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with tabs
          Container(
            color: c.pageBg,
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    _tab('Personal Info',    0),
                    const SizedBox(width: 32),
                    _tab('Login & Security', 1),
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
              color: selected ? c.accent : c.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: label.length * 8.5,
            color: selected ? c.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(
    String name, String internId, String email, String contact, String? photoUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
         // onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: c.borderColor,
                backgroundImage: _pickedImageBytes != null
                    ? MemoryImage(_pickedImageBytes!) as ImageProvider
                    : (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(_fullPhotoUrl(photoUrl))
                        : null,
                child: (_pickedImageBytes == null && (photoUrl == null || photoUrl.isEmpty))
                    ? Icon(Icons.person, size: 44, color: c.textMuted)
                    : null,
              ),
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.pageBg, width: 2),
                  ),
                  child: Icon(Icons.camera_alt_rounded, size: 14, color: c.pageBg),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _fieldRow('Name',          'name',      name),
        _fieldRow('Intern ID',     'intern_id', internId, editable: false),
        _fieldRow('Email',         'email',     email),
        _fieldRow('Contact Number','contact',   contact),
      ],
    );
  }

  Widget _fieldRow(String label, String fieldKey, String value, {bool editable = true}) {
    return Column(
      children: [
        InkWell(
          onTap: editable ? () => _showEditFieldDialog(label, fieldKey, value) : null,
          borderRadius: BorderRadius.circular(8),
          hoverColor: editable ? c.accent.withOpacity(0.05) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(color: c.textMain, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(value.isEmpty ? '—' : value, style: TextStyle(color: c.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                if (editable)
                  Text('Edit', style: TextStyle(color: c.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        Divider(color: c.borderColor, height: 1),
      ],
    );
  }

  Widget _buildLoginSecurity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.textMain)),
        const SizedBox(height: 6),
        Text('Choose a strong password you don\'t use elsewhere.', style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 28),
        _passwordField('Current Password', _currentPassController, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
        const SizedBox(height: 16),
        _passwordField('New Password',     _newPassController,     _obscureNew,     () => setState(() => _obscureNew = !_obscureNew)),
        const SizedBox(height: 16),
        _passwordField('Confirm Password', _confirmPassController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
        const SizedBox(height: 28),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _handleChangePassword,
            child: Text('Update Password', style: TextStyle(color: c.pageBg, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: c.pageBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.accent.withOpacity(0.4)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(color: c.textMain, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: c.textMuted, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleChangePassword() {
    final current = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _snack('Please fill in all fields.', Colors.redAccent); return;
    }
    if (newPass != confirm) {
      _snack('New passwords do not match.', Colors.redAccent); return;
    }
    if (newPass.length < 6) {
      _snack('Password must be at least 6 characters.', Colors.redAccent); return;
    }
    // TODO: wire to ApiService.changePassword(token, current, newPass)
    _snack('Password updated successfully!', const Color(0xFF4CAF50));
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}