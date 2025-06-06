import 'package:flutter/material.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/models/notice_models.dart';
import 'package:hoseo_m_client/services/notice_download_service.dart';
import 'package:hoseo_m_client/services/notice_local_server.dart';
import 'package:hoseo_m_client/services/notice_network_service.dart';
import 'package:hoseo_m_client/services/notice_attachment_service.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
import 'package:hoseo_m_client/menu_1_screen/widgets/notice_attachment_section.dart';
import 'package:hoseo_m_client/menu_1_screen/widgets/notice_download_indicators.dart';
import 'package:hoseo_m_client/menu_1_screen/widgets/notice_webview_controls.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class NoticeWebViewEnhanced extends StatefulWidget {
  final String title;
  final String url;
  final String? chidx;
  final String? author;
  final String? createDt;
  final bool? offline; // 오프라인 플래그 추가

  const NoticeWebViewEnhanced({
    super.key,
    required this.title,
    required this.url,
    this.chidx,
    this.author,
    this.createDt,
    this.offline = false,
  });

  @override
  State<NoticeWebViewEnhanced> createState() => _NoticeWebViewEnhancedState();
}

class _NoticeWebViewEnhancedState extends State<NoticeWebViewEnhanced> {
  // WebView 관련
  WebViewController? controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  double loadingProgress = 0.0;

  // 다운로드 관련
  bool isAutoDownloading = false;

  // 네트워크 및 첨부파일 관련
  bool isConnected = true;
  List<NoticeAttachmentItem> attachments = [];
  Map<String, double> attachmentDownloadProgress = {};
  NoticeDetailData? noticeDetailData;

  // 서비스 인스턴스
  final NoticeLocalServer _localServer = NoticeLocalServer.instance;
  final NoticeNetworkService _networkService = NoticeNetworkService.instance;

  // 스트림 구독
  StreamSubscription<bool>? _networkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 오프라인이거나 URL이 비어있으면 WebView 초기화 생략
      if (widget.offline == true || widget.url.isEmpty) {
        _handleOfflineMode();
      } else {
        _initializeWebView();
        _startAutoDownload();
      }
    });
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    _networkService.stopListening();
    super.dispose();
  }

  /// 서비스 초기화
  void _initializeServices() {
    // 네트워크 상태 감지 시작
    _networkService.startListening();

    // 네트워크 상태 변경 구독
    _networkSubscription = _networkService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() {
          isConnected = connected;
        });
      }
    });

    // 초기 네트워크 상태 설정
    isConnected = _networkService.isConnected;
  }

  /// 오프라인 모드 처리
  void _handleOfflineMode() {
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage = '오프라인 상태입니다.\n상세 내용을 보려면 인터넷에 연결해주세요.';
    });
  }

  /// 자동 다운로드 시작
  Future<void> _startAutoDownload() async {
    if (widget.chidx == null || !isConnected) return;

    setState(() {
      isAutoDownloading = true;
    });

    try {
      // 1. 공지사항 상세 정보 가져오기
      await _fetchNoticeDetails();

      // 2. 백그라운드 다운로드 시작
      _downloadNoticeInBackground();
    } catch (e) {
      print('자동 다운로드 초기화 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          isAutoDownloading = false;
        });
      }
    }
  }

  /// 공지사항 상세 정보 가져오기
  Future<void> _fetchNoticeDetails() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      final response = await dio.get(ApiConfig.getUrl('/notice/idx/${widget.chidx}'));
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> attachmentsList = data['attachments'] ?? [];

        setState(() {
          attachments = attachmentsList.map((item) => NoticeAttachmentItem.fromJson(item)).toList();
          noticeDetailData = NoticeDetailData(
            chidx: widget.chidx!,
            title: widget.title,
            content: data['content'] ?? '',
            author: widget.author ?? '',
            createDt: widget.createDt ?? '',
            assets: [],
            attachments: attachments,
          );
        });

        // 첨부파일 다운로드 상태 확인은 제거 (앱 내부 저장 없음)
      }
    } catch (e) {
      print('공지사항 상세 정보 가져오기 실패: $e');
    }
  }

  /// 백그라운드에서 공지사항 다운로드
  void _downloadNoticeInBackground() async {
    if (widget.chidx == null) return;

    try {
      await NoticeDownloadService.downloadNoticePackage(
        chidx: widget.chidx!,
        title: widget.title,
        author: widget.author ?? '',
        createDt: widget.createDt ?? '',
        onProgress: (progress) {
          // 백그라운드 다운로드이므로 진행률 표시 안함
        },
      );
    } catch (e) {
      print('백그라운드 다운로드 실패: $e');
    }
  }

  /// WebView 초기화
  Future<void> _initializeWebView() async {
    try {
      final webViewController = await NoticeWebViewControls.initializeWebView(
        widget.url,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              loadingProgress = progress;
            });
          }
        },
        onPageStarted: (url) {
          if (mounted) {
            setState(() {
              isLoading = true;
              hasError = false;
              errorMessage = null;
            });
          }
        },
        onPageFinished: (url) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (controller != null) {
            NoticeWebViewControls.adjustPageSize(controller!);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              hasError = true;
              errorMessage = 'WebView 오류: ${error.description}';
              isLoading = false;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          controller = webViewController;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'WebView 초기화 실패: $e';
          isLoading = false;
        });
      }
    }
  }

  /// 페이지 새로고침
  Future<void> _reloadPage() async {
    if (controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeWebView();
      });
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          hasError = false;
          errorMessage = null;
        });
      }
      await controller!.reload();
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = '페이지 새로고침 실패: $e';
          isLoading = false;
        });
      }
    }
  }

  /// 사용자 지정 위치로 첨부파일 다운로드
  Future<void> _downloadAttachmentToUserLocation(NoticeAttachmentItem attachment) async {
    if (!isConnected) {
      _showSnackBar('네트워크에 연결되어 있지 않습니다.');
      return;
    }

    print('다운로드 요청: ${attachment.originName}');

    setState(() {
      attachmentDownloadProgress[attachment.originName] = 0.0;
    });

    try {
      final String? localPath = await NoticeAttachmentService.downloadAttachmentToUserLocation(
        attachment: attachment,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              attachmentDownloadProgress[attachment.originName] = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          attachmentDownloadProgress.remove(attachment.originName);
        });
      }

      if (localPath != null) {
        // 다운로드 성공
        _showSnackBar('${attachment.originName} 다운로드 완료 (Downloads 폴더에 저장)');

        // 파일 열기 시도
        final opened = await NoticeAttachmentService.openFileWithDefaultApp(localPath);
        if (!opened) {
          _showSnackBar('파일을 열 수 있는 앱이 없거나 접근 권한이 없습니다.');
        }
      } else {
        // 다운로드 실패
        _showSnackBar('다운로드에 실패했습니다.');
      }
    } catch (e) {
      print('다운로드 오류: $e');
      _showSnackBar('다운로드 중 오류 발생: $e');

      if (mounted) {
        setState(() {
          attachmentDownloadProgress.remove(attachment.originName);
        });
      }
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: widget.title,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _reloadPage),
        if (!isConnected) Icon(Icons.wifi_off, color: Colors.red),
      ],
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMainContent(),
                if (isLoading && !hasError) NoticeDownloadIndicators.buildLoadingIndicator(context, loadingProgress),
                if (isAutoDownloading) NoticeDownloadIndicators.buildAutoDownloadIndicator(context),
              ],
            ),
          ),
          // 첨부파일 섹션
          NoticeAttachmentSection(
            attachments: attachments,
            downloadProgress: attachmentDownloadProgress,
            isConnected: isConnected,
            onUserDownload: _downloadAttachmentToUserLocation,
          ),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 위젯
  Widget _buildMainContent() {
    // 오프라인 모드일 때 특별한 처리
    if (widget.offline == true || widget.url.isEmpty) {
      return _buildOfflineContent();
    }

    if (hasError) {
      return NoticeWebViewControls.buildErrorPage(
        errorMessage: errorMessage ?? '알 수 없는 오류',
        onRetry: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeWebView();
          });
        },
      );
    }

    if (controller == null) {
      return NoticeWebViewControls.buildInitializingPage();
    }

    return WebViewWidget(controller: controller!);
  }

  /// 오프라인 콘텐츠 위젯
  Widget _buildOfflineContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 공지사항 기본 정보 카드
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // 작성자 및 날짜
                  if (widget.author != null || widget.createDt != null)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.author ?? ''} / ${widget.createDt?.substring(0, 10) ?? ''}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // 오프라인 안내 메시지
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '오프라인 상태입니다.\n상세 내용을 보려면 인터넷에 연결해주세요.',
                            style: TextStyle(color: Colors.orange[700], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 재시도 버튼
          ElevatedButton.icon(
            onPressed: () async {
              // 네트워크 재연결 확인 (5초 타임아웃)
              try {
                final networkService = NoticeNetworkService.instance;
                final connected = await networkService.checkConnection().timeout(const Duration(seconds: 5));

                if (connected && widget.chidx != null) {
                  // 네트워크가 연결되면 GoRouter를 사용하여 이전 페이지로 이동
                  GoRouterHistory.instance.navigateBack(context);
                } else {
                  _showSnackBar('네트워크 연결을 확인해주세요.');
                }
              } catch (e) {
                print('[DEBUG] 네트워크 확인 타임아웃: $e');
                _showSnackBar('네트워크 확인 시간이 초과되었습니다.');
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
