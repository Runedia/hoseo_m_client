import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/main.dart';
import 'package:hoseo_m_client/menu_1_screen/notice_screen.dart';
import 'package:hoseo_m_client/menu_1_screen/notice_webview_screen.dart';
import 'package:hoseo_m_client/menu_2_screen/shuttle_select_screen.dart';
import 'package:hoseo_m_client/menu_2_screen/shuttle_detail_screen.dart';
import 'package:hoseo_m_client/menu_3_screen/department_screen.dart';
import 'package:hoseo_m_client/menu_3_screen/department_detail_screen.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_schedule.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_list_screen.dart';
import 'package:hoseo_m_client/menu_4_screen/meal_detail_screen.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map_detail_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/academic_home_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/schedule_list_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/curriculum_home_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/curriculum_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/class_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/record_screen.dart';
import 'package:hoseo_m_client/settings_screen.dart';
import 'package:hoseo_m_client/utils/app_state.dart';

// Fade transition을 위한 custom transition builder
Page<T> fadeTransitionPage<T extends Object?>(
  Widget child,
  GoRouterState state,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

class AppRouter {
  static GoRouter createRouter(String currentThemeName) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // 홈 화면
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => fadeTransitionPage(
            HomeScreen(currentThemeName: currentThemeName),
            state,
          ),
        ),

        // 공지사항
        GoRoute(
          path: '/notice',
          name: 'notice',
          pageBuilder: (context, state) => fadeTransitionPage(
            const NoticeScreenNew(),
            state,
          ),
          routes: [
            GoRoute(
              path: '/detail',
              name: 'notice-detail',
              pageBuilder: (context, state) {
                final title = state.uri.queryParameters['title'] ?? '';
                final url = state.uri.queryParameters['url'] ?? '';
                final chidx = state.uri.queryParameters['chidx'];
                final author = state.uri.queryParameters['author'];
                final createDt = state.uri.queryParameters['createDt'];
                
                return fadeTransitionPage(
                  NoticeWebViewEnhanced(
                    title: title,
                    url: url,
                    chidx: chidx,
                    author: author,
                    createDt: createDt,
                  ),
                  state,
                );
              },
            ),
          ],
        ),

        // 셔틀버스
        GoRoute(
          path: '/shuttle',
          name: 'shuttle',
          pageBuilder: (context, state) => fadeTransitionPage(
            const ShuttleSelectScreen(),
            state,
          ),
          routes: [
            GoRoute(
              path: '/detail',
              name: 'shuttle-detail',
              pageBuilder: (context, state) {
                final dateStr = state.uri.queryParameters['date'];
                final isAsanStr = state.uri.queryParameters['isAsan'];
                
                final date = dateStr != null 
                    ? DateTime.tryParse(dateStr) ?? DateTime.now()
                    : DateTime.now();
                final isAsan = isAsanStr == 'true';
                
                return fadeTransitionPage(
                  ShuttleDetailScreen(date: date, isAsanToCheonan: isAsan),
                  state,
                );
              },
            ),
          ],
        ),

        // 학과정보
        GoRoute(
          path: '/department',
          name: 'department',
          pageBuilder: (context, state) => fadeTransitionPage(
            const DepartmentPage(),
            state,
          ),
          routes: [
            GoRoute(
              path: '/detail',
              name: 'department-detail',
              pageBuilder: (context, state) {
                // AppState에서 데이터 가져오기
                if (AppState.hasCurrentDepartment()) {
                  return fadeTransitionPage(
                    const DepartmentDetailScreen(),
                    state,
                  );
                } else {
                  // 데이터가 없으면 이전 페이지로 되돌리기
                  return fadeTransitionPage(
                    const DepartmentPage(),
                    state,
                  );
                }
              },
            ),
          ],
        ),

        // 식단정보
        GoRoute(
          path: '/meal',
          name: 'meal',
          pageBuilder: (context, state) => fadeTransitionPage(
            const MealPage(),
            state,
          ),
          routes: [
            GoRoute(
              path: '/list',
              name: 'meal-list',
              pageBuilder: (context, state) {
                final cafeteriaName = state.uri.queryParameters['cafeteriaName'] ?? '종합정보관 식당';
                final action = state.uri.queryParameters['action'] ?? 'MAPP_2312012408';
                
                return fadeTransitionPage(
                  MealListScreen(cafeteriaName: cafeteriaName, action: action),
                  state,
                );
              },
            ),
            GoRoute(
              path: '/detail',
              name: 'meal-detail',
              pageBuilder: (context, state) {
                final cafeteriaName = state.uri.queryParameters['cafeteriaName'] ?? '종합정보관 식당';
                
                // AppState에서 데이터 가져오기
                if (AppState.hasCurrentMealDetail()) {
                  return fadeTransitionPage(
                    MealDetailScreen(
                      notice: AppState.currentMealDetail!,
                      imageUrls: AppState.currentMealImageUrls!,
                      cafeteriaName: AppState.currentMealCafeteriaName!,
                    ),
                    state,
                  );
                } else {
                  // 데이터가 없으면 기본값 사용
                  return fadeTransitionPage(
                    MealDetailScreen(
                      notice: const {},
                      imageUrls: const [],
                      cafeteriaName: cafeteriaName,
                    ),
                    state,
                  );
                }
              },
            ),
          ],
        ),

        // 캠퍼스맵
        GoRoute(
          path: '/campus',
          name: 'campus',
          pageBuilder: (context, state) => fadeTransitionPage(
            const CampusMapPage(),
            state,
          ),
          routes: [
            GoRoute(
              path: '/detail',
              name: 'campus-detail',
              pageBuilder: (context, state) {
                final campusName = state.uri.queryParameters['campusName'] ?? '아산캠퍼스';
                final campusCode = state.uri.queryParameters['campusCode'] ?? 'asan';
                
                return fadeTransitionPage(
                  CampusMapDetailScreen(campusName: campusName, campusCode: campusCode),
                  state,
                );
              },
            ),
          ],
        ),

        // 학사종합
        GoRoute(
          path: '/academic',
          name: 'academic',
          pageBuilder: (context, state) => fadeTransitionPage(
            const AcademicHomePage(),
            state,
          ),
          routes: [
            // 학사일정
            GoRoute(
              path: '/schedule',
              name: 'academic-schedule',
              pageBuilder: (context, state) => fadeTransitionPage(
                const AcademicSchedulePage(),
                state,
              ),
            ),
            // 교육과정
            GoRoute(
              path: '/curriculum',
              name: 'academic-curriculum',
              pageBuilder: (context, state) => fadeTransitionPage(
                const CurriculumHomePage(),
                state,
              ),
              routes: [
                // 교육과정 상세 페이지들
                GoRoute(
                  path: '/:type',
                  name: 'curriculum-detail',
                  pageBuilder: (context, state) {
                    final type = state.pathParameters['type'] ?? 'basic';
                    final title = state.uri.queryParameters['title'] ?? '교육과정';
                    
                    return fadeTransitionPage(
                      CurriculumPage(type: type, title: title),
                      state,
                    );
                  },
                ),
              ],
            ),
            // 수업정보
            GoRoute(
              path: '/class',
              name: 'academic-class',
              pageBuilder: (context, state) {
                final type = state.uri.queryParameters['type'] ?? 'regist';
                final title = state.uri.queryParameters['title'] ?? '수업';
                
                return fadeTransitionPage(
                  ClassInfoScreen(type: type, title: title),
                  state,
                );
              },
            ),
            // 학적정보
            GoRoute(
              path: '/record',
              name: 'academic-record',
              pageBuilder: (context, state) {
                final type = state.uri.queryParameters['type'] ?? 'test';
                final title = state.uri.queryParameters['title'] ?? '학적';
                
                return fadeTransitionPage(
                  RecordInfoScreen(type: type, title: title),
                  state,
                );
              },
            ),
          ],
        ),

        // 설정
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => fadeTransitionPage(
            const SettingsScreen(),
            state,
          ),
        ),
      ],
    );
  }
}
