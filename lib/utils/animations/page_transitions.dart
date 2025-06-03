import 'package:flutter/material.dart';

/// 간단한 페이지 전환 애니메이션을 제공하는 클래스
class PageAnimations {
  /// 페이드 효과 (모든 화면 전환에 사용)
  static Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut), child: child);
    },
  );

  /// 기본 전환 (fade와 동일)
  static Route<T> slideRight<T>(Widget page) => fade(page);

  static Route<T> slideLeft<T>(Widget page) => fade(page);
}
