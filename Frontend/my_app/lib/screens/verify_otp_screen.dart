import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VerifyOTPScreen extends StatefulWidget {
  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final otpController = TextEditingController();

  void verify(String email) async {
    final success = await ApiService.verifyOTP(email, otpController.text);

    if (success) {
      Navigator.pushNamed(context, '/reset-password', arguments: email);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: otpController),
            ElevatedButton(
              onPressed: () => verify(email),
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
