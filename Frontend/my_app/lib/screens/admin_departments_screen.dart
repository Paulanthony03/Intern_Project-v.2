import 'package:flutter/material.dart';

class DepartmentsScreen extends StatelessWidget {
  final String token;

  const DepartmentsScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Departments")),
      body: const Center(
        child: Text("Departments Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
