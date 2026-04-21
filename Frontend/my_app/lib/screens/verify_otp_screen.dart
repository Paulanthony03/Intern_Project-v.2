import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color pageBg = Color(0xFF1A1A1A);
const Color cardBg = Color(0xFF222222);
const Color accent = Color(0xFFBFCF33);
const Color textMain = Colors.white;
const Color textMuted = Color(0xFF888888);

class VerifyOTPScreen extends StatefulWidget {
  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final otpController = TextEditingController();

  void verify(String email) async {
    final success = await ApiService.verifyOTP(email, otpController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(context, '/reset-password', arguments: email);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

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
                "Verify OTP",
                style: TextStyle(
                  color: textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the OTP sent to your email",
                style: TextStyle(color: textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                style: TextStyle(color: textMain),
                decoration: InputDecoration(
                  hintText: "6-digit OTP",
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
                  onPressed: () => verify(email),
                  child: Text(
                    "Verify",
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
