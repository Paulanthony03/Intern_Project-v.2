import 'package:flutter/material.dart';

class InternsScreen extends StatelessWidget {
  final String token;

  const InternsScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interns")),
      body: const Center(
        child: Text("Interns Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
