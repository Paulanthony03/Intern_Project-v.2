import 'package:flutter/material.dart';
import 'otp_screen.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;

  void sendOtp() async {
    setState(() => loading = true);

    final res = await ApiService.forgotPassword(emailController.text);

    setState(() => loading = false);

    if (res.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email not found or error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : sendOtp,
              child: Text(loading ? "Sending..." : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
