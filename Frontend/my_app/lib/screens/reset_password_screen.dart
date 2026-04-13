import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                bool success = await ApiService.resetPassword(
                  widget.token,
                  passwordController.text,
                );

                if (success) {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              },
              child: Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
