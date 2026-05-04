import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/core/l10n/app_localizations.dart';
import 'package:mera_ashiana/core/theme/app_theme.dart';
import 'package:mera_ashiana/features/auth/auth_state.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthState.initialize();

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
            final bool isDarkMode =
                currentThemeMode == ThemeMode.dark ||
                (currentThemeMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark);

            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
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

              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,

              initialRoute: AppRoutes.splash,

              // ✅ CLEAN ROUTING (ONLY ONE SYSTEM)
              routes: AppPages.routes,
            );
          },
        );
      },
    );
  }
}
