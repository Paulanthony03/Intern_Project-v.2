import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final schoolController = TextEditingController();
  final programController = TextEditingController();
  final internIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
            /// TOP TITLE
            Positioned(
              top: 30,
              left: 50,
              child: Text(
                "Blacky",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                                                controller: firstNameController,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your First Name",
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
                                                controller: lastNameController,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your Last Name",
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
                                                controller: emailController,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your email",
                                                ),
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
                                                controller: internIdController,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                decoration: inputStyle(
                                                  "Enter your Intern ID",
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Intern ID is required";
                                                  }

                                                  if (!RegExp(
                                                    r'^[0-9]+$',
                                                  ).hasMatch(value)) {
                                                    return "Intern ID must contain numbers only";
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

                                    TextFormField(
                                      controller: schoolController,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      decoration: inputStyle(
                                        "Enter School Name",
                                      ),
                                      validator: (v) => v!.isEmpty
                                          ? "School name is required"
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
                                      controller: programController,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      decoration: inputStyle(
                                        "Enter your College Program",
                                      ),
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
                                                controller: passwordController,
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
                                                controller:
                                                    confirmPasswordController,
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
