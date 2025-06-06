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
├── config/                      # 설정 관리
│   └── api_config.dart          # API 엔드포인트 및 환경 설정
│
├── database/                    # 데이터베이스 관리
│   └── database_manager.dart    # SQLite 데이터베이스 매니저 (오프라인 지원)
│
├── models/                      # 데이터 모델
│   └── notice_models.dart       # 공지사항 데이터 모델
│
├── router/                      # 라우팅 관리
│   └── app_router.dart          # 앱 라우터 설정
│
├── services/                    # 비즈니스 로직 서비스
│   ├── notice_attachment_service.dart  # 공지사항 첨부파일 서비스
│   ├── notice_download_service.dart    # 공지사항 다운로드 서비스
│   ├── notice_local_server.dart        # 공지사항 로컬 서버 (HTML 뷰어)
│   └── notice_network_service.dart     # 공지사항 네트워크 서비스
│
├── menu_1_screen/              # 공지사항 관련 화면
│   ├── notice_screen.dart       # 공지사항 목록 화면
│   ├── notice_webview_screen.dart # 공지사항 웹뷰 상세 화면
│   ├── saved_notices_screen.dart    # 저장된 공지사항 화면 (미사용)
│   └── widgets/                 # 공지사항 관련 위젯
│       ├── notice_attachment_section.dart   # 첨부파일 섹션
│       ├── notice_download_indicators.dart  # 다운로드 인디케이터
│       └── notice_webview_controls.dart     # 웹뷰 컨트롤
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
- 첨부파일 다운로드 및 관리
- 공지사항 저장 기능
- **오프라인 지원 및 캐싱**
- **향상된 웹뷰 컨트롤 및 네비게이션**
- **테이블 형태의 개선된 목록 UI**

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
- **테이블 형태의 개선된 목록 레이아웃**
- **홀수/짝수 줄 구분으로 향상된 가독성**
- **모바일 최적화된 셀 높이 및 정렬**

### 5. 캠퍼스맵 🗺️
- 아산/천안 캠퍼스 지도
- 건물별 위치 정보
- 인터랙티브 맵 기능
- **향상된 네비게이션 및 사용자 경험**

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
- **GoRouter 기반 통합 히스토리 관리 시스템**
- 부드러운 페이지 전환 애니메이션
- **일관된 네비게이션 패턴 및 상태 관리**

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
- **Go Router** - 선언적 라우팅 관리
- **GoRouterHistory** - 통합 네비게이션 상태 관리 (브라우저 스타일)

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
  flutter_localizations: sdk        # 다국어 지원
  go_router: ^14.6.1               # 선언적 라우팅
  http: ^1.1.0                     # HTTP 통신
  path_provider: ^2.1.1            # 파일 시스템 경로
  webview_flutter: ^4.4.2          # 웹뷰
  permission_handler: ^11.0.1      # 권한 관리
  dio: ^5.8.0                      # HTTP 클라이언트
  sqflite: ^2.4.2                  # SQLite 데이터베이스
  path: ^1.9.1                     # 파일 경로 처리
  url_launcher: ^6.3.1             # 외부 URL 실행
  connectivity_plus: ^6.1.4        # 네트워크 연결 상태
  shared_preferences: ^2.2.2       # 로컬 설정 저장
  intl: ^0.19.0                    # 국제화 지원 (버전은 Flutter SDK에 따라 조정)
  open_file: ^3.5.10               # 파일 열기
```

## 🔄 API + DB 통합 패턴

앱은 온라인/오프라인 하이브리드 동작을 지원합니다:

1. **온라인 상태**: REST API 우선 호출 → 성공 시 DB 업데이트
2. **API 실패**: 로컬 DB 데이터 사용 + 오프라인 안내
3. **오프라인 상태**: 로컬 DB 데이터만 사용
4. **데이터 없음**: 적절한 에러 메시지 표시

### 오프라인 지원 기능
- **네트워크 연결 상태 자동 감지**
- **로컬 SQLite DB를 활용한 데이터 캐싱**
- **오프라인 상태에서도 이전 데이터 조회 가능**
- **네트워크 복구 시 자동 데이터 동기화**
- **사용자에게 명확한 오프라인 상태 안내**

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

### 로컬 개발 환경 설정

#### localhost REST API 연결 설정

개발 중 localhost에서 실행되는 REST API 서버에 연결하려면 다음 설정이 필요합니다:

1. **Android 네트워크 보안 설정**
   - `android/app/src/main/res/xml/network_security_config.xml`에서 localhost 도메인 허용
   - 이미 설정된 localhost, 127.0.0.1, 10.0.2.2 도메인들이 포함되어 있습니다

2. **API 엔드포인트 설정**
   - `lib/config/api_config.dart`에서 개발용 호스트 주소 설정
   - **Android 에뮬레이터**: `http://10.0.2.2:3000` (기본 설정)
   - **실제 기기**: PC의 WiFi IP 주소 사용 (예: `http://192.168.1.100:3000`)

3. **intl 라이브러리 버전 호환성**
   ```bash
   # Flutter 버전에 따라 intl 라이브러리 버전이 달라질 수 있습니다
   # 콘솔에서 버전 충돌 오류 발생 시 해당 버전으로 수정하세요
   flutter pub deps
   ```
   
   만약 버전 충돌이 발생하면 `pubspec.yaml`에서 intl 버전을 조정:
   ```yaml
   dependencies:
     intl: ^0.18.1  # 콘솔 메시지에 따라 버전 수정
   ```

4. **Android Manifest 설정**
   - `android:enableOnBackInvokedCallback="true"` 이미 설정됨 (Android 13+ 호환성)
   - 네트워크 권한 및 보안 설정 포함

#### 개발 서버 실행 확인
로컬 REST API 서버가 포트 3000에서 실행 중인지 확인:
```bash
# Windows
netstat -an | findstr :3000

# 또는 브라우저에서 직접 확인
http://localhost:3000
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