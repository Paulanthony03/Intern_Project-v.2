import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final result = await ApiService.forgotPassword(
                  emailController.text,
                );

                if (result != null && result['token'] != null) {
                  final token = result['token'];

                  Navigator.pushNamed(
                    context,
                    '/reset',
                    arguments: token, // ✅ pass token
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error sending reset link")),
                  );
                }
              },
              child: Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
