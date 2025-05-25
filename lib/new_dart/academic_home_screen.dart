import 'package:flutter/material.dart';
import '../new_dart/settings_screen.dart'; // 설정 화면 파일 import
import '../new_dart/app_themes.dart'; // 테마 정의한 파일 import

// 학사종합 화면을 위한 StatelessWidget 클래스 정의
class AcademicHomePage extends StatelessWidget {
  const AcademicHomePage({super.key});

  // 버튼에 들어갈 카테고리 목록. 학사 관련 기능들을 나열함
  final List<String> categories = const [
    '학사일정',
    '교육과정',
    '수업',
    '학적',
    '취업지원',
    '국제교류',
    '증명서 발급',
    '기타',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 현재 앱의 테마 정보 가져옴
    final isDark = theme.brightness == Brightness.dark; // 다크모드 여부 판단

    return Scaffold(
      body: Column(
        children: [
          // 화면 상단 제목 영역
          Container(
            width: double.infinity, // 가로 전체 너비
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16), // 위아래, 좌우 여백
            alignment: Alignment.centerLeft, // 왼쪽 정렬
            child: const Text(
              '학사종합', // 제목 텍스트
              style: TextStyle(
                fontSize: 28, // 큰 글씨
                color: Colors.black, // 텍스트 색
                fontWeight: FontWeight.bold, // 굵게
              ),
            ),
          ),

          // 중앙 버튼들 (Wrap 사용해서 자동 줄바꿈되는 레이아웃)
          Expanded(
            child: SingleChildScrollView( // 콘텐츠가 화면보다 크면 스크롤 가능하게 함
              child: Column(
                children: [
                  const SizedBox(height: 40), // 상단 여백
                  Center(
                    child: SizedBox(
                      width: 360, // 버튼 전체 영역의 최대 너비 설정
                      child: Wrap(
                        spacing: 20, // 버튼 사이 좌우 간격
                        runSpacing: 20, // 버튼 사이 위아래 간격
                        alignment: WrapAlignment.center, // 가운데 정렬
                        children: categories.map((title) {
                          return SizedBox(
                            width: 150, // 버튼 가로 크기
                            height: 80, // 버튼 세로 크기
                            child: ElevatedButton(
                              onPressed: () {
                                // 눌렀을 때 동작은 현재 없음. 나중에 추가 예정
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white // 다크모드일 때 배경 흰색
                                    : const Color.fromARGB(255, 190, 25, 36), // 밝은 모드일 땐 호서대 레드
                                foregroundColor: isDark
                                    ? Colors.black // 글자색
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // 버튼 테두리 둥글게
                                ),
                              ),
                              child: Text(
                                title, // 버튼 텍스트 (카테고리 이름)
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center, // 가운데 정렬
                              ),
                            ),
                          );
                        }).toList(), // 리스트를 위젯 목록으로 변환
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // 하단 여백
                ],
              ),
            ),
          ),

          // 하단 네비게이션 버튼들 (이전 / 홈 / 다음 / 설정)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0), // 하단 여백
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들을 가로로 균등하게 배치
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.arrow_back, // 아이콘: 이전
                  label: '이전',
                  onTap: () {
                    // 추후 이전 기능 추가 가능
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.home, // 아이콘: 홈
                  label: '홈',
                  onTap: () {
                    // 홈 화면 이동 기능 넣을 수 있음 (현재 비워둠)
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.arrow_forward, // 아이콘: 다음
                  label: '다음',
                  onTap: () {
                    // 추후 다음 기능 추가 가능
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.settings, // 아이콘: 설정
                  label: '설정',
                  onTap: () {
                    // 설정 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 하단 버튼 하나하나를 만드는 함수
  Widget _buildNavButton(
      BuildContext context, {
        required IconData icon, // 아이콘
        required String label, // 아래 텍스트
        required VoidCallback onTap, // 눌렀을 때 실행할 함수
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; // 다크모드 여부

    return Column(
      mainAxisSize: MainAxisSize.min, // 버튼 크기를 내용물에 맞춤
      children: [
        ElevatedButton(
          onPressed: onTap, // 눌렀을 때 동작
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black, // 배경색 다르게
            foregroundColor: isDark ? Colors.black : Colors.white, // 아이콘 색
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 둥근 버튼
            ),
            minimumSize: const Size(48, 48), // 최소 크기
          ),
          child: Icon(icon, size: 20), // 아이콘 위젯
        ),
        const SizedBox(height: 4), // 아이콘과 텍스트 사이 간격
        Text(
          label,
          style: const TextStyle(fontSize: 12), // 텍스트 크기
        ),
      ],
    );
  }
}
