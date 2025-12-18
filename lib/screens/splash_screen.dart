import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for 3-4 seconds (adjust based on your Lottie animation length)
    await Future.delayed(const Duration(seconds: 8));

    if (!mounted) return;

    // Smooth transition to Login Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Checks if the system is in Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Uses Navy for Splash in light mode or Dark Background in dark mode
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. The Lottie Animation
            Image.asset(
              'assets/images/mera_ashiana_logo.jpeg',
              // Path to your Lottie file
              width: 250,
              height: 250,
            ),

            const SizedBox(height: 20),

            // 2. Your App Name
            const Text(
              "MERA ASHIANA",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
