import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';
import 'package:mera_ashiana/theme/app_theme.dart';
import 'package:mera_ashiana/services/auth_state.dart';
import 'package:mera_ashiana/core//api_client.dart';

// Global navigation key for 401 redirects
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

// ✅ Changed to async so we can await the AuthState
void main() async {
  // 1. Ensures Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ✅ CRITICAL: Initialize ApiClient BEFORE anything else
  // This prevents the "LateInitializationError: Field 'dio' has not been initialized"
  ApiClient.init();

  // 3. ✅ Initialize AuthState (Check if user is logged in)
  await AuthState.initialize();

  // 4. Google Play 2026 Mandate: Edge-to-Edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
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
              // ✅ Added navigatorKey for global logout/redirects
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
