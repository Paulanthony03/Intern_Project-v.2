import 'package:flutter/material.dart';
import 'package:my_app/screens/landing_screen.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/user_dashboard.dart';
import 'package:my_app/screens/forgot_password_screen.dart';
import 'package:my_app/screens/verify_otp_screen.dart';
import 'package:my_app/screens/reset_password_screen.dart';
import 'package:my_app/screens/app_shell.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        '/': (context) => LandingScreen(),
        '/admin': (context) => AppShell(),
        '/user': (context) => UserDashboard(),
        '/login': (_) => LoginScreen(),
        '/forgot-password': (_) => ForgotPasswordScreen(),
        '/verify-otp': (_) => VerifyOTPScreen(),
        '/reset-password': (_) => ResetPasswordScreen(),
      },
    );
  }
}
