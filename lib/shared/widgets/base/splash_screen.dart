import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/routes/app_routes.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';
import 'package:mera_ashiana/core/theme/app_colors.dart';

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
    // Check login status in background, but don't force login screen
    await Future.wait([
      AuthState.checkLoginStatus(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    // Fixed: Always navigate to main so user sees the Home Screen first
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryNavy = Color(0xFF0A1D37);

    return Scaffold(
      backgroundColor: isDark ? primaryNavy : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "MERA ASHIANA",
                style: TextStyle(
                  color: AppColors.accentYellow,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5.0,
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentYellow,
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
