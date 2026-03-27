import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFF3F6F4);
  static const bg2 = Color(0xFFFFFFFF);
  static const bg3 = Color(0xFFF6FAF7);
  static const bg4 = Color(0xFFE7F2EC);

  static const card = Color(0xFFFFFFFF);
  static const cardSoft = Color(0xFFF7FBF8);
  static const cardStrong = Color(0xFF1F5E3E);

  static const border = Color(0xFFD9E7DE);
  static const borderSoft = Color(0xFFE8EFEA);

  static const green = Color(0xFF2ECC71);
  static const green2 = Color(0xFF245C3D);
  static const green3 = Color(0xFF328458);
  static const green4 = Color(0xFF4FA171);
  static const greenBg = Color(0xFFEAF7F0);

  static const red = Color(0xFFD64545);
  static const red2 = Color(0xFFB33434);
  static const redBg = Color(0xFFFDEEEE);

  static const blue = Color(0xFF2F7CF6);
  static const blue2 = Color(0xFF1F63C3);
  static const blueBg = Color(0xFFEAF2FF);

  static const orange = Color(0xFFF4A62A);
  static const orange2 = Color(0xFFE68E00);
  static const orangeBg = Color(0xFFFFF5E7);

  static const text = Color(0xFF16231C);
  static const text2 = Color(0xFF55695F);
  static const text3 = Color(0xFF8AA095);

  static const shadow = Color(0x16000000);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.green2,
      secondary: AppColors.orange,
      surface: AppColors.bg2,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
    ),
  );

  final textTheme = GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
    titleLarge: GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: AppColors.text,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: AppColors.text,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.text2,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      titleTextStyle: GoogleFonts.cairo(
        color: AppColors.text,
        fontWeight: FontWeight.w900,
        fontSize: 20,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerColor: AppColors.border,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.bg2,
      selectedItemColor: AppColors.green2,
      unselectedItemColor: AppColors.text3,
      elevation: 18,
      selectedIconTheme: IconThemeData(size: 28),
      unselectedIconTheme: IconThemeData(size: 25),
      selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.green3, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.red, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.text2, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: AppColors.text3, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green2,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 62),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      contentTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
