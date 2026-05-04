import 'package:flutter/material.dart';
import 'package:mera_ashiana/routes/app_routes.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/screens/base/main_scaffold.dart';
import 'package:mera_ashiana/authentication_bottom_sheet.dart';

import 'package:mera_ashiana/features/screens/forgot_password_screen.dart';
import 'package:mera_ashiana/features/screens/reset_password_screen.dart';

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
