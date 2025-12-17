import 'package:mera_ashiana/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mera_ashiana/l10n/app_localizations.dart'; // generated localization

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // default language

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive App Structure',
      debugShowCheckedModeBanner: false,
      locale: _locale, // set current locale
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate, // your generated localization class
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: LoginScreen(
        // pass callback to login screen (or later to account settings)
      ),
    );
  }
}