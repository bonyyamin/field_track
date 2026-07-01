import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData lightTheme({String? fontFamily, TextTheme? textTheme}) {
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimaryLight),
      displayMedium: TextStyle(color: AppColors.textPrimaryLight),
      displaySmall: TextStyle(color: AppColors.textPrimaryLight),
      headlineLarge: TextStyle(color: AppColors.textPrimaryLight),
      headlineMedium: TextStyle(color: AppColors.textPrimaryLight),
      headlineSmall: TextStyle(color: AppColors.textPrimaryLight),
      titleLarge: TextStyle(color: AppColors.textPrimaryLight),
      titleMedium: TextStyle(color: AppColors.textPrimaryLight),
      titleSmall: TextStyle(color: AppColors.textPrimaryLight),
      bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
      bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
      bodySmall: TextStyle(color: AppColors.textSecondaryLight),
      labelLarge: TextStyle(color: AppColors.textPrimaryLight),
      labelMedium: TextStyle(color: AppColors.textSecondaryLight),
      labelSmall: TextStyle(color: AppColors.textSecondaryLight),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: fontFamily,
      textTheme: textTheme ?? baseTextTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.primaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.surfaceLight,
        onSecondary: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.fieldLabel.copyWith(color: AppColors.textSecondaryLight),
        hintStyle: AppTextStyles.inputText.copyWith(color: AppColors.textSecondaryLight),
        errorStyle: AppTextStyles.cardSubtitle.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const Color(0xFFDC4040) == AppColors.error ? const BorderSide(color: AppColors.error) : BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonLight,
          foregroundColor: AppColors.surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: AppColors.primaryLight),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        selectedLabelStyle: TextStyle(
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData darkTheme({String? fontFamily, TextTheme? textTheme}) {
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimaryDark),
      displayMedium: TextStyle(color: AppColors.textPrimaryDark),
      displaySmall: TextStyle(color: AppColors.textPrimaryDark),
      headlineLarge: TextStyle(color: AppColors.textPrimaryDark),
      headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
      headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
      titleLarge: TextStyle(color: AppColors.textPrimaryDark),
      titleMedium: TextStyle(color: AppColors.textPrimaryDark),
      titleSmall: TextStyle(color: AppColors.textPrimaryDark),
      bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
      bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
      bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      labelLarge: TextStyle(color: AppColors.textPrimaryDark),
      labelMedium: TextStyle(color: AppColors.textSecondaryDark),
      labelSmall: TextStyle(color: AppColors.textSecondaryDark),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: fontFamily,
      textTheme: textTheme ?? baseTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.backgroundDark,
        onSecondary: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.fieldLabel.copyWith(color: AppColors.textSecondaryDark),
        hintStyle: AppTextStyles.inputText.copyWith(color: AppColors.textSecondaryDark),
        errorStyle: AppTextStyles.cardSubtitle.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondaryDark.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondaryDark.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonDark,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: AppColors.primaryDark),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        selectedLabelStyle: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
