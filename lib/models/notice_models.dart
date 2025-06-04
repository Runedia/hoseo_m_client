// 공지사항 상세 데이터 모델
class NoticeDetailData {
  final String chidx;
  final String title;
  final String content;
  final String author;
  final String createDt;
  final List<NoticeAssetItem> assets;
  final List<NoticeAttachmentItem> attachments;

  NoticeDetailData({
    required this.chidx,
    required this.title,
    required this.content,
    required this.author,
    required this.createDt,
    required this.assets,
    required this.attachments,
  });

  factory NoticeDetailData.fromJson(Map<String, dynamic> json) {
    return NoticeDetailData(
      chidx: json['chidx']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      createDt: json['create_dt'] ?? '',
      assets: (json['assets'] as List<dynamic>?)
          ?.map((item) => NoticeAssetItem.fromJson(item))
          .toList() ?? [],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((item) => NoticeAttachmentItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chidx': chidx,
      'title': title,
      'content': content,
      'author': author,
      'create_dt': createDt,
      'assets': assets.map((item) => item.toJson()).toList(),
      'attachments': attachments.map((item) => item.toJson()).toList(),
    };
  }
}

class NoticeAssetItem {
  final String localPath;
  final String fileName;

  NoticeAssetItem({required this.localPath, required this.fileName});

  factory NoticeAssetItem.fromJson(Map<String, dynamic> json) {
    return NoticeAssetItem(
      localPath: json['localPath'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localPath': localPath,
      'fileName': fileName,
    };
  }
}

class NoticeAttachmentItem {
  final String originUrl;
  final String originName;
  final String localPath;
  final String fileName;
  final bool isDownloaded;
  final int? fileSize;

  NoticeAttachmentItem({
    required this.originUrl,
    required this.originName,
    required this.localPath,
    required this.fileName,
    this.isDownloaded = false,
    this.fileSize,
  });

  factory NoticeAttachmentItem.fromJson(Map<String, dynamic> json) {
    return NoticeAttachmentItem(
      originUrl: json['originUrl'] ?? json['file_url'] ?? '',
      originName: json['originName'] ?? json['origin_name'] ?? '',
      localPath: json['localPath'] ?? '',
      fileName: json['fileName'] ?? json['file_name'] ?? '',
      isDownloaded: json['isDownloaded'] ?? false,
      fileSize: json['fileSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originUrl': originUrl,
      'originName': originName,
      'localPath': localPath,
      'fileName': fileName,
      'isDownloaded': isDownloaded,
      'fileSize': fileSize,
    };
  }
}

// 다운로드 진행 상태
class NoticeDownloadProgress {
  final int current;
  final int total;
  final String currentFile;
  final bool isComplete;

  NoticeDownloadProgress({
    required this.current,
    required this.total,
    required this.currentFile,
    this.isComplete = false,
  });

  double get percentage => total > 0 ? (current / total) : 0.0;
}

// 저장된 공지사항 정보
class SavedNoticeInfo {
  final String chidx;
  final String title;
  final String author;
  final String createDt;
  final String htmlFilePath;
  final DateTime savedAt;

  SavedNoticeInfo({
    required this.chidx,
    required this.title,
    required this.author,
    required this.createDt,
    required this.htmlFilePath,
    required this.savedAt,
  });

  factory SavedNoticeInfo.fromJson(Map<String, dynamic> json) {
    return SavedNoticeInfo(
      chidx: json['chidx'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      createDt: json['create_dt'] ?? '',
      htmlFilePath: json['htmlFilePath'] ?? '',
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chidx': chidx,
      'title': title,
      'author': author,
      'create_dt': createDt,
      'htmlFilePath': htmlFilePath,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
