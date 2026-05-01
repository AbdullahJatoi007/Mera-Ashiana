import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';
import 'package:mera_ashiana/services/auth_state.dart';

// Global navigation key for 401 redirects and global context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global Notifiers for Locale and Theme
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthState (Check if user is logged in)
  await AuthState.initialize();

  // Initial System UI Configuration
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
            // --- DYNAMIC SYSTEM UI OVERLAY ---
            // Determine if the current active theme is dark
            final bool isDarkMode =
                currentThemeMode == ThemeMode.dark ||
                (currentThemeMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark);

            // Update System UI Icons (White in dark mode, Black in light mode)
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                // Icons turn light (white) if in dark mode, and dark (black) if in light mode
                systemNavigationBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
                statusBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );

            return MaterialApp(
              navigatorKey: navigatorKey,
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
              // Fast theme switching
              theme: AppTheme.lightTheme.copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android:
                        PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: AppTheme.darkTheme.copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android:
                        PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              themeMode: currentThemeMode,

              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
