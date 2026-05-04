import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text("About Blacky"),
      ),

      body: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(40),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "About Blacky",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "Blacky Internship Management System helps interns manage "
                "their internship profiles, documents, and information "
                "efficiently.\n\n"
                "Administrators can track intern progress, manage records, "
                "and keep everything organized in one centralized platform.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
