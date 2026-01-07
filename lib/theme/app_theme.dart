import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';

class AppTheme {
  // ✅ FIX #3: Make themes static final (cached instances)
  // This prevents Flutter from creating new ThemeData objects on every rebuild
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // ✅ FIX #4: Enable Material 3 for better performance
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryNavy,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryNavy,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryNavy,
      secondary: AppColors.accentYellow,
      surface: AppColors.white,
      error: AppColors.errorRed,
      onPrimary: AppColors.white,
      onSecondary: AppColors.textDark,
      onSurface: AppColors.textDark,
      onError: AppColors.white,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textGrey),
    ),

    dividerColor: AppColors.borderGrey,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // ✅ FIX #4: Enable Material 3 for better performance
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.background,
    primaryColor: AppDarkColors.primaryNavy,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.surface,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppDarkColors.primaryNavy,
      secondary: AppDarkColors.accentYellow,
      surface: AppDarkColors.surface,
      error: AppDarkColors.errorRed,
      onPrimary: Colors.white,
      onSecondary: AppDarkColors.textPrimary,
      onSurface: AppDarkColors.textPrimary,
      onError: Colors.white,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppDarkColors.textPrimary),
      bodyMedium: TextStyle(color: AppDarkColors.textSecondary),
    ),

    dividerColor: AppDarkColors.borderGrey,
  );
}