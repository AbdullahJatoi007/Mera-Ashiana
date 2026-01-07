import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';

// Global notifiers
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, currentThemeMode, _) {
            return MaterialApp(
              title: 'Mera Ashiana',
              debugShowCheckedModeBanner: false,
              locale: currentLocale,
              supportedLocales: const [Locale('en'), Locale('ur')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // ✅ FIX #1: Disable theme animation for instant switching
              themeAnimationDuration: Duration.zero,

              // ✅ FIX #2: Use cached theme instances (defined in app_theme.dart)
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,

              // Use a const home to prevent splash screen rebuilds
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}