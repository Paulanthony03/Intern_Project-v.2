import 'package:flutter/material.dart';

class SchoolScreen extends StatelessWidget {
  final String token;

  const SchoolScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("School")),
      body: const Center(
        child: Text("School Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
