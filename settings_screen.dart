import 'package:flutter/material.dart';
import 'main.dart'; // 테마 적용 위해 MyApp 참조
import 'academic_home_screen.dart'; // 홈 화면으로 돌아가기 위한 import
import 'app_themes.dart'; // 테마 정의한 Map 가져옴

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 현재 선택된 테마 이름 저장할 변수
  late String select_theme;

  @override
  void initState() {
    super.initState();
    select_theme = 'Default'; // 처음 앱 열었을 때 기본 테마로 설정
  }

  // 테마를 변경하는 함수. 드롭다운에서 선택 시 실행됨
  void changeTheme(String? newTheme) {
    if (newTheme == null) return;

    setState(() {
      select_theme = newTheme; // 선택한 테마로 상태 갱신
    });

    // MyApp의 상태에 접근해서 테마 변경 호출
    MyApp.of(context)?.updateTheme(newTheme);
  }

  // 데이터 초기화 버튼을 눌렀을 때 실행될 함수 (추후 구현할 예정)
  void resetPreferences() {}

  @override
  Widget build(BuildContext context) {
    // app_themes.dart에 정의된 테마들의 키 목록을 가져옴
    final themeNames = AppThemes.themes.keys.toList();

    return Scaffold(
      body: SafeArea( // 노치 영역 피해줌
        child: Padding(
          padding: const EdgeInsets.all(20.0), // 전체 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // 상단 여백
              const Text(
                '설정',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // 테마 드롭다운 UI
              Row(
                children: [
                  const Text('테마 선택: ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true, // 드롭다운 가로 꽉 채움
                      value: select_theme, // 현재 선택된 테마
                      items: themeNames.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(), // DropdownMenuItem 리스트로 변환
                      onChanged: changeTheme, // 선택 시 호출될 함수
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 초기화 버튼 (기능은 아직 구현 안 됨)
              ElevatedButton.icon(
                onPressed: resetPreferences,
                icon: const Icon(Icons.delete_forever), // 아이콘
                label: const Text('데이터 초기화'),
                style: ElevatedButton.styleFrom(
                  // 테마 색상에 따라 버튼 색상 변경
                  backgroundColor: select_theme == 'Dark'
                      ? Colors.white
                      : Colors.black,
                  foregroundColor: select_theme == 'Dark'
                      ? Colors.black
                      : Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // 앱 정보 (버전 등) 텍스트로 표시
              const Text('앱 버전: 1.0.0'),
              const Text('데이터 버전: 2025.05.23'),

              const Spacer(), // 남은 공간을 아래로 밀어줌
            ],
          ),
        ),
      ),

      // 하단 고정 버튼 (홈/이전/다음/설정)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // 하단 여백
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등 배치
          children: [
            _buildNavButton(
              context,
              icon: Icons.arrow_back, // 이전 버튼 (기능은 없음)
              label: '이전',
              onTap: () {},
            ),
            _buildNavButton(
              context,
              icon: Icons.home,
              label: '홈',
              onTap: () {
                // AcademicHomePage로 이동하면서 모든 이전 화면 제거
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AcademicHomePage()),
                      (route) => false, // 기존 route 다 삭제
                );
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.arrow_forward, // 다음 버튼 (추후 기능 추가 예정)
              label: '다음',
              onTap: () {},
            ),
            _buildNavButton(
              context,
              icon: Icons.settings,
              label: '설정',
              onTap: () {
                // 설정 버튼 눌러도 동작X
              },
            ),
          ],
        ),
      ),
    );
  }

  // 하단 버튼 하나씩 만들어주는 함수
  Widget _buildNavButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context); // 현재 테마 정보
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min, // 내용 크기에 맞게 설정
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black, // 다크모드일 때 색 반전
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 둥근 테두리
            ),
            minimumSize: const Size(48, 48), // 버튼 최소 크기
          ),
          child: Icon(icon, size: 20), // 아이콘 표시
        ),
        const SizedBox(height: 4), // 버튼 아래 텍스트와 간격
        Text(
          label,
          style: const TextStyle(fontSize: 12), // 버튼 텍스트
        ),
      ],
    );
  }
}
