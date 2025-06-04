import 'package:flutter/material.dart';
import 'package:hoseo_m_client/menu_1_screen/notice_webview_enhanced.dart';
import 'package:hoseo_m_client/models/notice_models.dart';
import 'package:hoseo_m_client/services/notice_download_service.dart';
import 'package:hoseo_m_client/services/notice_local_server.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';

class SavedNoticesScreen extends StatefulWidget {
  const SavedNoticesScreen({super.key});

  @override
  State<SavedNoticesScreen> createState() => _SavedNoticesScreenState();
}

class _SavedNoticesScreenState extends State<SavedNoticesScreen> {
  List<SavedNoticeInfo> savedNotices = [];
  bool isLoading = true;
  int storageUsage = 0;

  final NoticeLocalServer _localServer = NoticeLocalServer.instance;

  @override
  void initState() {
    super.initState();
    _loadSavedNotices();
    _loadStorageUsage();
  }

  Future<void> _loadSavedNotices() async {
    try {
      final notices = await NoticeDownloadService.getSavedNotices();
      if (mounted) {
        setState(() {
          savedNotices = notices;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showSnackBar('저장된 공지사항 로드 실패: $e');
    }
  }

  Future<void> _loadStorageUsage() async {
    try {
      final usage = await NoticeDownloadService.getStorageUsage();
      if (mounted) {
        setState(() {
          storageUsage = usage;
        });
      }
    } catch (e) {
      print('저장 공간 사용량 조회 실패: $e');
    }
  }

  Future<void> _openSavedNotice(SavedNoticeInfo notice) async {
    try {
      final String localUrl = await _localServer.startServer(notice.htmlFilePath);

      // 저장된 공지사항 열기도 히스토리에 추가
      // NavigationHistory.instance.onNavigate('NoticeWebView');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => NoticeWebViewEnhanced(
                title: '${notice.title} (저장됨)',
                url: localUrl,
                chidx: notice.chidx,
                author: notice.author,
                createDt: notice.createDt,
              ),
        ),
      );
    } catch (e) {
      _showSnackBar('저장된 공지사항 열기 실패: $e');
    }
  }

  Future<void> _deleteNotice(SavedNoticeInfo notice) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('공지사항 삭제'),
            content: Text('"${notice.title}"을(를) 삭제하시겠습니까?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await NoticeDownloadService.deleteNotice(notice.chidx);
      if (success) {
        _loadSavedNotices();
        _loadStorageUsage();
        _showSnackBar('공지사항이 삭제되었습니다.');
      } else {
        _showSnackBar('공지사항 삭제에 실패했습니다.');
      }
    }
  }

  Future<void> _deleteAllNotices() async {
    if (savedNotices.isEmpty) {
      _showSnackBar('삭제할 공지사항이 없습니다.');
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('모든 공지사항 삭제'),
            content: Text('저장된 모든 공지사항(${savedNotices.length}개)을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('모두 삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await NoticeDownloadService.deleteAllNotices();
      if (success) {
        _loadSavedNotices();
        _loadStorageUsage();
        _showSnackBar('모든 공지사항이 삭제되었습니다.');
      } else {
        _showSnackBar('공지사항 삭제에 실패했습니다.');
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '저장된 공지사항',
      actions: [
        if (savedNotices.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'deleteAll':
                  _deleteAllNotices();
                  break;
                case 'refresh':
                  _loadSavedNotices();
                  _loadStorageUsage();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(children: [Icon(Icons.refresh), SizedBox(width: 8), Text('새로고침')]),
                  ),
                  const PopupMenuItem(
                    value: 'deleteAll',
                    child: Row(
                      children: [Icon(Icons.delete_sweep, color: Colors.red), SizedBox(width: 8), Text('모두 삭제')],
                    ),
                  ),
                ],
          ),
      ],
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // 저장 공간 사용량 표시
                  if (savedNotices.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.storage, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '저장된 공지사항: ${savedNotices.length}개',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '사용 공간: ${_formatFileSize(storageUsage)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 공지사항 목록
                  Expanded(
                    child:
                        savedNotices.isEmpty
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('저장된 공지사항이 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  SizedBox(height: 8),
                                  Text(
                                    '공지사항 상세보기에서 다운로드 버튼을\n눌러 공지사항을 저장하세요',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: savedNotices.length,
                              itemBuilder: (context, index) {
                                final notice = savedNotices[index];
                                return _buildNoticeCard(notice);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildNoticeCard(SavedNoticeInfo notice) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSavedNotice(notice),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 삭제 버튼
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _deleteNotice(notice),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 작성자와 작성일
                Row(
                  children: [
                    Text(
                      '${notice.author} | ${notice.createDt}',
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 저장일
                Row(
                  children: [
                    Icon(Icons.file_download_done, size: 16, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '저장일: ${_formatDate(notice.savedAt)}',
                      style: TextStyle(fontSize: 12, color: theme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
