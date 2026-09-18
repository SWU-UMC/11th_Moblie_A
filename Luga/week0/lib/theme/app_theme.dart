imoprt 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.surface,

    colorScheme: const ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),

    textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Manrope'),
        bodyMedium: TextStyle(fontFamily: 'Manrope'),
        titleLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
    ),

    cardTheme: CardThemeData(
        color: Colors.white,
        shpae: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
    ),

    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
    ),
  );
}