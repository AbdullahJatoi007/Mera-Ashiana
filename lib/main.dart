import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart';
import 'package:mera_ashiana/screens/auth/login_screen.dart';
import 'package:mera_ashiana/screens/favourite_screen.dart';
import 'package:mera_ashiana/screens/search_filter_screen.dart';
import 'package:mera_ashiana/screens/search_screen.dart';
import 'package:mera_ashiana/screens/splash_screen.dart';

// Global notifier to manage language across the entire app
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'Mera Ashiana',
          debugShowCheckedModeBanner: false,
          locale: currentLocale,
          // Global locale
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
