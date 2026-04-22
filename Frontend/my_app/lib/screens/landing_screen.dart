import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'about_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("../assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
          child: Column(
            children: [
              /// NAVBAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// LOGO
                  Row(
                    children: [
                      Image.asset("../assets/images/mylogo.png", height: 40),

                      const SizedBox(width: 10),

                      Text(
                        "Blacky",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  /// NAV BUTTONS
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),

                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AboutScreen(),

                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(
                                      0,
                                      1,
                                    ); // start from bottom
                                    const end = Offset.zero;

                                    final tween = Tween(begin: begin, end: end)
                                        .chain(
                                          CurveTween(
                                            curve: Curves.easeOutCubic,
                                          ),
                                        );

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                        child: Text(
                          "ABOUT",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "REGISTER",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            212,
                            226,
                            74,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },

                        child: Text(
                          "SIGN IN",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              /// HERO TEXT
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start your journey with a smarter way to manage your internship",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "We're glad to have you here. This platform is designed to help interns easily manage their profiles and access their information, while administrators ensure everything stays organized and up to date.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
