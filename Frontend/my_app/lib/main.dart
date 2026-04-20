import 'package:flutter/material.dart';
import 'package:my_app/screens/landing_screen.dart';
import 'package:my_app/screens/admin_dashboard.dart';
import 'package:my_app/screens/user_dashboard.dart';

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
        '/': (context) => LandingScreen(),
        '/admin': (context) => AdminDashboard(token: ''),
        '/user': (context) => UserDashboard(),
      },
    );
  }
}
