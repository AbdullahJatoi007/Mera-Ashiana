import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for System UI control
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';
import 'package:mera_ashiana/services/auth_state.dart';

// Global notifiers for app-wide state changes
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() {
  // 1. Ensures Flutter is ready before plugin initialization
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Google Play 2026 Mandate: Support Edge-to-Edge display for Android 15
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Optional: Set status bar to transparent to match Edge-to-Edge design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nested builders to listen to Theme and Locale changes reactively
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, currentThemeMode, _) {
            return MaterialApp(
              title: 'Mera Ashiana',
              debugShowCheckedModeBanner: false,

              // Localization Configuration
              locale: currentLocale,
              supportedLocales: const [
                Locale('en'),
                Locale('ur'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Theme Configuration
              themeAnimationDuration: Duration.zero, // Faster transitions
              theme: AppTheme.lightTheme.copyWith(
                // Required for Android 15 Predictive Back Support
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: AppTheme.darkTheme.copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              themeMode: currentThemeMode,

              // Initial Route
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}