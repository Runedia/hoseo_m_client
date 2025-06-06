import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// go_router와 호환되는 네비게이션 히스토리 관리 클래스
class GoRouterHistory {
  static final GoRouterHistory _instance = GoRouterHistory._internal();

  static GoRouterHistory get instance => _instance;

  GoRouterHistory._internal();

  final List<String> _history = ['/'];
  int _currentIndex = 0;

  /// 새로운 라우트로 이동시 호출
  void onNavigate(String route) {
    // 현재 위치 이후의 히스토리는 삭제 (브라우저와 동일한 동작)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(route);
    _currentIndex = _history.length - 1;
    _printHistory('Navigate to $route');
  }

  /// 뒤로가기시 호출
  void onBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _printHistory('Back');
    }
  }

  /// 앞으로가기시 호출
  void onForward() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      _printHistory('Forward');
    }
  }

  /// 홈으로 이동시 호출
  void onHome() {
    _currentIndex = 0;
    _printHistory('Home');
  }

  /// 뒤로갈 수 있는지 확인
  bool canGoBack() {
    return _currentIndex > 0;
  }

  /// 앞으로갈 수 있는지 확인
  bool canGoForward() {
    return _currentIndex < _history.length - 1;
  }

  /// 현재 라우트 반환
  String? getCurrentRoute() {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// 다음 라우트 반환
  String? getNextRoute() {
    if (_currentIndex < _history.length - 1) {
      return _history[_currentIndex + 1];
    }
    return null;
  }

  /// 이전 라우트 반환
  String? getPreviousRoute() {
    if (_currentIndex > 0) {
      return _history[_currentIndex - 1];
    }
    return null;
  }

  /// 히스토리 초기화
  void reset() {
    _history.clear();
    _history.add('/');
    _currentIndex = 0;
    _printHistory('Reset');
  }

  /// 디버그용 히스토리 출력
  void _printHistory(String action) {
    print('[$action] History: $_history, Current: $_currentIndex');
  }

  /// 현재 히스토리 상태 반환
  String getHistoryStatus() {
    return 'Current: ${getCurrentRoute()}, '
        'Can go back: ${canGoBack()}, '
        'Can go forward: ${canGoForward()}';
  }

  /// 히스토리와 함께 네비게이션 실행 (push)
  void pushWithHistory(BuildContext context, String route) {
    print('[pushWithHistory] Attempting to navigate to: $route');
    onNavigate(route);
    context.go(route);
  }

  /// 뒤로가기 실행
  void navigateBack(BuildContext context) {
    print('[navigateBack] Before: ${getHistoryStatus()}');
    if (canGoBack()) {
      onBack();
      final targetRoute = getCurrentRoute();
      print('[navigateBack] After onBack: ${getHistoryStatus()}');

      if (targetRoute != null) {
        print('[navigateBack] Going to: $targetRoute');
        context.go(targetRoute);
      }
    } else {
      print('[navigateBack] Cannot go back');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이전 페이지가 없습니다.')));
    }
  }

  /// 앞으로가기 실행
  void navigateForward(BuildContext context) {
    print('[navigateForward] Before: ${getHistoryStatus()}');
    if (canGoForward()) {
      onForward();
      final targetRoute = getCurrentRoute();
      print('[navigateForward] After onForward: ${getHistoryStatus()}');

      if (targetRoute != null) {
        print('[navigateForward] Going to: $targetRoute');
        context.go(targetRoute);
      }
    } else {
      print('[navigateForward] Cannot go forward');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다음 페이지가 없습니다.')));
    }
  }

  /// 홈으로 이동 실행
  void navigateHome(BuildContext context) {
    print('[navigateHome] Navigating to home');
    // 홈으로 이동하는 것도 새로운 네비게이션으로 기록
    onNavigate('/');
    // go_router를 사용하여 홈으로 이동 (스택을 모두 대체)
    context.go('/');
  }
}
