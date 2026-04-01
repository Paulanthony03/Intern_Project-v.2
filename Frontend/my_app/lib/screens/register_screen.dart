import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final internIdController = TextEditingController();
  final schoolController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? emailError;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      String? result = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        internIdController.text.trim(),
        schoolController.text.trim(),
      );

      if (result == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() {
          emailError = result;
        });

        _formKey.currentState!.validate();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),

              const Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // 🔹 FULL NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter your full name" : null,
              ),

              const SizedBox(height: 15),

              // 🔹 EMAIL
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  errorText: emailError,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (emailError != null) {
                    setState(() => emailError = null);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email";
                  }

                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );

                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 🔹 INTERN ID
              TextFormField(
                controller: internIdController,
                decoration: const InputDecoration(labelText: "Intern ID"),
                validator: (value) =>
                    value!.isEmpty ? "Enter your Intern ID" : null,
              ),

              const SizedBox(height: 15),

              // 🔹 SCHOOL
              TextFormField(
                controller: schoolController,
                decoration: const InputDecoration(
                  labelText: "School / University",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter your school" : null,
              ),

              const SizedBox(height: 15),

              // 🔹 PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Enter password";
                  if (value.length < 6) return "Minimum 6 characters";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 🔹 CONFIRM PASSWORD
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // 🔹 BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register"),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
