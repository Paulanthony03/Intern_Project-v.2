import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart'; // create this
import 'screens/user_dashboard.dart'; // create this
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ START SCREEN
      initialRoute: '/',

      // ✅ DEFINE ROUTES HERE
      routes: {
        '/': (context) => LoginScreen(),
        '/admin': (context) => AdminDashboard(),
        '/user': (context) => UserDashboard(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/reset-password': (context) => ResetPasswordScreen(
          token: ModalRoute.of(context)!.settings.arguments as String,
        ),
      },
    );
  }
}
