import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';
import 'register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

String? emailError;
String? passwordError;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      isDense: true,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    var result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", result["token"]);
      await prefs.setString("role", result["role"]);

      if (result["role"].toString().toLowerCase() == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard()),
        );
      }
    }
    if (result == null) {
      setState(() {
        emailError = "Invalid email or password";
        passwordError = "Invalid email or password";
      });
      return;
    }
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
              child: Text(
                "crescent",
                style: GoogleFonts.googleSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT LOGO
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 200),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: Image.asset(
                                  '../assets/images/mylogo.png',
                                ),
                              ),

                              const SizedBox(height: 50),

                              Text(
                                "Welcome Back!",
                                style: GoogleFonts.googleSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: const Color.fromARGB(
                                    255,
                                    240,
                                    238,
                                    238,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 1),

                              SelectableText(
                                "Access your account to manage intern profiles and dashboards.",
                                style: GoogleFonts.googleSans(
                                  fontSize: 15,
                                  color: const Color.fromARGB(
                                    255,
                                    240,
                                    238,
                                    238,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 150),

                            Padding(
                              padding: const EdgeInsets.only(
                                right: 50,
                                top: 40,
                              ),
                              child: Container(
                                width: 500,
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 50, 49, 49),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Login",
                                      style: GoogleFonts.googleSans(
                                        fontSize: 15,
                                        color: const Color.fromARGB(
                                          255,
                                          240,
                                          238,
                                          238,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // EMAIL LABEL
                                    Text(
                                      "Email",
                                      style: GoogleFonts.googleSans(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // EMAIL
                                    TextFormField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter your email",
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        errorText: emailError,
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
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 15,
                                            ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter your email";
                                        }
                                        final emailRegex = RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        );
                                        if (!emailRegex.hasMatch(value)) {
                                          return "Enter a valid email";
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 15),

                                    // EMAIL LABEL
                                    Text(
                                      "Password",
                                      style: GoogleFonts.googleSans(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // PASSWORD
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: obscurePassword,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),

                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter your password",
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        errorText: passwordError,
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                          255,
                                          41,
                                          39,
                                          39,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 15,
                                            ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color.fromARGB(
                                              255,
                                              140,
                                              139,
                                              139,
                                            ),
                                          ),
                                          onPressed: () => setState(
                                            () => obscurePassword =
                                                !obscurePassword,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter your password";
                                        }
                                        if (value.length < 6) {
                                          return "Minimum 6 characters";
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Forgot Password?",
                                              style: GoogleFonts.googleSans(
                                                color: Colors.grey,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // LOGIN BUTTON
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
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: isLoading ? null : loginUser,
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.black,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                "Login",
                                                style: GoogleFonts.googleSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    // REGISTER LINK
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Don't have an account? ",
                                            style: GoogleFonts.googleSans(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Register",
                                                style: GoogleFonts.googleSans(
                                                  fontSize: 10,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
