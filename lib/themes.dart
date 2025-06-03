import 'package:flutter/material.dart';

class HSColors {
  // 고유 색상
  static const Color HsBlue = Color(0xFF08449A);
  static const Color HsGreen = Color(0xFF04A1AC);
  static const Color HsRed = Color(0xFFBE1924);
  static const Color HsGrey = Color(0xFF5E5A57);

  // 공통 AppBar 텍스트 스타일
  static const TextStyle _appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Blue 테마
  static final ThemeData HsBlue_Theme = ThemeData(
    primaryColor: HsBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: HsBlue,
      foregroundColor: Colors.white,
      titleTextStyle: _appBarTitleStyle,
    ),
    brightness: Brightness.light,
  );

  // Green 테마
  static final ThemeData HsGreen_Theme = ThemeData(
    primaryColor: HsGreen,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: HsGreen,
      foregroundColor: Colors.white,
      titleTextStyle: _appBarTitleStyle,
    ),
    brightness: Brightness.light,
  );

  // Red 테마
  static final ThemeData HsRed_Theme = ThemeData(
    primaryColor: HsRed,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: HsRed,
      foregroundColor: Colors.white,
      titleTextStyle: _appBarTitleStyle,
    ),
    brightness: Brightness.light,
  );

  // Grey 테마
  static final ThemeData HsGrey_Theme = ThemeData(
    primaryColor: HsGrey,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: HsGrey,
      foregroundColor: Colors.white,
      titleTextStyle: _appBarTitleStyle,
    ),
    brightness: Brightness.light,
  );
}
