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

    // 1. Initialize Fade Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // 2. Start the combined App Initialization and Navigation flow
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initializes essential services before moving to the Dashboard
  Future<void> _initializeApp() async {
    // RUN SIMULTANEOUSLY: Start checking session while the splash is visible
    // This reduces the perceived waiting time for the user.
    await Future.wait([
      AuthState.checkLoginStatus(), // Check cookies/tokens
      Future.delayed(const Duration(seconds: 3)), // Minimum branding time
    ]);

    if (!mounted) return;

    // Smooth transition to MainScaffold
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with the Shadow Styling from your original code
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/mera_ashiana_logo.jpeg',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // App Name
              Text(
                "MERA ASHIANA",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                "Find Your Dream Home",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Loading indicator (Optional: shows user something is happening)
              const SizedBox(height: 50),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
