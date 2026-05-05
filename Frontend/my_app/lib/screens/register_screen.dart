import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'landing_screen.dart';
import 'registration_otp_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// ─────────────────────────────────────────────
// THEME COLORS
// ─────────────────────────────────────────────
class AppColors {
  AppColors._(); // prevent instantiation

  static const background       = Color(0xFF323131);
  static const fieldFill        = Color(0xFF292727);
  static const accent           = Color(0xFFD4E24A);
  static const textPrimary      = Colors.white;
  static const textSecondary    = Color(0xFFD7D6D6);
  static const textHint         = Color(0x72727272);
  static const textMuted        = Color(0xFF7A7878);
  static const cursorColor      = Color(0x72727272);
  static const focusBorder      = Colors.white;
}

// ─────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // ── Form Key ──────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────
  final _firstNameController      = TextEditingController();
  final _lastNameController       = TextEditingController();
  final _emailController          = TextEditingController();
  final _schoolController         = TextEditingController();
  final _programController        = TextEditingController();
  final _internIdController       = TextEditingController();
  final _passwordController       = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── State ─────────────────────────────────
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  // ── School Options ────────────────────────
  static const List<String> _schoolOptions = [
    'Pamantasan ng Lungsod ng San Pablo',
    'Laguna State Polytechnic University',
    'CARD-MRI Development Institute, Inc.',
  ];

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _programController.dispose();
    _internIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  /// Shared [InputDecoration] for all text fields.
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.focusBorder, width: 2),
      ),
    );
  }

  /// Label widget used above each field.
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
    );
  }

  /// A [TextFormField] pre-styled with the app theme.
  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColors.cursorColor,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: _inputStyle(hint).copyWith(suffixIcon: suffixIcon),
      validator: validator,
    );
  }

  /// Eye-toggle icon for password fields.
  Widget _visibilityToggle(bool isObscured, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off : Icons.visibility,
        color: AppColors.textMuted,
      ),
      onPressed: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─────────────────────────────────────────────
  // REGISTER ACTION
  // ─────────────────────────────────────────────
 Future<void> _registerUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final email = _emailController.text;
  final res = await ApiService.sendRegistrationOtp(email);

  setState(() => _isLoading = false);

  if (res == null) {
    _showSnackBar('Something went wrong. Try again.');
  } else if (res['error'] == 'Email already exists') {
    _showSnackBar('Email already exists');
  } else if (res['message'] != null) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationOtpScreen(
          email:    email,
          name:     '${_firstNameController.text} ${_lastNameController.text}',
          password: _passwordController.text,
          internId: _internIdController.text,
          school:   _schoolController.text,
          program:  _programController.text,
        ),
      ),
    );
  }
}

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('../assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            _buildLogo(),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  _buildLeftPanel(),
                  _buildRightPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LOGO (top-left)
  // ─────────────────────────────────────────────
  Widget _buildLogo() {
    return Positioned(
      top: 30,
      left: 50,
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LandingScreen()),
        ),
        child: const Text(
          'Blacky',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LEFT PANEL — branding / illustration
  // ─────────────────────────────────────────────
  Widget _buildLeftPanel() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Image.asset('../assets/images/mylogo.png'),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Set Up Account',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.3,
                  ),
                  child: const SelectableText(
                    'Register to access your intern profile and dashboard.',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RIGHT PANEL — registration form
  // ─────────────────────────────────────────────
  Widget _buildRightPanel() {
    return Expanded(
      flex: 2,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Container(
              width: 700,
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 35),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormTitle(),
                  const SizedBox(height: 25),
                  _buildNameRow(),
                  const SizedBox(height: 15),
                  _buildEmailAndInternIdRow(),
                  const SizedBox(height: 15),
                  _buildSchoolDropdown(),
                  const SizedBox(height: 15),
                  _buildProgramField(),
                  const SizedBox(height: 15),
                  _buildPasswordRow(),
                  const SizedBox(height: 25),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FORM SECTIONS
  // ─────────────────────────────────────────────

  Widget _buildFormTitle() {
    return const Align(
      alignment: Alignment.center,
      child: Text(
        'Create your Profile',
        style: TextStyle(
          fontSize: 27,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// First Name + Last Name
  Widget _buildNameRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('First Name'),
              const SizedBox(height: 5),
              _styledField(
                controller: _firstNameController,
                hint: 'Enter your First Name',
                validator: (v) => v!.isEmpty ? 'First name is required' : null,
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Last Name'),
              const SizedBox(height: 5),
              _styledField(
                controller: _lastNameController,
                hint: 'Enter your Last Name',
                validator: (v) => v!.isEmpty ? 'Last name is required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Email + Intern ID
  Widget _buildEmailAndInternIdRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Email'),
              const SizedBox(height: 5),
              _styledField(
                controller: _emailController,
                hint: 'Enter your email',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email address is required';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Intern ID'),
              const SizedBox(height: 5),
              _styledField(
                controller: _internIdController,
                hint: 'Enter your Intern ID',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Intern ID is required';
                  if (!RegExp(r'^[0-9-]+$').hasMatch(value)) {
                    return 'Intern ID must contain numbers and hyphens only';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// School dropdown
  Widget _buildSchoolDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('School'),
      const SizedBox(height: 5),
      DropdownButtonFormField2<String>(
        value: _schoolController.text.isEmpty ? null : _schoolController.text,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: _inputStyle('Select your School'),
        hint: const Text(
          'Select your School',
          style: TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
         offset: const Offset(0, -8),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          openInterval: const Interval(0, 1),  
          isOverButton: false,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
        ),
        items: _schoolOptions
            .map((school) => DropdownMenuItem(
                  value: school,
                  child: Text(
                    school,
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  ),
                ))
            .toList(),
        onChanged: (value) => setState(() => _schoolController.text = value ?? ''),
        validator: (v) => (v == null || v.isEmpty) ? 'School name is required' : null,
      ),
    ],
  );
}

  /// Program field
  Widget _buildProgramField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Program'),
        const SizedBox(height: 5),
        _styledField(
          controller: _programController,
          hint: 'Enter your College Program',
          validator: (v) => v!.isEmpty ? 'Program is required' : null,
        ),
      ],
    );
  }

  /// Password + Confirm Password
  Widget _buildPasswordRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Password'),
              const SizedBox(height: 5),
              _styledField(
                controller: _passwordController,
                hint: 'Create Password',
                obscureText: _obscurePassword,
                suffixIcon: _visibilityToggle(
                  _obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Confirm Password'),
              const SizedBox(height: 5),
              _styledField(
                controller: _confirmPasswordController,
                hint: 'Confirm your Password',
                obscureText: _obscureConfirm,
                suffixIcon: _visibilityToggle(
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value.length < 6) return 'Minimum 6 characters';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Register button
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: _isLoading ? null : _registerUser,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  /// "Already have an account? Login" link
  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            children: [
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}