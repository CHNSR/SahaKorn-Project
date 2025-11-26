import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF7A5CFF);
  static const Color scaffoldBg = Color(0xFFFb8c1ec);
  static const Color appBarBg = Colors.black;
}

class AppTheme {
  AppTheme._();
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBg,
      elevation: 2,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}