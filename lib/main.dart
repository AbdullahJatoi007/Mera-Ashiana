import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';
import 'package:mera_ashiana/services/auth_state.dart'; // Import this

// Global notifiers
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() {
  // Ensure Flutter is ready before checking login
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Nested builders to listen to Theme, Locale, and Auth
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
              themeAnimationDuration: Duration.zero,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
