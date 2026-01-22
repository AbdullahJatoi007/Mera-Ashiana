import 'package:flutter/material.dart';

import 'package:mera_ashiana/screens/base/main_scaffold.dart';
import 'package:mera_ashiana/services/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Check session and wait for branding (3 seconds total)
    await Future.wait([
      AuthState.checkLoginStatus(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    // Smooth Fade transition to the Main Dashboard
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScaffold(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Brand Colors
    const Color primaryNavy = Color(0xFF0A1D37);
    const Color accentYellow = Color(0xFFFFC400);

    return Scaffold(
      // Use Navy background in dark mode for a more "Elite" feel
      backgroundColor: isDark ? primaryNavy : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black45
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/mera_ashiana_logo.jpeg',
                    width: 160, // Slightly smaller for better proportions
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              const Text(
                "MERA ASHIANA",
                style: TextStyle(
                  color: accentYellow, // Brand Yellow
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5.0,
                ),
              ),
              const SizedBox(height: 10),

              // Tagline
              Text(
                "Find Your Dream Home",
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 60),

              // Animated Loading Indicator
              SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark
                        ? accentYellow.withOpacity(0.4)
                        : primaryNavy.withOpacity(0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
