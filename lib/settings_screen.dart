import 'package:flutter/material.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/main.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/themes/theme_preferences.dart';
import 'package:hoseo_m_client/utils/themes/themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedTheme;
  bool _isLoading = true;

  final List<String> themeOptions = ['HS Red', 'HS Blue', 'HS Green', 'HS Grey'];

  // 테마 이름에 따른 색상 반환
  Color _getThemeColor(String themeName) {
    switch (themeName) {
      case 'HS Red':
        return HSColors.hsRedTheme.primaryColor;
      case 'HS Blue':
        return HSColors.hsBlueTheme.primaryColor;
      case 'HS Green':
        return HSColors.hsGreenTheme.primaryColor;
      case 'HS Grey':
        return HSColors.hsGreyTheme.primaryColor;
      default:
        return HSColors.hsRedTheme.primaryColor;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  // 현재 설정된 테마를 비동기로 로드
  void _loadCurrentTheme() async {
    try {
      final currentTheme = await ThemePreferences.getTheme();
      setState(() {
        selectedTheme = currentTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        selectedTheme = 'HS Red'; // 기본값
        _isLoading = false;
      });
    }
  }

  void changeTheme(String? newTheme) async {
    if (newTheme == null) return;

    setState(() {
      selectedTheme = newTheme;
    });

    // 즉시 앱 테마 변경
    final myAppState = MyApp.of(context);
    if (myAppState != null) {
      myAppState.updateTheme(newTheme);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('테마가 변경되었습니다.'), duration: Duration(seconds: 2)));
      }
    } else {
      // MyApp 상태를 찾을 수 없는 경우
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테마 설정이 저장되었습니다. 앱을 다시 시작하여 적용해주세요.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void resetPreferences() async {
    // 사용자에게 확인 대화상자 표시
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('데이터 초기화'),
          content: const Text('저장된 모든 데이터와 파일(이미지 등)이 삭제됩니다.\n정말 초기화하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('확인')),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // 로딩 대화상자 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(child: Text('데이터베이스 및 파일 초기화 중...')),
                ],
              ),
            );
          },
        );

        // 1. 데이터베이스 재생성 (파일 삭제 후 새로 생성)
        await DatabaseManager.instance.recreateDatabase();

        // 2. 저장된 모든 파일 삭제 (이미지, JSON 등)
        await DatabaseManager.instance.clearAllStoredFiles();

        // 로딩 대화상자 닫기
        if (mounted) {
          Navigator.of(context).pop();
        }

        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('데이터베이스와 저장된 파일이 성공적으로 초기화되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // 로딩 대화상자 닫기 (오류 발생 시)
        if (mounted) {
          Navigator.of(context).pop();
        }

        // 오류 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('초기화 실패: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CommonScaffold(title: '설정', body: Center(child: CircularProgressIndicator()));
    }

    return CommonScaffold(
      title: '설정',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('설정', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Text('테마 선택: ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedTheme,
                      selectedItemBuilder: (context) {
                        return themeOptions.map((name) {
                          return Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getThemeColor(name),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(name),
                            ],
                          );
                        }).toList();
                      },
                      items:
                          themeOptions.map((name) {
                            return DropdownMenuItem(
                              value: name,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _getThemeColor(name),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade300, width: 1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(name),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: changeTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: resetPreferences,
                icon: const Icon(Icons.delete_forever),
                label: const Text('데이터 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text('앱 버전: 1.0.0'),
              const Text('데이터 버전: 2025.05.23'),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
