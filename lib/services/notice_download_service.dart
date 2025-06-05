import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/models/notice_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoticeDownloadService {
  static const String savedNoticesKey = 'saved_notices';

  /// 네트워크 연결 상태 확인
  static Future<bool> isNetworkConnected() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.isNotEmpty && 
           !connectivityResult.contains(ConnectivityResult.none);
  }

  /// 공지사항 패키지 다운로드 (HTML + 이미지 + 첨부파일)
  static Future<String?> downloadNoticePackage({
    required String chidx,
    required String title,
    required String author,
    required String createDt,
    Function(NoticeDownloadProgress)? onProgress,
  }) async {
    try {
      print('공지사항 패키지 다운로드 시작: $chidx');

      // 1. 공지사항 상세 정보 가져오기
      final response = await Dio().get(ApiConfig.getUrl('/notice/idx/$chidx'));
      if (response.statusCode != 200) {
        throw Exception('공지사항 정보 가져오기 실패: ${response.statusCode}');
      }

      final Map<String, dynamic> noticeData = response.data;
      final String contentPath = noticeData['content'] ?? '';
      
      if (contentPath.isEmpty) {
        throw Exception('공지사항 내용 경로가 없습니다.');
      }

      // 2. HTML 콘텐츠 다운로드
      final String htmlUrl = ApiConfig.getFileUrl(contentPath);
      print('HTML 다운로드: $htmlUrl');

      final htmlResponse = await Dio().get(htmlUrl);
      if (htmlResponse.statusCode != 200) {
        throw Exception('HTML 다운로드 실패: ${htmlResponse.statusCode}');
      }

      // 3. 로컬 저장 디렉토리 설정
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory noticesDir = Directory(path.join(appDocDir.path, 'notices'));
      if (!await noticesDir.exists()) {
        await noticesDir.create(recursive: true);
      }

      // chidx별 서브폴더 생성
      final Directory packageDir = Directory(path.join(noticesDir.path, chidx));
      if (await packageDir.exists()) {
        await packageDir.delete(recursive: true);
      }
      await packageDir.create(recursive: true);
      print('패키지 폴더 생성: ${packageDir.path}');

      // 4. HTML 파일 저장
      final String htmlFileName = '${chidx}.html';
      final File htmlFile = File(path.join(packageDir.path, htmlFileName));
      await htmlFile.writeAsString(htmlResponse.data);
      print('HTML 파일 저장: ${htmlFile.path}');

      onProgress?.call(NoticeDownloadProgress(
        current: 1,
        total: 1,
        currentFile: htmlFileName,
        isComplete: true,
      ));

      // 5. 공지사항 정보 JSON 저장
      final NoticeDetailData detailData = NoticeDetailData(
        chidx: chidx,
        title: title,
        content: contentPath,
        author: author,
        createDt: createDt,
        assets: [], // 추후 이미지 파싱 기능 추가 가능
        attachments: [], // 추후 첨부파일 기능 추가 가능
      );

      final File metaFile = File(path.join(packageDir.path, '${chidx}_detail.json'));
      await metaFile.writeAsString(jsonEncode(detailData.toJson()));
      print('메타 정보 저장: ${metaFile.path}');

      // 6. 저장된 공지사항 목록에 추가
      await _addToSavedNotices(SavedNoticeInfo(
        chidx: chidx,
        title: title,
        author: author,
        createDt: createDt,
        htmlFilePath: htmlFile.path,
        savedAt: DateTime.now(),
      ));

      print('공지사항 패키지 다운로드 완료: ${htmlFile.path}');
      return htmlFile.path;

    } catch (e) {
      print('공지사항 패키지 다운로드 오류: $e');
      return null;
    }
  }

  /// 단일 HTML 다운로드 (기존 방식)
  static Future<String?> downloadNoticeHtml({
    required String url,
    required String chidx,
    required String title,
    required String author,
    required String createDt,
  }) async {
    try {
      print('공지사항 HTML 다운로드 시작: $url');

      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP 오류: ${response.statusCode}');
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory noticesDir = Directory(path.join(appDocDir.path, 'notices'));
      if (!await noticesDir.exists()) {
        await noticesDir.create(recursive: true);
      }

      // chidx별 폴더 생성
      final Directory packageDir = Directory(path.join(noticesDir.path, chidx));
      if (await packageDir.exists()) {
        await packageDir.delete(recursive: true);
      }
      await packageDir.create(recursive: true);

      final String fileName = '${chidx}.html';
      final String filePath = path.join(packageDir.path, fileName);
      final File file = File(filePath);

      await file.writeAsString(response.data);

      // 저장된 공지사항 목록에 추가
      await _addToSavedNotices(SavedNoticeInfo(
        chidx: chidx,
        title: title,
        author: author,
        createDt: createDt,
        htmlFilePath: filePath,
        savedAt: DateTime.now(),
      ));

      print('공지사항 HTML 저장 완료: $filePath');
      return filePath;

    } catch (e) {
      print('공지사항 HTML 다운로드 오류: $e');
      return null;
    }
  }

  /// 저장된 공지사항 목록 가져오기
  static Future<List<SavedNoticeInfo>> getSavedNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedNoticesJson = prefs.getString(savedNoticesKey);
      
      if (savedNoticesJson == null) {
        return [];
      }

      final List<dynamic> savedNoticesList = jsonDecode(savedNoticesJson);
      final List<SavedNoticeInfo> notices = savedNoticesList
          .map((json) => SavedNoticeInfo.fromJson(json))
          .toList();

      // 파일이 실제로 존재하는지 확인하고 필터링
      final List<SavedNoticeInfo> existingNotices = [];
      for (final notice in notices) {
        final file = File(notice.htmlFilePath);
        if (await file.exists()) {
          existingNotices.add(notice);
        } else {
          print('파일이 존재하지 않음: ${notice.htmlFilePath}');
        }
      }

      // 존재하지 않는 파일들은 목록에서 제거
      if (existingNotices.length != notices.length) {
        await _saveSavedNotices(existingNotices);
      }

      return existingNotices;

    } catch (e) {
      print('저장된 공지사항 목록 조회 오류: $e');
      return [];
    }
  }

  /// 특정 공지사항이 저장되어 있는지 확인
  static Future<bool> isNoticeSaved(String chidx) async {
    final savedNotices = await getSavedNotices();
    return savedNotices.any((notice) => notice.chidx == chidx);
  }

  /// 저장된 공지사항 삭제
  static Future<bool> deleteNotice(String chidx) async {
    try {
      final savedNotices = await getSavedNotices();
      final notice = savedNotices.where((n) => n.chidx == chidx).firstOrNull;
      
      if (notice == null) {
        return false;
      }

      // 파일 삭제
      final Directory packageDir = Directory(path.dirname(notice.htmlFilePath));
      if (await packageDir.exists()) {
        await packageDir.delete(recursive: true);
        print('패키지 삭제 완료: ${packageDir.path}');
      }

      // 목록에서 제거
      savedNotices.removeWhere((n) => n.chidx == chidx);
      await _saveSavedNotices(savedNotices);

      return true;
    } catch (e) {
      print('공지사항 삭제 오류: $e');
      return false;
    }
  }

  /// 모든 저장된 공지사항 삭제
  static Future<bool> deleteAllNotices() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory noticesDir = Directory(path.join(appDocDir.path, 'notices'));
      
      if (await noticesDir.exists()) {
        await noticesDir.delete(recursive: true);
        print('모든 공지사항 삭제 완료');
      }

      // SharedPreferences에서도 제거
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(savedNoticesKey);

      return true;
    } catch (e) {
      print('모든 공지사항 삭제 오류: $e');
      return false;
    }
  }

  /// 저장된 공지사항 목록에 추가
  static Future<void> _addToSavedNotices(SavedNoticeInfo notice) async {
    try {
      final savedNotices = await getSavedNotices();
      
      // 이미 존재하는 경우 제거 후 추가 (업데이트)
      savedNotices.removeWhere((n) => n.chidx == notice.chidx);
      savedNotices.add(notice);
      
      // 날짜순으로 정렬 (최신순)
      savedNotices.sort((a, b) => b.savedAt.compareTo(a.savedAt));

      await _saveSavedNotices(savedNotices);
    } catch (e) {
      print('저장된 공지사항 목록 추가 오류: $e');
    }
  }

  /// 저장된 공지사항 목록 저장
  static Future<void> _saveSavedNotices(List<SavedNoticeInfo> notices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(notices.map((n) => n.toJson()).toList());
      await prefs.setString(savedNoticesKey, jsonString);
    } catch (e) {
      print('저장된 공지사항 목록 저장 오류: $e');
    }
  }

  /// 첨부파일 개별 다운로드
  static Future<String?> downloadAttachment({
    required String chidx,
    required NoticeAttachmentItem attachment,
    Function(double)? onProgress,
  }) async {
    try {
      if (!await isNetworkConnected()) {
        throw Exception('네트워크에 연결되어 있지 않습니다.');
      }

      print('첨부파일 다운로드 시작: ${attachment.originName}');

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory packageDir = Directory(path.join(appDocDir.path, 'notices', chidx));
      
      if (!await packageDir.exists()) {
        await packageDir.create(recursive: true);
      }

      final Directory attachmentsDir = Directory(path.join(packageDir.path, 'attachments'));
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      // 파일명 안전하게 처리
      final String safeFileName = attachment.originName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final String filePath = path.join(attachmentsDir.path, safeFileName);
      
      // 이미 다운로드된 파일이 있으면 경로 반환
      final File file = File(filePath);
      if (await file.exists()) {
        print('첨부파일 이미 존재: $filePath');
        return filePath;
      }

      // 다운로드 실행
      final dio = Dio();
      await dio.download(
        attachment.originUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      print('첨부파일 다운로드 완료: $filePath');
      return filePath;

    } catch (e) {
      print('첨부파일 다운로드 오류: $e');
      return null;
    }
  }

  /// 첨부파일이 로컬에 있는지 확인
  static Future<bool> isAttachmentDownloaded(String chidx, NoticeAttachmentItem attachment) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String safeFileName = attachment.originName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final String filePath = path.join(appDocDir.path, 'notices', chidx, 'attachments', safeFileName);
      
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 첨부파일 로컬 경로 가져오기
  static Future<String?> getAttachmentLocalPath(String chidx, NoticeAttachmentItem attachment) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String safeFileName = attachment.originName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final String filePath = path.join(appDocDir.path, 'notices', chidx, 'attachments', safeFileName);
      
      final File file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 저장 공간 사용량 계산
  static Future<int> getStorageUsage() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory noticesDir = Directory(path.join(appDocDir.path, 'notices'));
      
      if (!await noticesDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in noticesDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      print('저장 공간 사용량 계산 오류: $e');
      return 0;
    }
  }
}
