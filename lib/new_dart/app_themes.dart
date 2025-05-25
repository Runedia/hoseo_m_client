import 'package:flutter/material.dart';

// 다양한 테마를 정의한 클래스
class AppThemes {
  static final Map<String, ThemeData> themes = {
    // 기본 밝은 테마
    'Default': ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 0, 123, 255),
      scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 0, 123, 255)),
    ),

    // 민트색 테마
    'Mint': ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 111, 255, 229),
      scaffoldBackgroundColor: const Color.fromARGB(255, 180, 255, 255),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 111, 255, 229)),
    ),

    // 녹색 테마
    'Green': ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 99, 230, 150),
      scaffoldBackgroundColor: const Color.fromARGB(255, 192, 248, 169),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 99, 230, 150)),
    ),

    // 다크 모드 테마
    'Dark': ThemeData.dark().copyWith(
      primaryColor: const Color.fromARGB(255, 50, 50, 50),
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 50, 50, 50)),
    ),
  };
}
