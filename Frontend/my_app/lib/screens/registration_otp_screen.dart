import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegistrationOtpScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String internId;
  final String school;
  final String program;

  RegistrationOtpScreen({
    required this.email,
    required this.name,
    required this.password,
    required this.internId,
    required this.school,
    required this.program,
  });

  @override
  State<RegistrationOtpScreen> createState() => _RegistrationOtpScreenState();
}

class _RegistrationOtpScreenState extends State<RegistrationOtpScreen> {
  final otpController = TextEditingController();
  bool loading = false;

  Future<void> verifyOtp() async {
    setState(() => loading = true);

    final res = await ApiService.verifyRegistrationOtp(
      widget.email,
      otpController.text,
    );

    if (res.statusCode == 200) {
      // 🔥 NOW REGISTER USER
      final reg = await ApiService.register(
        widget.name,
        widget.email,
        widget.password,
        widget.internId,
        widget.school,
        widget.program,
      );
      setState(() => loading = false);

      if (reg == "success") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration successful")));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration failed")));
      }
    } else {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Verify Your Email",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),

              SizedBox(height: 10),

              Text(
                "OTP sent to ${widget.email}",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  filled: true,
                  fillColor: Colors.white12,
                ),
                style: TextStyle(color: Colors.white),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? CircularProgressIndicator()
                    : Text("Verify & Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
