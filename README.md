# 호서대학교 모바일앱 📱

> 호서대학교 UI/UX 7조 모바일 클라이언트 프로젝트

## 📋 프로젝트 개요

호서대학교 학생들을 위한 종합 모바일 애플리케이션입니다. 공지사항, 셔틀버스, 학과정보, 식단표, 캠퍼스맵, 학사종합 등 다양한 기능을 제공합니다.

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점 및 메인 홈 화면
├── settings_screen.dart         # 설정 화면
│
├── database/                    # 데이터베이스 관리
│   └── database_manager.dart    # SQLite 데이터베이스 매니저 (오프라인 지원)
│
├── menu_1_screen/              # 공지사항 관련 화면
│   ├── notice_screen.dart       # 공지사항 목록 화면
│   └── notice_webview_page.dart # 공지사항 웹뷰 상세 화면
│
├── menu_2_screen/              # 셔틀버스 관련 화면
│   ├── shuttle_select_screen.dart  # 셔틀버스 선택 화면
│   └── shuttle_detail_screen.dart  # 셔틀버스 시간표 상세 화면
│
├── menu_3_screen/              # 학과정보 관련 화면
│   ├── department_screen.dart      # 학과 목록 화면
│   └── department_detail_screen.dart # 학과 상세 정보 화면
│
├── menu_4_screen/              # 식단표 관련 화면
│   ├── meal_schedule.dart       # 식당 선택 화면
│   ├── meal_list_screen.dart    # 식단 목록 화면
│   └── meal_detail_screen.dart  # 식단 상세 화면
│
├── menu_5_screen/              # 캠퍼스맵 관련 화면
│   ├── campus_map.dart          # 캠퍼스 선택 화면
│   ├── campus_map_detail.dart   # 캠퍼스맵 상세 화면
│   └── campus_map_detail_screen.dart # 캠퍼스맵 세부 정보
│
├── menu_6_screen/              # 학사종합 관련 화면
│   ├── academic_home_screen.dart     # 학사종합 홈 화면
│   ├── schedule_home_screen.dart     # 학사일정 홈 화면
│   ├── schedule_calendar_screen.dart # 학사일정 달력 화면
│   ├── schedule_list_screen.dart     # 학사일정 목록 화면
│   ├── curriculum_home_screen.dart   # 교육과정 홈 화면
│   ├── curriculum_screen.dart        # 교육과정 화면
│   ├── class_screen.dart            # 수강/강의 정보 화면
│   └── record_screen.dart           # 학적 정보 화면
│
├── utils/                      # 공통 유틸리티
│   ├── common_scaffold.dart     # 공통 스캐폴드 및 네비게이션 관리
│   ├── app_state.dart          # 앱 상태 관리
│   ├── animations/
│   │   └── page_transitions.dart # 페이지 전환 애니메이션
│   └── themes/                 # 테마 관련
│       ├── themes.dart         # 테마 정의 (HS Blue, Green, Grey, Red)
│       ├── theme_preferences.dart # 테마 설정 저장/로드
│       └── theme_provider.dart # 테마 상태 제공자
│
└── vo/                         # Value Object
    └── FeatureItem.dart        # 기능 아이템 데이터 모델
```

## 🌟 주요 기능

### 1. 공지사항 📢
- 호서대학교 공지사항 조회
- 웹뷰를 통한 상세 공지 확인
- 오프라인 지원

### 2. 셔틀버스 🚌
- 아산-천안 캠퍼스 간 셔틀버스 시간표
- 실시간 시간표 조회
- 요일별 다른 시간표 지원

### 3. 학과정보 🎓
- 각 학과별 상세 정보 제공
- 교수진, 교육과정 등 정보 조회

### 4. 식단표 🍽️
- 캠퍼스 내 식당별 식단 정보
- 일별 메뉴 조회
- 이미지 포함 상세 식단 정보

### 5. 캠퍼스맵 🗺️
- 아산/천안 캠퍼스 지도
- 건물별 위치 정보
- 인터랙티브 맵 기능

### 6. 학사종합 📚
- **학사일정**: 달력 및 목록 형태로 학사 일정 조회
- **교육과정**: 전공별 교육과정 정보
- **수강/강의**: 수강신청, 강의계획서 등
- **학적**: 학적 관련 정보 및 서류

### 7. 외부 연동 🔗
- **LMS**: 호서대학교 학습관리시스템 연결
- **통합포털**: 호서대학교 통합포털 연결

## 🎨 UI/UX 특징

### 테마 시스템
- **HS Red** (기본)
- **HS Blue**
- **HS Green** 
- **HS Grey**

### 네비게이션
- 브라우저 스타일의 이전/다음/홈 네비게이션
- 히스토리 관리 시스템
- 부드러운 페이지 전환 애니메이션

### 반응형 디자인
- 다양한 화면 크기 지원
- 적응형 레이아웃

## 🏗️ 기술 스택

### Frontend
- **Flutter** - 크로스플랫폼 모바일 앱 개발
- **Dart** - 프로그래밍 언어

### 상태 관리
- **StatefulWidget** - 기본 상태 관리
- **SharedPreferences** - 사용자 설정 저장
- **Custom NavigationHistory** - 네비게이션 상태 관리

### 데이터베이스
- **SQLite** (via sqflite) - 로컬 데이터 저장
- **DatabaseManager** - 통합 데이터베이스 관리

### 네트워킹
- **HTTP** - REST API 통신
- **Dio** - 고급 HTTP 클라이언트
- **Connectivity Plus** - 네트워크 상태 확인

### UI/UX
- **Material Design** - 기본 디자인 시스템
- **Custom Themes** - 호서대학교 브랜드 컬러
- **WebView Flutter** - 웹 콘텐츠 표시
- **Pretendard Font** - 한국어 최적화 폰트

## 📦 주요 의존성

```yaml
dependencies:
  flutter: sdk
  http: ^1.1.0                    # HTTP 통신
  sqflite: ^2.4.2                # SQLite 데이터베이스
  connectivity_plus: ^6.1.4       # 네트워크 연결 상태
  shared_preferences: ^2.2.2      # 로컬 설정 저장
  webview_flutter: ^4.4.2        # 웹뷰
  url_launcher: ^6.3.1           # 외부 URL 실행
  path_provider: ^2.1.1          # 파일 시스템 경로
  dio: ^5.8.0                    # HTTP 클라이언트
  intl: ^0.18.1                  # 국제화 지원
  permission_handler: ^11.0.1    # 권한 관리
```

## 🔄 API + DB 통합 패턴

앱은 온라인/오프라인 하이브리드 동작을 지원합니다:

1. **온라인 상태**: REST API 우선 호출 → 성공 시 DB 업데이트
2. **API 실패**: 로컬 DB 데이터 사용 + 오프라인 안내
3. **오프라인 상태**: 로컬 DB 데이터만 사용
4. **데이터 없음**: 적절한 에러 메시지 표시

## 🚀 시작하기

### 환경 요구사항
- Flutter SDK ^3.7.2
- Dart SDK ^3.7.2
- Android 개발 환경 (Android Studio, Android SDK)

### 설치 및 실행
```bash
# 의존성 설치
flutter pub get

# 앱 실행 (디버그 모드)
flutter run

# 릴리즈 빌드
flutter build apk --release
```

## 📱 지원 플랫폼
- **Android** (API 21+)

## 🏫 서버 연동

백엔드 서버와 RESTful API로 통신:
- 기본 서버: `http://rukeras.com:3000`
- 공지사항, 셔틀버스, 학과정보, 식단표, 학사정보 등 API 연동

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](./LICENSE) 파일을 참조하세요.

---

**호서대학교 UI/UX 7조** 개발팀