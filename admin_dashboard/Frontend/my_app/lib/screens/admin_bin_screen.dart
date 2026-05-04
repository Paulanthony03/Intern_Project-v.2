import 'package:flutter/material.dart';

class BinScreen extends StatelessWidget {
  final String token;

  const BinScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bin")),
      body: const Center(
        child: Text("Bin Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
