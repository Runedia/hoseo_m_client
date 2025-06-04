import 'dart:io';
import 'package:path/path.dart' as path;

class NoticeLocalServer {
  static NoticeLocalServer? _instance;

  static NoticeLocalServer get instance => _instance ??= NoticeLocalServer._();

  NoticeLocalServer._();

  HttpServer? _server;
  int _serverPort = 8080;
  bool _isRunning = false;
  String? _currentBaseDir;

  bool get isRunning => _isRunning;

  int get serverPort => _serverPort;

  String get serverUrl => 'http://localhost:$_serverPort';

  /// 서버 시작 (이미 실행 중이면 재사용)
  Future<String> startServer(String htmlFilePath) async {
    final String baseDir = path.dirname(htmlFilePath);

    // 이미 같은 디렉토리로 서버가 실행 중이면 재사용
    if (_isRunning && _currentBaseDir == baseDir) {
      print('기존 공지사항 서버 재사용: $serverUrl');
      return _getFileUrl(htmlFilePath);
    }

    // 서버가 다른 디렉토리로 실행 중이면 재시작
    if (_isRunning) {
      print('공지사항 서버 재시작 (디렉토리 변경)');
      await stopServer();
    }

    await _startNewServer(baseDir);
    return _getFileUrl(htmlFilePath);
  }

  /// 새 서버 시작
  Future<void> _startNewServer(String baseDir) async {
    try {
      // 사용 가능한 포트 찾기
      for (int port = 8080; port <= 8090; port++) {
        try {
          _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
          _serverPort = port;
          print('공지사항 로컬 서버 시작: $serverUrl (baseDir: $baseDir)');
          break;
        } catch (e) {
          print('포트 $port 사용 불가: $e');
          continue;
        }
      }

      if (_server == null) {
        throw Exception('사용 가능한 포트를 찾을 수 없습니다');
      }

      _currentBaseDir = baseDir;
      _isRunning = true;

      // 서버 요청 처리
      _server!.listen((HttpRequest request) async {
        await _handleRequest(request, baseDir);
      });
    } catch (e) {
      print('공지사항 로컬 서버 시작 오류: $e');
      _isRunning = false;
      rethrow;
    }
  }

  /// 요청 처리
  Future<void> _handleRequest(HttpRequest request, String baseDir) async {
    try {
      String requestPath = request.uri.path;
      print('공지사항 서버 요청: $requestPath');

      // URL 디코딩 처리 (한글 파일명 지원)
      requestPath = Uri.decodeComponent(requestPath);
      print('디코딩된 경로: $requestPath');

      String filePath;
      if (requestPath == '/' || requestPath.isEmpty) {
        // 루트 요청은 baseDir의 첫 번째 HTML 파일
        final Directory dir = Directory(baseDir);
        final List<FileSystemEntity> files = await dir.list().toList();
        final File? htmlFile = files
            .where((f) => f is File && f.path.endsWith('.html'))
            .cast<File>()
            .firstOrNull;

        if (htmlFile != null) {
          filePath = htmlFile.path;
        } else {
          throw Exception('HTML 파일을 찾을 수 없습니다');
        }
      } else {
        // 특정 파일 요청
        filePath = path.join(baseDir, requestPath.substring(1));
      }

      final File requestedFile = File(filePath);
      print('실제 파일 경로: ${requestedFile.path}');

      if (await requestedFile.exists()) {
        // MIME 타입 설정
        String mimeType = _getMimeType(path.extension(filePath));

        request.response.headers.set('Content-Type', mimeType);
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        request.response.headers.set('Cache-Control', 'no-cache');

        if (mimeType.startsWith('text/')) {
          // 텍스트 파일은 UTF-8로 읽기
          final String content = await requestedFile.readAsString();
          request.response.write(content);
        } else {
          // 바이너리 파일은 그대로 전송
          final List<int> bytes = await requestedFile.readAsBytes();
          request.response.add(bytes);
        }

        print('공지사항 파일 전송 완료: $filePath (${await requestedFile.length()} bytes)');
      } else {
        // 파일이 없으면 404 응답
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('파일을 찾을 수 없습니다: $requestPath');
        print('공지사항 파일 없음: $filePath');

        // 디렉토리의 모든 파일 목록 출력 (디버깅용)
        try {
          final Directory dir = Directory(baseDir);
          final List<FileSystemEntity> files = await dir.list().toList();
          print('디렉토리 내 파일들:');
          for (var file in files) {
            print('- ${path.basename(file.path)}');
          }
        } catch (e) {
          print('디렉토리 목록 조회 실패: $e');
        }
      }

      await request.response.close();
    } catch (e) {
      print('공지사항 서버 요청 처리 오류: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write('서버 오류: $e');
        await request.response.close();
      } catch (closeError) {
        print('응답 종료 오류: $closeError');
      }
    }
  }

  /// 파일별 URL 생성
  String _getFileUrl(String filePath) {
    final String fileName = path.basename(filePath);
    return '$serverUrl/$fileName';
  }

  /// 서버 중지
  Future<void> stopServer() async {
    if (_server != null && _isRunning) {
      try {
        await _server!.close();
        print('공지사항 로컬 서버 정지');
      } catch (e) {
        print('공지사항 서버 정지 오류: $e');
      }
      _server = null;
      _isRunning = false;
      _currentBaseDir = null;
    }
  }

  /// MIME 타입 결정
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.html':
      case '.htm':
        return 'text/html; charset=utf-8';
      case '.css':
        return 'text/css; charset=utf-8';
      case '.js':
        return 'application/javascript; charset=utf-8';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.pdf':
        return 'application/pdf';
      case '.json':
        return 'application/json; charset=utf-8';
      default:
        return 'application/octet-stream';
    }
  }

  /// 서버 상태 정보
  Map<String, dynamic> getServerInfo() {
    return {
      'isRunning': _isRunning,
      'serverPort': _serverPort,
      'serverUrl': serverUrl,
      'currentBaseDir': _currentBaseDir,
    };
  }
}
