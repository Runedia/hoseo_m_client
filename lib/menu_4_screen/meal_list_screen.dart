import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/app_state.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

class MealListScreen extends StatefulWidget {
  final String cafeteriaName;
  final String action;

  const MealListScreen({super.key, required this.cafeteriaName, required this.action});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<Map<String, dynamic>> noticeList = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  final int pageSize = 8;

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  Future<void> fetchMenus({int page = 1}) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 네트워크 연결 확인
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // 인터넷 연결이 있으면 API 호출
        await _fetchFromAPI(page);
      } else {
        // 인터넷 연결이 없으면 로컬 데이터 사용
        await _loadLocalData(page);
      }
    } catch (e) {
      // API 호출 실패 시 로컬 데이터로 폴백
      print('fetchMenus 오류: $e');
      await _loadLocalData(page);
    }
  }

  Future<void> _fetchFromAPI(int page) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl('/menu/list2?page=$page&pageSize=$pageSize&action=${widget.action}'));
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List data = body['data'] ?? [];

        // DB에 데이터 저장
        await DatabaseManager.instance.saveMenuListData(widget.action, page, body);

        setState(() {
          noticeList = List<Map<String, dynamic>>.from(data);
          currentPage = body['currentPage'] ?? 1;
          totalPages = body['totalPages'] ?? 1;
          totalCount = body['totalCount'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception('서버 오류: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('API 호출 실패: $e');
    }
  }

  Future<void> _loadLocalData(int page) async {
    try {
      final localData = await DatabaseManager.instance.getMenuListData(widget.action, page);

      if (localData != null) {
        final List data = localData['data'] ?? [];
        setState(() {
          noticeList = List<Map<String, dynamic>>.from(data);
          currentPage = localData['currentPage'] ?? 1;
          totalPages = localData['totalPages'] ?? 1;
          totalCount = localData['totalCount'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          noticeList = [];
          currentPage = 1;
          totalPages = 1;
          totalCount = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('로컬 데이터 로드 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDetail(String chidx) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator(), SizedBox(width: 20), Text('로딩 중...')],
          ),
        );
      },
    );

    try {
      // 1. 인터넷 연결 상태 확인
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // 1. 인터넷이 연결되어있을 경우
        try {
          // 2. REST API 연결
          final url = Uri.parse(ApiConfig.getUrl('/menu/idx/$chidx/${widget.action}'));
          final res = await http.get(url);

          if (res.statusCode == 200) {
            // 3. 데이터를 수신 받은 경우 해당 데이터 사용
            final detail = json.decode(res.body);

            // 4. DB 업데이트 (덮어쓰기)
            await DatabaseManager.instance.saveMenuDetailData(widget.action, chidx, detail);

            // 로딩 대화상자 닫기
            if (mounted) context.pop();
            return _navigateToDetail(detail);
          } else {
            // 서버 오류
            throw Exception('서버 오류: ${res.statusCode}');
          }
        } catch (e) {
          // 5. 데이터를 수신 실패 한 경우 (ERROR 발생 시)
          print('API 호출 실패: $e');

          // 6. DB에서 데이터 불러오기 후 SnackBar로 오프라인 데이터 입니다. 안내
          final localDetail = await DatabaseManager.instance.getMenuDetailData(widget.action, chidx);

          if (localDetail != null) {
            // 로딩 대화상자 닫기
            if (mounted) context.pop();

            // 오프라인 데이터 사용 안내
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('오프라인 데이터입니다.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }

            return _navigateToDetail(localDetail);
          } else {
            // DB에도 데이터가 없는 경우
            throw Exception('사용 가능한 데이터가 없습니다.');
          }
        }
      } else {
        // 7. 인터넷이 연결되어있지 않을 경우
        // 8. DB 내용 사용
        final localDetail = await DatabaseManager.instance.getMenuDetailData(widget.action, chidx);

        if (localDetail != null) {
          // 로딩 대화상자 닫기
          if (mounted) context.pop();
          return _navigateToDetail(localDetail);
        } else {
          // 9. DB에도 데이터가 없을 경우 SnackBar로 메시지 표시
          throw Exception('인터넷 연결이 없고 저장된 데이터도 없습니다.');
        }
      }
    } catch (e) {
      // 로딩 대화상자 닫기
      if (mounted) context.pop();

      // 오류 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터를 불러올 수 없습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToDetail(Map<String, dynamic> detail) async {
    final List<dynamic>? attachmentsRaw = detail['attachments'];
    final List<dynamic>? assetsRaw = detail['assets'];
    final List<dynamic> effectiveAttachments =
        (attachmentsRaw == null || attachmentsRaw.isEmpty) ? (assetsRaw ?? []) : attachmentsRaw;

    final imageUrls =
        effectiveAttachments
            .where((att) {
              final fileName = (att['fileName'] ?? att['file_name'] ?? '').toString().toLowerCase();
              return fileName.endsWith('.png') || fileName.endsWith('.jpg') || fileName.endsWith('.jpeg');
            })
            .map((att) => ApiConfig.getFileUrl(att['localPath']))
            .toList();

    // AppState에 meal detail 정보 저장
    AppState.setCurrentMealDetail(detail, imageUrls.cast<String>(), widget.cafeteriaName);

    // go_router를 사용한 네비게이션
    GoRouterHistory.instance.pushWithHistory(context, '/meal/detail?cafeteriaName=${widget.cafeteriaName}');
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '교내식당 식단표',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _titleButton(widget.cafeteriaName),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          noticeList.isEmpty
                              ? const Center(
                                child: Text('데이터가 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              )
                              : SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                                  columnWidths: const {
                                    0: FixedColumnWidth(50), // 번호 열 약간 넓게
                                    1: FlexColumnWidth(3), // 제목 열 더 넓게
                                    2: FixedColumnWidth(60), // 작성자 열 약간 좁게
                                    3: FixedColumnWidth(85), // 등록일자 열 유지
                                  },
                                  children: [
                                    _headerRow(),
                                    ...noticeList.asMap().entries.map((entry) {
                                      final notice = entry.value;
                                      return _buildTableRow(notice, entry.key);
                                    }),
                                  ],
                                ),
                              ),
                    ),
                    // 미니멀 도트 스타일 페이징
                    if (totalCount > 0) _buildMinimalDotPagination(),
                  ],
                ),
      ),
    );
  }

  TableRow _headerRow() => TableRow(
    decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    children: [_headerCell('번호'), _headerCell('제목'), _headerCell('작성자'), _headerCell('등록일자')],
  );

  Widget _headerCell(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );

  Widget _cell(String text, {bool centerAlign = true, bool isClickable = false}) => Container(
    constraints: const BoxConstraints(minHeight: 48), // TableRow와 동일한 최소 높이
    color: Colors.transparent, // 투명하게 설정하여 TableRow 배경색 상속
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isClickable ? Theme.of(context).primaryColor : Colors.black87,
            fontWeight: isClickable ? FontWeight.w500 : FontWeight.normal,
          ),
          textAlign: centerAlign ? TextAlign.center : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );

  TableRow _buildTableRow(Map<String, dynamic> notice, int index) {
    final title = notice['title'] ?? '';
    final author = notice['author'] ?? '';
    final createDate = notice['create_dt']?.substring(0, 10) ?? '';
    final idx = notice['idx']?.toString() ?? '';

    return TableRow(
      decoration: BoxDecoration(color: index.isEven ? Colors.grey[300] : Colors.white),
      children: [
        _cell(idx),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => fetchDetail(notice['chidx']),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 48),
              color: Colors.transparent, // TableRow 배경색 상속
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
        _cell(author),
        _cell(createDate),
      ],
    );
  }

  Widget _titleButton(String title) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    onPressed: () {},
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
  );

  // 미니멀 도트 스타일 페이징 위젯
  Widget _buildMinimalDotPagination() {
    print('[DEBUG] Building pagination: currentPage=$currentPage, totalPages=$totalPages, totalCount=$totalCount');

    return Container(
      child:
          totalPages > 1
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이전 버튼
                  _buildCircleButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: currentPage > 1 ? () => fetchMenus(page: currentPage - 1) : null,
                    isEnabled: currentPage > 1,
                  ),
                  const SizedBox(width: 12),
                  // 페이지 정보 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$currentPage / $totalPages',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 다음 버튼
                  _buildCircleButton(
                    icon: Icons.keyboard_arrow_right,
                    onPressed: currentPage < totalPages ? () => fetchMenus(page: currentPage + 1) : null,
                    isEnabled: currentPage < totalPages,
                  ),
                ],
              )
              : Text(
                '전체 $totalCount건',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
    );
  }

  // 원형 네비게이션 버튼
  Widget _buildCircleButton({required IconData icon, required VoidCallback? onPressed, required bool isEnabled}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(icon, size: 18, color: isEnabled ? Colors.white : Colors.grey[500]),
        ),
      ),
    );
  }

  // 개별 도트 위젯
  Widget _buildDot(int pageNumber) {
    final bool isCurrentPage = pageNumber == currentPage;

    return GestureDetector(
      onTap: () => fetchMenus(page: pageNumber),
      child: Container(
        width: isCurrentPage ? 20 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: isCurrentPage ? Theme.of(context).primaryColor : Colors.grey[400],
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
