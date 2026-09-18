import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.surface,

    colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontFamily: 'Manrope', fontSize: 22, 
        fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        ),
      titleLarge: TextStyle(
        fontFamily: 'Manrope', fontSize: 20,
        fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        ),
      titleMedium: TextStyle(
        fontFamily: 'Manrope', fontSize: 16,
        fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
      bodyMedium: TextStyle(
        fontFamily: 'Manrope', fontSize: 14,
        color: AppColors.textSecondary,
        ),
      labelLarge: TextStyle(
        fontFamily: 'Manrope', fontSize: 14,
        fontWeight: FontWeight.w600, color: AppColors.primary,
      ),
    ),

    cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
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