import 'package:flutter/material.dart';
import 'package:mera_ashiana/core/routes/app_routes.dart';
import 'package:mera_ashiana/shared/widgets/base/splash_screen.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../shared/widgets/base/main_scaffold.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),

    AppRoutes.login: (context) => Scaffold(
      body: AuthenticationBottomSheet(
        onLoginSuccess: () {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        },
      ),
    ),

    // Added Missing Routes
    AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
    AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),

    AppRoutes.main: (context) => const MainScaffold(),
  };
}
