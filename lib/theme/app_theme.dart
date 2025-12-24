import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primaryNavy,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryNavy,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),

    colorScheme: ColorScheme.light(
      primary: AppColors.primaryNavy,
      secondary: AppColors.accentYellow,
      background: AppColors.background,
      error: AppColors.errorRed,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textGrey),
    ),

    dividerColor: AppColors.borderGrey,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.background,

    primaryColor: AppDarkColors.primaryNavy,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.surface,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
    ),

    colorScheme: ColorScheme.dark(
      primary: AppDarkColors.primaryNavy,
      secondary: AppDarkColors.accentYellow,
      background: AppDarkColors.background,
      surface: AppDarkColors.surface,
      error: AppDarkColors.errorRed,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppDarkColors.textPrimary),
      bodyMedium: TextStyle(color: AppDarkColors.textSecondary),
    ),

    dividerColor: AppDarkColors.borderGrey,
  );
}
