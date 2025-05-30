// hs_colors.dart
// HS 고유 색상 및 테마를 전역에서 사용하도록 정의한 파일입니다.
import 'package:flutter/material.dart';

class HSColors {
  // HS 고유 색상 정의
  static const Color HsBlue = Color(0xFF08449A);   // HS BLUE
  static const Color HsGreen = Color(0xFF04A1AC);  // HS GREEN
  static const Color HsRed = Color(0xFFBE1924);    // HS RED
  static const Color HsGrey = Color(0xFF5E5A57);   // HS GREY

  // 각각의 색상에 맞는 ThemeData 정의
  static final ThemeData HsBlue_Theme = ThemeData(
    primaryColor: HsBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: HsBlue,
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final ThemeData HsGreen_Theme = ThemeData(
    primaryColor: HsGreen,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: HsGreen,
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final ThemeData HsRed_Theme = ThemeData(
    primaryColor: HsRed,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: HsRed,
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );

  static final ThemeData HsGrey_Theme = ThemeData(
    primaryColor: HsGrey,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: HsGrey,
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );
}
