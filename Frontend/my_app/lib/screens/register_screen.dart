import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/form_persistence_service.dart';
import 'login_screen.dart';
import 'landing_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedSchool;
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final schoolController = TextEditingController();
  final programController = TextEditingController();
  final internIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final List<String> schoolOptions = [
    "Pamantasan ng Lungsod ng San Pablo",
    "CARD-MRI Development Institute",
    "Laguna State Polytechnic University",
  ];

  static const _screenKey = 'register';
  static const _fieldKeys = [
    'firstName',
    'lastName',
    'email',
    'school',
    'program',
    'internId',
    'password',
    'confirmPassword',
  ];

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    schoolController.dispose();
    programController.dispose();
    internIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadDrafts() async {
    final drafts = await FormPersistenceService.loadAllDrafts(
      _screenKey,
      _fieldKeys,
    );
    setState(() {
      if (drafts.containsKey('firstName'))
        firstNameController.text = drafts['firstName']!;
      if (drafts.containsKey('lastName'))
        lastNameController.text = drafts['lastName']!;
      if (drafts.containsKey('email')) emailController.text = drafts['email']!;
      if (drafts.containsKey('school')) selectedSchool = drafts['school'];
      schoolController.text = drafts['school'] ?? "";
      if (drafts.containsKey('program'))
        programController.text = drafts['program']!;
      if (drafts.containsKey('internId'))
        internIdController.text = drafts['internId']!;
      if (drafts.containsKey('password'))
        passwordController.text = drafts['password']!;
      if (drafts.containsKey('confirmPassword'))
        confirmPasswordController.text = drafts['confirmPassword']!;
    });
  }

  void _onFieldChanged(String fieldKey, String value) {
    FormPersistenceService.saveDraft(_screenKey, fieldKey, value);
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
      filled: true,
      fillColor: const Color.fromARGB(255, 41, 39, 39),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      isDense: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String? result = await ApiService.register(
      "${firstNameController.text} ${lastNameController.text}",
      emailController.text,
      passwordController.text,
      internIdController.text,
      schoolController.text,
    );

    setState(() => isLoading = false);

    if (result == "success") {
      await FormPersistenceService.clearDraft(_screenKey, _fieldKeys);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result ?? "Registration Failed")));
    }
  }

  Widget label(String text) {
    return Text(text, style: TextStyle(fontSize: 15, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 30,
              left: 50,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingScreen()),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blacky",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Form(
              key: _formKey,
              child: Row(
                children: [
                  /// LEFT SIDE
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 200),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Image.asset(
                                  "../assets/images/mylogo.png",
                                ),
                              ),

                              const SizedBox(height: 26),

                              Text(
                                "Set Up Account",
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 0),
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  child: SelectableText(
                                    "Register to access your intern profile and dashboard.",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        240,
                                        238,
                                        238,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// RIGHT SIDE FORM
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 1),
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Container(
                                width: 700,

                                padding: const EdgeInsets.only(
                                  left: 45,
                                  right: 45,
                                  top: 35,
                                  bottom: 35,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 50, 49, 49),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Create your Profile",
                                        style: TextStyle(
                                          fontSize: 27,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    /// FIRST + LAST
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "First Name",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller: firstNameController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your First Name",
                                                ),
                                                onChanged: (v) =>
                                                    _onFieldChanged(
                                                      'firstName',
                                                      v,
                                                    ),
                                                validator: (v) => v!.isEmpty
                                                    ? "First name is required"
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Last Name",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller: lastNameController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your Last Name",
                                                ),
                                                onChanged: (v) =>
                                                    _onFieldChanged(
                                                      'lastName',
                                                      v,
                                                    ),
                                                validator: (v) => v!.isEmpty
                                                    ? "Last name is required"
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    /// EMAIL + INTERN ID
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller: emailController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your email",
                                                ),
                                                onChanged: (v) =>
                                                    _onFieldChanged('email', v),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Email address is required";
                                                  }
                                                  final emailRegex = RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                  );
                                                  if (!emailRegex.hasMatch(
                                                    value,
                                                  )) {
                                                    return "Enter a valid email";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Intern ID",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller: internIdController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your Intern ID",
                                                ),
                                                onChanged: (v) =>
                                                    _onFieldChanged(
                                                      'internId',
                                                      v,
                                                    ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Intern ID is required";
                                                  }

                                                  if (!RegExp(
                                                    r'^[0-9-]+$',
                                                  ).hasMatch(value)) {
                                                    return "Intern ID must contain numbers and hyphens only";
                                                  }

                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    /// SCHOOL
                                    Text(
                                      "School",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color.fromARGB(
                                          255,
                                          215,
                                          214,
                                          214,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    DropdownButtonFormField<String>(
                                      value:
                                          schoolOptions.contains(selectedSchool)
                                          ? selectedSchool
                                          : null,
                                      isExpanded: true,
                                      dropdownColor: const Color.fromARGB(
                                        255,
                                        41,
                                        39,
                                        39,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      iconEnabledColor: Colors.white,

                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                          255,
                                          41,
                                          39,
                                          39,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 15,
                                            ),
                                      ),

                                      hint: const Text(
                                        "Select School",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),

                                      items: schoolOptions.map((school) {
                                        return DropdownMenuItem<String>(
                                          value: school,
                                          child: Text(
                                            school,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),

                                      onChanged: (value) {
                                        setState(() {
                                          selectedSchool = value;
                                        });

                                        schoolController.text = value ?? "";
                                        _onFieldChanged('school', value ?? "");
                                      },

                                      validator: (value) => value == null
                                          ? "School is required"
                                          : null,
                                    ),

                                    const SizedBox(height: 15),

                                    /// PROGRAM
                                    Text(
                                      "Program",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color.fromARGB(
                                          255,
                                          215,
                                          214,
                                          214,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    TextFormField(
                                      cursorColor: Color.fromARGB(
                                        114,
                                        114,
                                        114,
                                        114,
                                      ),
                                      controller: programController,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context).nextFocus(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      decoration: inputStyle(
                                        "Enter your College Program",
                                      ),
                                      onChanged: (v) =>
                                          _onFieldChanged('program', v),
                                      validator: (v) => v!.isEmpty
                                          ? "Program is required"
                                          : null,
                                    ),

                                    const SizedBox(height: 15),

                                    /// PASSWORDS
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Password",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller: passwordController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                obscureText: obscurePassword,
                                                decoration:
                                                    inputStyle(
                                                      "Create Password",
                                                    ).copyWith(
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                          obscurePassword
                                                              ? Icons
                                                                    .visibility_off
                                                              : Icons
                                                                    .visibility,
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                122,
                                                                120,
                                                                120,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            obscurePassword =
                                                                !obscurePassword;
                                                          });
                                                        },
                                                      ),
                                                      suffixIconConstraints:
                                                          const BoxConstraints(
                                                            minHeight: 30,
                                                            minWidth: 30,
                                                          ),
                                                    ),
                                                onChanged: (v) =>
                                                    _onFieldChanged(
                                                      'password',
                                                      v,
                                                    ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Password is required";
                                                  }
                                                  if (value.length < 6) {
                                                    return "Minimum 6 characters";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Confirm Password",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    215,
                                                    214,
                                                    214,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              TextFormField(
                                                cursorColor: Color.fromARGB(
                                                  114,
                                                  114,
                                                  114,
                                                  114,
                                                ),
                                                controller:
                                                    confirmPasswordController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                onFieldSubmitted: (_) =>
                                                    FocusScope.of(
                                                      context,
                                                    ).nextFocus(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                obscureText: obscureConfirm,
                                                decoration:
                                                    inputStyle(
                                                      "Confirm your Password",
                                                    ).copyWith(
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                          obscureConfirm
                                                              ? Icons
                                                                    .visibility_off
                                                              : Icons
                                                                    .visibility,
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                122,
                                                                120,
                                                                120,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            obscureConfirm =
                                                                !obscureConfirm;
                                                          });
                                                        },
                                                      ),
                                                      suffixIconConstraints:
                                                          const BoxConstraints(
                                                            minHeight: 30,
                                                            minWidth: 30,
                                                          ),
                                                    ),
                                                onChanged: (v) =>
                                                    _onFieldChanged(
                                                      'confirmPassword',
                                                      v,
                                                    ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please confirm your password";
                                                  }
                                                  if (value.length < 6) {
                                                    return "Minimum 6 characters";
                                                  }
                                                  if (value !=
                                                      passwordController.text) {
                                                    return "Passwords do not match";
                                                  }

                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 25),

                                    /// REGISTER BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            212,
                                            226,
                                            74,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : registerUser,
                                        child: isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.black,
                                              )
                                            : Text(
                                                "Register",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    /// LOGIN LINK
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Already have an account? ",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Login",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    212,
                                                    226,
                                                    74,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
