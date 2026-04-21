import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  void sendOTP() async {
    final success = await ApiService.forgotPassword(emailController.text);

    if (success) {
      Navigator.pushNamed(
        context,
        '/verify-otp',
        arguments: emailController.text,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController),
            ElevatedButton(onPressed: sendOTP, child: Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
