import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/themes/theme_preferences.dart';
import 'package:hoseo_m_client/utils/themes/themes.dart';

class ThemeProvider extends ChangeNotifier {
  String _currentThemeName = 'HS Red';

  String get currentThemeName => _currentThemeName;

  ThemeData get currentTheme {
    switch (_currentThemeName) {
      case 'HS Blue':
        return HSColors.hsBlueTheme;
      case 'HS Green':
        return HSColors.hsGreenTheme;
      case 'HS Grey':
        return HSColors.hsGreyTheme;
      case 'HS Red':
      default:
        return HSColors.hsRedTheme;
    }
  }

  // 초기 테마 로드
  Future<void> loadTheme() async {
    _currentThemeName = await ThemePreferences.getTheme();
    notifyListeners();
  }

  // 테마 변경
  Future<void> setTheme(String themeName) async {
    _currentThemeName = themeName;
    await ThemePreferences.saveTheme(themeName);
    notifyListeners();
  }
}
