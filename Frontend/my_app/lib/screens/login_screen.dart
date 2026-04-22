import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';
import 'user_dashboard.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'landing_screen.dart';

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
      filled: true,
      fillColor: const Color.fromARGB(255, 41, 39, 39),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
      final token = result["token"];

      await prefs.setString("token", result["token"]);
      await prefs.setString("role", result["role"]);

      if (result["role"].toString().toLowerCase() == "admin") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard(token: token)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard(token: token)),
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

            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Form(
                  key: _formKey,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LEFT LOGO
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
                                      '../assets/images/mylogo.png',
                                    ),
                                  ),

                                  const SizedBox(height: 26),

                                  Text(
                                    "Welcome Back!",
                                    style: TextStyle(
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

                                  Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                      ),
                                      child: SelectableText(
                                        "Access your account to manage intern profiles and dashboards.",
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

                      Expanded(
                        flex: 2,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 45),
                                  child: Container(
                                    width: 650,
                                    padding: const EdgeInsets.only(
                                      left: 45,
                                      right: 45,
                                      top: 35,
                                      bottom: 35,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        51,
                                        49,
                                        49,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            "Login to Blacky",
                                            style: TextStyle(
                                              fontSize: 27,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                255,
                                                240,
                                                238,
                                                238,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 25),

                                        // EMAIL LABEL
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

                                        // EMAIL
                                        TextFormField(
                                          cursorColor: Color.fromARGB(
                                            114,
                                            114,
                                            114,
                                            114,
                                          ),
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
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
                                              fontSize: 11,
                                              color: Color.fromARGB(
                                                221,
                                                158,
                                                158,
                                                158,
                                              ),
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 18,
                                                  horizontal: 15,
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Email address is required";
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

                                        // PASSWORD
                                        TextFormField(
                                          cursorColor: Color.fromARGB(
                                            114,
                                            114,
                                            114,
                                            114,
                                          ),
                                          controller: passwordController,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                          obscureText: obscurePassword,

                                          decoration:
                                              InputDecoration(
                                                hintText: "Enter your password",
                                                hintStyle: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color.fromARGB(
                                                    221,
                                                    158,
                                                    158,
                                                    158,
                                                  ),
                                                ),
                                              ).copyWith(
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    obscurePassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      122,
                                                      120,
                                                      120,
                                                    ),
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      obscurePassword =
                                                          !obscurePassword;
                                                    });
                                                  },
                                                ),

                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                errorText: passwordError,
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                  255,
                                                  41,
                                                  39,
                                                  39,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
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

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ForgotPasswordScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: const Color.fromARGB(
                                                  255,
                                                  126,
                                                  123,
                                                  123,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 35),

                                        // LOGIN BUTTON
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    212,
                                                    226,
                                                    74,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : loginUser,
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
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

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
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Register",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          const Color.fromARGB(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
