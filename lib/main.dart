import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/core/api_client.dart';

// Global navigation key for 401 redirects and global context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global Notifiers for Locale and Theme
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() async {
  // 1. Ensures Flutter framework is fully initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ✅ ApiClient.init() removed as it is now self-initializing

  // 3. Initialize AuthState (Check if user is logged in via local storage/cookies)
  // Ensure that AuthState.initialize() handles its own ApiClient dependency internally
  await AuthState.initialize();

  // 4. System UI Configuration (Edge-to-Edge for modern Android/iOS look)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
              // Required for redirects from background services/interceptors
              navigatorKey: navigatorKey,

              title: 'Mera Ashiana',
              debugShowCheckedModeBanner: false,

              // Localization setup
              locale: currentLocale,
              supportedLocales: const [Locale('en'), Locale('ur')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Theme Configuration with Predictive Back support for Android 14+
              themeAnimationDuration: Duration.zero,
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

              // Entry Point
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
