import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';

class NoticeScreenNew extends StatefulWidget {
  const NoticeScreenNew({super.key});

  @override
  State<NoticeScreenNew> createState() => _NoticeScreenNewState();
}

class _NoticeScreenNewState extends State<NoticeScreenNew> {
  List<Map<String, dynamic>> notices = [];
  final List<String> categories = ['일반공지', '학사공지', '장학공지', '취업공지'];
  final Map<String, String?> typeMapping = {
    '일반공지': 'CTG_17082400011',
    '학사공지': 'CTG_17082400012',
    '장학공지': 'CTG_17082400013',
    '취업공지': 'CTG_20120400086',
  };
  String selectedCategory = '일반공지';
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 초기 로드 시 선택된 카테고리로 공지사항 가져오기
    fetchNotices(categoryType: typeMapping[selectedCategory]);
  }

  Future<void> fetchNotices({String? categoryType}) async {
    // if (!mounted) return; // 위젯이 dispose된 경우 조기 반환

    setState(() => isLoading = true);
    try {
      // 서버에서 카테고리별 필터링 지원
      String url = ApiConfig.getUrl('/notice/list?page=1&pageSize=30');
      if (categoryType != null && categoryType.isNotEmpty) {
        url += '&type=$categoryType';
      }

      print('[DEBUG] 공지사항 요청 URL: $url');
      print('[DEBUG] 선택된 카테고리: $selectedCategory');
      print('[DEBUG] 카테고리 코드: $categoryType');

      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final responseData = List<Map<String, dynamic>>.from(response.data);
        print('[DEBUG] 받은 공지사항 수: ${responseData.length}');

        // 받은 데이터의 카테고리 확인
        if (responseData.isNotEmpty) {
          final categories = responseData.map((notice) => notice['type']).toSet();
          print('[DEBUG] 받은 데이터의 카테고리들: $categories');

          // 첫 번째 공지사항 샘플 출력
          print('[DEBUG] 첫 번째 공지사항 샘플:');
          print('  - 제목: ${responseData[0]['title']}');
          print('  - 카테고리: ${responseData[0]['type']}');
          print('  - 작성자: ${responseData[0]['author']}');
        } else {
          print('[DEBUG] 빈 데이터 - 해당 카테고리에 공지사항이 없음');
        }

        // mounted 체크 후 setState 호출
        if (mounted) {
          setState(() {
            notices = responseData;
            isLoading = false;
          });
          print('[DEBUG] UI 업데이트 완료 - 서버 사이드 필터링 사용');
        }
      }
    } catch (e) {
      print('[DEBUG] 공지 불러오기 오류: $e');
      // mounted 체크 후 setState 호출
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> fetchNoticeDetail(int chidx) async {
    try {
      final res = await Dio().get(ApiConfig.getUrl('/notice/idx/$chidx'));
      return res.data;
    } catch (e) {
      print('상세 공지 불러오기 오류: $e');
      return null;
    }
  }

  String getCategoryDisplayName(String? type) {
    switch (type) {
      case 'CTG_17082400011':
        return '일반공지';
      case 'CTG_17082400012':
        return '학사공지';
      case 'CTG_17082400013':
        return '장학공지';
      case 'CTG_20120400086':
        return '취업공지';
      default:
        return '공지사항';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 서버에서 카테고리별 필터링을 지원하므로 검색어만 클라이언트에서 필터링
    final filteredNotices =
        notices.where((notice) {
          final title = (notice['title'] ?? '').toString();
          final matchesSearch = title.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesSearch;
        }).toList();

    return CommonScaffold(
      title: '공지사항',
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children:
                              categories.map((cat) {
                                final isSelected = selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      print('[DEBUG] 카테고리 변경: $cat');
                                      setState(() => selectedCategory = cat);
                                      // 카테고리 변경 시 해당 카테고리의 공지사항 다시 가져오기
                                      fetchNotices(categoryType: typeMapping[cat]);
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: '제목으로 검색',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredNotices.length,
                          itemBuilder: (context, index) {
                            final notice = filteredNotices[index];
                            return _buildNoticeCard(context, notice);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, Map<String, dynamic> notice) {
    final title = notice['title'] ?? '';
    final author = notice['author'] ?? '';
    final createDate = notice['create_dt']?.substring(0, 10) ?? '';
    final categoryName = getCategoryDisplayName(notice['type']);

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // 테마에 맞는 카드 배경색 사용
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
          onTap: () async {
            final chidxRaw = notice['chidx'];
            final chidx = chidxRaw is int ? chidxRaw : int.tryParse(chidxRaw.toString());

            if (chidx == null) {
              print('⚠️ chidx 변환 실패: $chidxRaw');
              return;
            }

            final detail = await fetchNoticeDetail(chidx);
            if (detail != null) {
              final htmlPath = detail['content'];
              if (htmlPath != null && htmlPath.isNotEmpty) {
                final fullUrl = ApiConfig.getFileUrl(htmlPath);

                // GoRouterHistory를 사용하여 공지사항 상세보기로 이동
                final routeUrl =
                    '/notice/detail?title=${Uri.encodeComponent(detail['title'] ?? '')}&url=${Uri.encodeComponent(fullUrl)}&chidx=${Uri.encodeComponent(chidx.toString())}&author=${Uri.encodeComponent(notice['author'] ?? '')}&createDt=${Uri.encodeComponent(notice['create_dt'] ?? '')}';

                GoRouterHistory.instance.pushWithHistory(context, routeUrl);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.primaryColor.withOpacity(0.1),
          highlightColor: theme.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color ?? theme.primaryColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // 카테고리와 날짜 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 카테고리 태그
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // 작성자 및 날짜
                    Text(
                      '$author / $createDate',
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color ?? Colors.grey[600]),
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
