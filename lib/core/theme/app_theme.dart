import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    primaryTextTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().primaryTextTheme),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.pink,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
  );
}
