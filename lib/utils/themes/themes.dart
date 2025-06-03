import 'package:flutter/material.dart';

class HSColors {
  // HS 고유 색상 정의
  static const Color hsBlue = Color(0xFF08449A); // HS BLUE
  static const Color hsGreen = Color(0xFF04A1AC); // HS GREEN
  static const Color hsRed = Color(0xFFBE1924); // HS RED
  static const Color hsGrey = Color(0xFF5E5A57); // HS GREY

  // 각각의 색상에 맞는 ThemeData 정의
  static final ThemeData hsBlueTheme = ThemeData(
    primaryColor: hsBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: hsBlue, foregroundColor: Colors.white),
    brightness: Brightness.light,
    fontFamily: 'Pretendard', // 기본 폰트 설정
  );

  static final ThemeData hsGreenTheme = ThemeData(
    primaryColor: hsGreen,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: hsGreen, foregroundColor: Colors.white),
    brightness: Brightness.light,
    fontFamily: 'Pretendard', // 기본 폰트 설정
  );

  static final ThemeData hsRedTheme = ThemeData(
    primaryColor: hsRed,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: hsRed, foregroundColor: Colors.white),
    brightness: Brightness.light,
    fontFamily: 'Pretendard', // 기본 폰트 설정
  );

  static final ThemeData hsGreyTheme = ThemeData(
    primaryColor: hsGrey,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: hsGrey, foregroundColor: Colors.white),
    brightness: Brightness.light,
    fontFamily: 'Pretendard', // 기본 폰트 설정
  );
}
