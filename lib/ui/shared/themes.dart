import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: ColorConstants.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
} 