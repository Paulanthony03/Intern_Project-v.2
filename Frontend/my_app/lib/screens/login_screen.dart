import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'package:flutter/foundation.dart';

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

static const Color maroon = Color(0xFF6B1010);
static const Color bgBeige = Color(0xFFF5EDE8);
static const Color cardPink = Color(0xFFE8D5D0);


  Future<void> loginUser() async {
    // 🔥 VALIDATE FIRST
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String? token = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid email or password")));
    }
  }

Widget buildField({
  required String label,
  required TextEditingController controller,
  bool obscureText = false,
  Widget? suffixIcon,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label, 
        style: TextStyle(
          color: maroon,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing:1.2,
          ),
          ),
      SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: maroon),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: maroon, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),                                             
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: bgBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey, // 🔥 IMPORTANT
            child: isLargeScreen
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 LEFT SIDE - IMAGE
                Expanded(
                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      Image.asset("assets/mylogo.png", height: 150),
                       SizedBox(height: 40),
                       Text("InternShip",
                    style: TextStyle(
                      fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: maroon,
                    letterSpacing: 4,
                  ),
                  ),
              ],
              ),
            ),
            SizedBox (width: 40),

              Expanded(child: _buildFormContent(),
              ),
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              kIsWeb
               ? Image.network(
               "assets/mylogo.png",
                height: 280,
                  errorBuilder: (context, error, stackTrace) {
                 return Icon(Icons.image_not_supported, size: 100, color: maroon);
                  },
               )
               : Image.asset(
                 "assets/mylogo.png",
                 height: 280,
                  errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 100, color: maroon);
                   },
                 ),
                    ],
              ),
            ),
          ),
            ),
            );
            }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Text("Welcome Back!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: maroon,
          ),
          ),
              SizedBox(height: 6),
              Text(
                "Let's Login to your account",
                style: TextStyle(
                  fontSize: 14,
                  color: maroon.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 32),
              //card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardPink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
              buildField(
                label: "Username",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
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

              SizedBox(height: 20),

              buildField(
                label: "Password",
                controller: passwordController,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                    color: maroon,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
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

              SizedBox(height: 28),

              // 🔹 LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: maroon,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  child: isLoading
                      ? CircularProgressIndicator(color: maroon)
                      : Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:16,
                          letterSpacing: 2,
                          ),
                          ),
                ),
              ),

              SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color:maroon.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Register now",
                    style:TextStyle(
                      color: maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      ),  
                    ),
                ),
               ],
              ),
             ],
             ),
        ),
      ],
    );
  }
}