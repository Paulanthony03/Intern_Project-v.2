import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart'; // create this
import 'screens/user_dashboard.dart'; // create this

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
      },
    );
  }
}
