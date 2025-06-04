import 'package:flutter/material.dart';
import 'package:hoseo_m_client/models/notice_models.dart';

class NoticeDownloadIndicators {
  /// 자동 다운로드 인디케이터 (우상단 작은 표시)
  static Widget buildAutoDownloadIndicator(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
            const SizedBox(width: 8),
            Text('다운로드 중...', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// 메인 다운로드 진행 다이얼로그
  static Widget buildDownloadDialog(BuildContext context, NoticeDownloadProgress? downloadProgress) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(value: downloadProgress?.percentage, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text('공지사항 저장 중...', style: Theme.of(context).textTheme.titleMedium),
                if (downloadProgress != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${downloadProgress.current}/${downloadProgress.total} - ${downloadProgress.currentFile}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 웹뷰 로딩 인디케이터
  static Widget buildLoadingIndicator(BuildContext context, double loadingProgress) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress > 0 ? loadingProgress : null,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '공지사항을 불러오는 중... ${(loadingProgress * 100).toInt()}%',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }

  /// 첨부파일 개별 다운로드 진행률 표시
  static Widget buildAttachmentDownloadProgress(double progress) {
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: progress, strokeWidth: 2),
          const SizedBox(height: 4),
          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
