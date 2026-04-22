import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color pageBg = Color(0xFF1A1A1A);
const Color cardBg = Color(0xFF222222);
const Color accent = Color(0xFFBFCF33);
const Color textMain = Colors.white;
const Color textMuted = Color(0xFF888888);

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();

  void reset(String email) async {
    final success = await ApiService.resetPassword(
      email,
      passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Reset failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

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
                "Reset Password",
                style: TextStyle(
                  color: textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your new password",
                style: TextStyle(color: textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                cursorColor: Color.fromARGB(114, 114, 114, 114),
                controller: passwordController,
                obscureText: false,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  hintText: "New Password",
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
                  onPressed: () => reset(email),
                  child: Text(
                    "Reset Password",
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
