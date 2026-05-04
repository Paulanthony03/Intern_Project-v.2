import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color pageBg = Color(0xFF1A1A1A);
const Color cardBg = Color(0xFF222222);
const Color accent = Color(0xFFBFCF33);
const Color textMain = Colors.white;
const Color textMuted = Color(0xFF888888);

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String error = "";

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(email);
  }

  void sendOTP() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() => error = "Email is required");
      return;
    }

    if (!isValidEmail(email)) {
      setState(() => error = "Invalid email format");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final res = await ApiService.forgotPassword(email);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["message"])));

      // go to OTP screen
      Navigator.pushNamed(context, '/verify-otp', arguments: email);
    } catch (e) {
      setState(() => error = "No account found with this email");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Center(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Forgot Password",
                style: TextStyle(
                  color: textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Enter your email to receive OTP",
                style: TextStyle(color: textMuted),
              ),
              const SizedBox(height: 25),
              TextField(
                cursorColor: Color.fromARGB(114, 114, 114, 114),
                controller: emailController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: textMuted),
                  filled: true,
                  fillColor: pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  errorText: error.isEmpty ? null : error,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Send OTP",
                          style: TextStyle(
                            color: pageBg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}
