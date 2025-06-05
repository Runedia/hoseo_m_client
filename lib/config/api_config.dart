/// API 설정을 관리하는 클래스
/// 모든 API 엔드포인트의 기본 URL을 중앙에서 관리합니다.
class ApiConfig {
  // 싱글톤 패턴 적용
  static final ApiConfig _instance = ApiConfig._internal();

  factory ApiConfig() => _instance;

  ApiConfig._internal();

  // 환경 설정
  static const bool _isProduction = false; // false로 설정하면 개발 모드

  // 호스트 URL 설정
  static const String _productionHost = 'http://rukeras.com:3000';
  // 개발용 호스트 (애뮬레이터 이용시)
  static const String _developmentHost = 'http://10.0.2.2:3000';
  // 개발용 호스트 (다른 환경 이용시)
  // static const String _developmentHost = 'http://localhost:3000';

  /// 현재 환경에 맞는 기본 API URL을 반환합니다.
  static String get baseUrl => _isProduction ? _productionHost : _developmentHost;

  /// 전체 API URL을 생성합니다.
  ///
  /// [endpoint] API 엔드포인트 (예: '/notice/list', '/menu/list2')
  ///
  /// 사용 예시:
  /// ```dart
  /// final url = ApiConfig.getUrl('/notice/list?page=1&pageSize=30');
  /// ```
  static String getUrl(String endpoint) {
    // endpoint가 이미 전체 URL인 경우 그대로 반환
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }

    // endpoint가 '/'로 시작하지 않으면 추가
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    return '$baseUrl$endpoint';
  }

  /// 파일 다운로드용 URL을 생성합니다.
  ///
  /// [filePath] 파일 경로 (예: 'uploads/notice/file.pdf')
  static String getFileUrl(String filePath) {
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    // filePath가 '/'로 시작하면 제거 (baseUrl에서 이미 포함)
    if (filePath.startsWith('/')) {
      filePath = filePath.substring(1);
    }

    return '$baseUrl/$filePath';
  }

  /// 현재 설정 정보를 반환합니다.
  static Map<String, dynamic> getConfigInfo() {
    return {
      'isProduction': _isProduction,
      'baseUrl': baseUrl,
      'productionHost': _productionHost,
      'developmentHost': _developmentHost,
    };
  }

  /// 개발 모드인지 확인합니다.
  static bool get isDevelopment => !_isProduction;

  /// 운영 모드인지 확인합니다.
  static bool get isProduction => _isProduction;
}
