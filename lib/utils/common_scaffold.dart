import 'package:flutter/material.dart';
import 'package:hoseo_m_client/menu_1_screen/notice_screen.dart';
import 'package:hoseo_m_client/menu_2_screen/shuttle_detail_screen.dart';
import 'package:hoseo_m_client/menu_2_screen/shuttle_select_screen.dart';
import 'package:hoseo_m_client/menu_3_screen/department_detail_screen.dart';
import 'package:hoseo_m_client/menu_3_screen/department_screen.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_detail_screen.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_list_screen.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_schedule.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map_detail_screen.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map.dart';
import 'package:hoseo_m_client/menu_6_screen/academic_home_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/class_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/curriculum_home_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/record_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/schedule_home_screen.dart';
import 'package:hoseo_m_client/settings_screen.dart';
import 'package:hoseo_m_client/utils/animations/page_transitions.dart';

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final FloatingActionButton? floatingActionButton;

  const CommonScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.floatingActionButton,
  });

  // 브라우저처럼 "이전" 이동 (정적 메서드로 변경)
  static void _navigateBack(BuildContext context) {
    if (NavigationHistory.instance.canGoBack()) {
      NavigationHistory.instance.onBack();
      final previousRoute = NavigationHistory.instance.getCurrentRoute();

      if (previousRoute == 'HomeScreen') {
        // 홈으로 갈 때
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // 다른 페이지로 갈 때 - 새로운 페이지를 push
        final previousPage = CommonScaffold._getPageFromRoute(previousRoute!);
        if (previousPage != null) {
          Navigator.push(context, PageAnimations.fade(previousPage));
        } else {
          // 페이지를 찾을 수 없으면 일반적인 pop 사용
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이전 페이지가 없습니다.')));
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이전 페이지가 없습니다.')));
    }
  }

  // 라우트 이름으로부터 페이지 위젯 생성 (정적 메서드로 변경)
  static Widget? _getPageFromRoute(String routeName) {
    switch (routeName) {
      case 'HomeScreen':
        // 홈 화면으로 돌아가기 대신 현재 상황에서는 null 반환
        // Navigator.popUntil로 처리해야 하므로
        return null;
      case 'NoticeScreen':
        return const NoticeScreen();
      case 'ShuttleSelectScreen':
        return const ShuttleSelectScreen();
      case 'ShuttleDetailScreen':
        // ShuttleDetailScreen은 파라미터가 필요하지만 기본값으로 대체
        return ShuttleDetailScreen(date: DateTime.now(), isAsanToCheonan: true);
      case 'DepartmentPage':
        return const DepartmentPage();
      case 'DepartmentDetail':
        // AppState에 저장된 학과 정보로 화면 생성
        return const DepartmentDetailScreen();
      case 'MealPage':
        return const MealPage();
      case 'MealList':
        // MealListScreen은 파라미터가 필요하지만 기본값으로 대체
        return const MealListScreen(cafeteriaName: '종합정보관 식당', action: 'MAPP_2312012408');
      case 'MealDetail':
        // MealDetailScreen은 파라미터가 필요하지만 기본값으로 대체
        return const MealDetailScreen(notice: {}, imageUrls: [], cafeteriaName: '종합정보관 식당');
      case 'CampusMapPage':
        return const CampusMapPage();
      case 'CampusMapDetailScreen':
        // CampusMapDetailScreen은 파라미터가 필요하지만 기본값으로 대체
        return const CampusMapDetailScreen(campusName: '아산캠퍼스', campusCode: 'asan');
      case 'AcademicHomePage':
        return const AcademicHomePage();
      case 'ScheduleHomePage':
        return const ScheduleHomePage();
      case 'CurriculumHomePage':
        return const CurriculumHomePage();
      case 'ClassInfoScreen':
        return ClassInfoScreen(type: 'regist', title: '수업');
      case 'RecordInfoScreen':
        return RecordInfoScreen(type: 'test', title: '학적');
      case 'SettingsScreen':
        return const SettingsScreen();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // 기본 뒤로가기 버튼 비활성화
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _navigateBack(context); // 하단 "이전" 버튼과 같은 로직 사용
                  },
                )
                : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }
}

class CommonBottomNavigation extends StatelessWidget {
  const CommonBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            context,
            icon: Icons.arrow_back,
            label: '이전',
            onTap: () {
              CommonScaffold._navigateBack(context);
            },
          ),
          _buildNavButton(
            context,
            icon: Icons.home,
            label: '홈',
            onTap: () {
              // 홈으로 가면서 히스토리 정리
              NavigationHistory.instance.onHome();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          _buildNavButton(
            context,
            icon: Icons.arrow_forward,
            label: '다음',
            onTap: () {
              _navigateForward(context);
            },
          ),
          // _buildNavButton(
          //   context,
          //   icon: Icons.settings,
          //   label: '설정',
          //   onTap: () {
          //     // 설정 페이지로 이동 시 히스토리에 추가
          //     NavigationHistory.instance.onNavigate('SettingsScreen');
          //     Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          //   },
          // ),
        ],
      ),
    );
  }

  // 브라우저처럼 "다음" 이동
  void _navigateForward(BuildContext context) {
    final nextRoute = NavigationHistory.instance.getNextRoute();

    if (nextRoute != null) {
      // HomeScreen의 경우 특별 처리
      if (nextRoute == 'HomeScreen') {
        NavigationHistory.instance.onForward();
        Navigator.popUntil(context, (route) => route.isFirst);
        return;
      }

      final nextPage = CommonScaffold._getPageFromRoute(nextRoute);
      if (nextPage != null) {
        NavigationHistory.instance.onForward();
        Navigator.push(context, PageAnimations.fade(nextPage));
      } else {
        _showNoForwardMessage(context);
      }
    } else {
      _showNoForwardMessage(context);
    }
  }

  void _showNoForwardMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('다음 페이지가 없습니다.'), duration: Duration(seconds: 2)));
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withAlpha(180),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(48, 48),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }
}

// 간단한 네비게이션 히스토리 관리 클래스
class NavigationHistory {
  static final NavigationHistory _instance = NavigationHistory._internal();

  static NavigationHistory get instance => _instance;

  NavigationHistory._internal();

  final List<String> _history = ['HomeScreen']; // 기본적으로 홈 화면부터 시작
  int _currentIndex = 0;

  // 새로운 페이지로 이동할 때
  void onNavigate(String routeName) {
    // 현재 위치 이후의 히스토리는 삭제 (브라우저와 동일한 동작)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(routeName);
    _currentIndex = _history.length - 1;

    _printHistory('Navigate to $routeName');
  }

  // 뒤로가기 했을 때
  void onBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _printHistory('Back');
    }
  }

  // 앞으로 갔을 때
  void onForward() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      _printHistory('Forward');
    }
  }

  // 홈으로 갔을 때
  void onHome() {
    // 브라우저처럼 홈으로 가는 것도 일반적인 네비게이션처럼 처리
    // onNavigate와 동일하게 처리
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add('HomeScreen');
    _currentIndex = _history.length - 1;

    _printHistory('Home');
  }

  // 뒤로가기 할 수 있는지 확인
  bool canGoBack() {
    return _currentIndex > 0;
  }

  // 현재 라우트 반환
  String? getCurrentRoute() {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  // 다음으로 갈 수 있는 라우트 반환
  String? getNextRoute() {
    if (_currentIndex < _history.length - 1) {
      return _history[_currentIndex + 1];
    }
    return null;
  }

  // 앞으로 갈 수 있는지 확인
  bool canGoForward() {
    return _currentIndex < _history.length - 1;
  }

  // 디버그용 히스토리 출력
  void _printHistory(String action) {
    print('[$action] History: $_history, Current: $_currentIndex');
  }

  // 현재 히스토리 상태 반환 (디버그용)
  String getHistoryStatus() {
    return 'Current: ${_history.isNotEmpty && _currentIndex < _history.length ? _history[_currentIndex] : 'Unknown'}, '
        'Can go back: ${_currentIndex > 0}, '
        'Can go forward: ${canGoForward()}';
  }
}
