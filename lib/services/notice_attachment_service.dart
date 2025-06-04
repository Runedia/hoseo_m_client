import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hoseo_m_client/models/notice_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:hoseo_m_client/utils/notice_file_utils.dart';
import 'package:open_file/open_file.dart';

class NoticeAttachmentService {
  static const String baseUrl = 'http://rukeras.com:3000';

  /// 첨부파일 개별 다운로드
  static Future<String?> downloadAttachment({
    required String chidx,
    required NoticeAttachmentItem attachment,
    Function(double)? onProgress,
  }) async {
    try {
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
      final String safeFileName = NoticeFileUtils.sanitizeFileName(attachment.originName);
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
      final String safeFileName = NoticeFileUtils.sanitizeFileName(attachment.originName);
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
      final String safeFileName = NoticeFileUtils.sanitizeFileName(attachment.originName);
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

  /// 사용자 다운로드 폴더에 첨부파일 다운로드
  static Future<String?> downloadAttachmentToUserLocation({
    required NoticeAttachmentItem attachment,
    Function(double)? onProgress,
  }) async {
    try {
      print('사용자 다운로드 시작: ${attachment.originName}');
      
      // Downloads 폴더에 직접 저장
      Directory? downloadsDirectory;
      
      if (Platform.isAndroid) {
        // Android의 경우 Downloads 폴더 사용
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        
        // 대안 경로들
        if (!await downloadsDirectory.exists()) {
          final externalDir = await getExternalStorageDirectory();
          downloadsDirectory = Directory('${externalDir?.path}/Download');
          
          if (!await downloadsDirectory.exists()) {
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }
        }
      } else {
        // iOS의 경우 Documents 폴더 사용
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }
      
      print('다운로드 디렉토리: ${downloadsDirectory.path}');
      
      // 디렉토리가 없으면 생성
      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      // 파일명 안전하게 처리
      final String safeFileName = NoticeFileUtils.sanitizeFileName(attachment.originName);
      final String filePath = path.join(downloadsDirectory.path, safeFileName);
      
      print('다운로드 경로: $filePath');
      
      // 다운로드 실행
      final dio = Dio();
      await dio.download(
        attachment.originUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            print('다운로드 진행률: ${(progress * 100).toStringAsFixed(1)}%');
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

  /// 다운로드된 파일을 기본 앱으로 열기 (개선된 버전)
  static Future<bool> openFileWithDefaultApp(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      
      switch (result.type) {
        case ResultType.done:
          print('파일 열기 성공: $filePath');
          return true;
        case ResultType.noAppToOpen:
          print('파일을 열 수 있는 앱이 없습니다: $filePath');
          return false;
        case ResultType.fileNotFound:
          print('파일을 찾을 수 없습니다: $filePath');
          return false;
        case ResultType.permissionDenied:
          print('파일 접근 권한이 없습니다: $filePath');
          return false;
        case ResultType.error:
        default:
          print('파일 열기 오류: ${result.message}');
          return false;
      }
    } catch (e) {
      print('파일 열기 실패: $e');
      return false;
    }
  }

  /// 첨부파일 열기 (기존 메서드는 호환성을 위해 유지)
  static Future<bool> openAttachment(String localPath) async {
    return await openFileWithDefaultApp(localPath);
  }

  /// 저장된 첨부파일 열기
  static Future<bool> openSavedAttachment(String chidx, NoticeAttachmentItem attachment) async {
    final String? localPath = await getAttachmentLocalPath(chidx, attachment);
    if (localPath != null) {
      return await openFileWithDefaultApp(localPath);
    }
    return false;
  }

  /// 모든 첨부파일의 다운로드 상태 확인
  static Future<Map<String, bool>> checkAttachmentsStatus(String chidx, List<NoticeAttachmentItem> attachments) async {
    final Map<String, bool> statusMap = {};
    
    for (final attachment in attachments) {
      final isDownloaded = await isAttachmentDownloaded(chidx, attachment);
      statusMap[attachment.originName] = isDownloaded;
    }
    
    return statusMap;
  }
}
