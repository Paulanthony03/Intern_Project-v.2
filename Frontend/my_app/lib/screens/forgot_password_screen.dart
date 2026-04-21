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
  final emailController = TextEditingController();

  void sendOTP() async {
    final success = await ApiService.forgotPassword(emailController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        '/verify-otp',
        arguments: emailController.text,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Center(
        child: Container(
          width: 380,
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
              const SizedBox(height: 10),
              Text(
                "Enter your email to receive OTP",
                style: TextStyle(color: textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
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
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: sendOTP,
                  child: Text(
                    "Send OTP",
                    style: TextStyle(
                      color: pageBg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
