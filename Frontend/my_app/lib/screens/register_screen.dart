import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      isDense: true,
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
    return Text(
      text,
      style: GoogleFonts.googleSans(fontSize: 11, color: Colors.white),
    );
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
                style: GoogleFonts.googleSans(
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Image.asset("../assets/images/mylogo.png"),
                          ),

                          const SizedBox(height: 50),

                          Text(
                            "Set Up Account",
                            style: GoogleFonts.googleSans(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 0),

                          Text(
                            "Register to access your intern profile and dashboard.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.googleSans(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// RIGHT SIDE FORM
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Container(
                            width: 700,

                            padding: const EdgeInsets.only(
                              top: 30,
                              left: 30,
                              right: 30,
                              bottom: 20,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 50, 49, 49),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Create your Profile",
                                  style: GoogleFonts.googleSans(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                          label("First Name"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller: firstNameController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            decoration: inputStyle(
                                              "Enter your First Name",
                                            ),
                                            validator: (v) =>
                                                v!.isEmpty ? "Required" : null,
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
                                          label("Last Name"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller: lastNameController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            decoration: inputStyle(
                                              "Enter your Last Name",
                                            ),
                                            validator: (v) =>
                                                v!.isEmpty ? "Required" : null,
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
                                          label("Email"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller: emailController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            decoration: inputStyle(
                                              "Enter your email",
                                            ),
                                            validator: (v) =>
                                                v!.isEmpty ? "Required" : null,
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
                                          label("Intern ID"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller: internIdController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            decoration: inputStyle(
                                              "Enter your Intern ID",
                                            ),
                                            validator: (v) =>
                                                v!.isEmpty ? "Required" : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                /// SCHOOL
                                label("School"),
                                const SizedBox(height: 5),

                                TextFormField(
                                  controller: schoolController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: inputStyle("Enter School Name"),
                                  validator: (v) =>
                                      v!.isEmpty ? "Required" : null,
                                ),

                                const SizedBox(height: 15),

                                /// PROGRAM
                                label("Program"),
                                const SizedBox(height: 5),

                                TextFormField(
                                  controller: programController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: inputStyle(
                                    "Enter your College Program",
                                  ),
                                  validator: (v) =>
                                      v!.isEmpty ? "Required" : null,
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
                                          label("Password"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller: passwordController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            obscureText: obscurePassword,
                                            decoration:
                                                inputStyle(
                                                  "Create Password",
                                                ).copyWith(
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      obscurePassword
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.white,
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
                                          label("Confirm Password"),
                                          const SizedBox(height: 5),

                                          TextFormField(
                                            controller:
                                                confirmPasswordController,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            obscureText: obscureConfirm,
                                            decoration:
                                                inputStyle(
                                                  "Confirm your Password",
                                                ).copyWith(
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      obscureConfirm
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.white,
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
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        212,
                                        226,
                                        74,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : registerUser,
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.black,
                                          )
                                        : Text(
                                            "Register",
                                            style: GoogleFonts.googleSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// LOGIN LINK
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Already have an account? ",
                                        style: GoogleFonts.googleSans(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Login",
                                            style: GoogleFonts.googleSans(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
