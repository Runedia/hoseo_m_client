import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
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
  String searchType = 'title'; // 'title' 또는 'author'
  bool isLoading = true;

  // 페이징 관련 변수
  int currentPage = 1;
  final int pageSize = 20;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  // 디바운싱 관련
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  // 네트워크 상태
  bool isOnline = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
    // 네트워크 상태 확인 후 초기 로드
    _checkConnectivityAndLoadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // 스크롤이 끝에서 200px 전에 도달하면 다음 페이지 로드
      if (!isLoadingMore && hasMoreData && isOnline) {
        _loadMoreNotices();
      }
    }
  }

  // 네트워크 연결 상태 확인 (타임아웃 5초)
  Future<bool> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 5),
      );
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('[DEBUG] 네트워크 확인 오류 또는 타임아웃: $e');
      return false; // 타임아웃이나 오류 시 오프라인으로 간주
    }
  }

  // 네트워크 상태 확인 후 데이터 로드
  Future<void> _checkConnectivityAndLoadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    isOnline = await _checkConnectivity();
    print('[DEBUG] 네트워크 상태: ${isOnline ? "온라인" : "오프라인"}');

    if (isOnline) {
      await _loadInitialNotices();
    } else {
      await _loadOfflineData();
    }
  }

  // 오프라인 데이터 로드
  Future<void> _loadOfflineData() async {
    try {
      final dbManager = DatabaseManager.instance;
      final categoryType = typeMapping[selectedCategory];

      // 기본 캐시 키 생성 (카테고리별)
      String cacheKey = 'notice_${categoryType ?? 'all'}';

      final cachedData = await dbManager.getMenuListData(cacheKey, 1);

      if (cachedData != null && cachedData['notices'] != null) {
        final List<Map<String, dynamic>> cachedNotices = List<Map<String, dynamic>>.from(cachedData['notices']);

        setState(() {
          notices = cachedNotices;
          isLoading = false;
          hasMoreData = false; // 오프라인에서는 페이징 비활성화
          errorMessage = null;
        });
        print('[DEBUG] 오프라인 데이터 로드 완료: ${notices.length}개');
      } else {
        setState(() {
          notices = [];
          isLoading = false;
          hasMoreData = false;
          errorMessage = '저장된 공지사항이 없습니다.\n인터넷에 연결 후 다시 시도해주세요.';
        });
        print('[DEBUG] 저장된 오프라인 데이터 없음');
      }
    } catch (e) {
      print('[DEBUG] 오프라인 데이터 로드 오류: $e');
      setState(() {
        notices = [];
        isLoading = false;
        hasMoreData = false;
        errorMessage = '데이터를 불러올 수 없습니다.';
      });
    }
  }

  Future<void> _loadInitialNotices() async {
    setState(() {
      currentPage = 1;
      notices.clear();
      hasMoreData = true;
      errorMessage = null;
    });
    fetchNoticesWithSearch(categoryType: typeMapping[selectedCategory], isInitialLoad: true);
  }

  void _loadMoreNotices() {
    if (!hasMoreData || isLoadingMore) return;
    setState(() {
      currentPage++;
    });
    fetchNoticesWithSearch(
      categoryType: typeMapping[selectedCategory],
      searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      searchType: searchType,
      isLoadMore: true,
    );
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          searchQuery = value;
          currentPage = 1;
          notices.clear();
          hasMoreData = true;
          errorMessage = null;
        });

        if (isOnline) {
          fetchNoticesWithSearch(
            categoryType: typeMapping[selectedCategory],
            searchQuery: value.isNotEmpty ? value : null,
            searchType: searchType,
            isInitialLoad: true,
          );
        } else {
          // 오프라인에서는 로컬 데이터에서 필터링
          _filterOfflineData(value);
        }
      }
    });
  }

  // 오프라인 데이터 필터링
  Future<void> _filterOfflineData(String searchQuery) async {
    try {
      final dbManager = DatabaseManager.instance;
      final categoryType = typeMapping[selectedCategory];
      String cacheKey = 'notice_${categoryType ?? 'all'}';

      final cachedData = await dbManager.getMenuListData(cacheKey, 1);

      if (cachedData != null && cachedData['notices'] != null) {
        List<Map<String, dynamic>> allNotices = List<Map<String, dynamic>>.from(cachedData['notices']);

        if (searchQuery.isNotEmpty) {
          allNotices =
              allNotices.where((notice) {
                final title = (notice['title'] ?? '').toString().toLowerCase();
                final author = (notice['author'] ?? '').toString().toLowerCase();
                final query = searchQuery.toLowerCase();

                if (searchType == 'title') {
                  return title.contains(query);
                } else {
                  return author.contains(query);
                }
              }).toList();
        }

        setState(() {
          notices = allNotices;
          isLoading = false;
        });
      }
    } catch (e) {
      print('[DEBUG] 오프라인 검색 오류: $e');
    }
  }

  Future<void> fetchNoticesWithSearch({
    String? categoryType,
    String? searchQuery,
    String? searchType,
    bool isInitialLoad = false,
    bool isLoadMore = false,
  }) async {
    if (isInitialLoad) {
      setState(() => isLoading = true);
    } else if (isLoadMore) {
      setState(() => isLoadingMore = true);
    }

    try {
      // 타임아웃 설정 (5초로 단축)
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      String url;

      // 검색어가 있으면 검색 API 사용, 없으면 일반 목록 API 사용
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url = ApiConfig.getUrl('/notice/search?page=$currentPage&pageSize=$pageSize');
        if (categoryType != null && categoryType.isNotEmpty) {
          url += '&type=$categoryType';
        }
        if (searchType == 'title') {
          url += '&title=${Uri.encodeComponent(searchQuery)}';
        } else if (searchType == 'author') {
          url += '&author=${Uri.encodeComponent(searchQuery)}';
        }
      } else {
        url = ApiConfig.getUrl('/notice/list?page=$currentPage&pageSize=$pageSize');
        if (categoryType != null && categoryType.isNotEmpty) {
          url += '&type=$categoryType';
        }
      }

      print('[DEBUG] 공지사항 요청 URL: $url');
      print('[DEBUG] 현재 페이지: $currentPage');

      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final responseData = List<Map<String, dynamic>>.from(response.data);
        print('[DEBUG] 받은 공지사항 수: ${responseData.length}');

        // 데이터베이스에 저장 (첫 페이지만)
        if (isInitialLoad && searchQuery == null) {
          await _saveNoticeDataToCache(categoryType, responseData);
        }

        if (mounted) {
          setState(() {
            if (isInitialLoad) {
              notices = responseData;
            } else {
              notices.addAll(responseData);
            }

            // 받은 데이터가 pageSize보다 적으면 더 이상 데이터가 없음
            if (responseData.length < pageSize) {
              hasMoreData = false;
            }

            isLoading = false;
            isLoadingMore = false;
            errorMessage = null;
          });
          print('[DEBUG] UI 업데이트 완료 - 총 공지사항: ${notices.length}');
        }
      }
    } catch (e) {
      print('[DEBUG] 공지 불러오기 오류: $e');

      // 타임아웃이나 네트워크 오류 발생 시 오프라인 모드로 전환
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          print('[DEBUG] 네트워크 오류 감지, 오프라인 모드로 전환');
          setState(() => isOnline = false);

          if (isInitialLoad) {
            await _loadOfflineData();
            return;
          }
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
          if (isInitialLoad) {
            errorMessage = '서버에 연결할 수 없습니다.\n인터넷 연결을 확인해주세요.';
          }
        });
      }
    }
  }

  // 공지사항 데이터를 캐시에 저장
  Future<void> _saveNoticeDataToCache(String? categoryType, List<Map<String, dynamic>> noticeData) async {
    try {
      final dbManager = DatabaseManager.instance;
      String cacheKey = 'notice_${categoryType ?? 'all'}';

      final cacheData = {
        'notices': noticeData,
        'category': categoryType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await dbManager.saveMenuListData(cacheKey, 1, cacheData);
      print('[DEBUG] 공지사항 데이터 캐시 저장 완료: ${noticeData.length}개');
    } catch (e) {
      print('[DEBUG] 캐시 저장 오류: $e');
    }
  }

  // 공지사항 상세 조회
  Future<Map<String, dynamic>?> fetchNoticeDetail(int chidx) async {
    try {
      // 온라인일 때만 서버에서 가져오기
      if (isOnline) {
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);
        dio.options.receiveTimeout = const Duration(seconds: 5);

        final res = await dio.get(ApiConfig.getUrl('/notice/idx/$chidx'));

        // 상세 데이터도 캐시에 저장
        await _saveNoticeDetailToCache(chidx, res.data);

        return res.data;
      } else {
        // 오프라인일 때는 캐시에서 가져오기
        return await _getNoticeDetailFromCache(chidx);
      }
    } catch (e) {
      print('상세 공지 불러오기 오류: $e');
      // 온라인에서 실패했을 때 캐시에서 시도
      return await _getNoticeDetailFromCache(chidx);
    }
  }

  // 오프라인 카테고리별 데이터 로드
  Future<void> _loadOfflineDataForCategory(String category) async {
    setState(() => isLoading = true);

    try {
      final dbManager = DatabaseManager.instance;
      final categoryType = typeMapping[category];
      String cacheKey = 'notice_${categoryType ?? 'all'}';

      final cachedData = await dbManager.getMenuListData(cacheKey, 1);

      if (cachedData != null && cachedData['notices'] != null) {
        final List<Map<String, dynamic>> cachedNotices = List<Map<String, dynamic>>.from(cachedData['notices']);

        setState(() {
          notices = cachedNotices;
          isLoading = false;
          hasMoreData = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          notices = [];
          isLoading = false;
          hasMoreData = false;
          errorMessage = '저장된 ${category} 공지사항이 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        notices = [];
        isLoading = false;
        hasMoreData = false;
        errorMessage = '데이터를 불러올 수 없습니다.';
      });
    }
  }

  // 공지사항 상세 데이터 캐시 저장
  Future<void> _saveNoticeDetailToCache(int chidx, Map<String, dynamic> detailData) async {
    try {
      final dbManager = DatabaseManager.instance;
      await dbManager.saveMenuDetailData('notice', chidx.toString(), detailData);
    } catch (e) {
      print('[DEBUG] 상세 데이터 캐시 저장 오류: $e');
    }
  }

  // 공지사항 상세 데이터 캐시에서 가져오기
  Future<Map<String, dynamic>?> _getNoticeDetailFromCache(int chidx) async {
    try {
      final dbManager = DatabaseManager.instance;
      return await dbManager.getMenuDetailData('notice', chidx.toString());
    } catch (e) {
      print('[DEBUG] 상세 데이터 캐시 조회 오류: $e');
      return null;
    }
  }

  // 기본 정보로 상세 페이지 이동
  void _navigateWithBasicInfo(Map<String, dynamic> notice, int chidx) {
    // 오프라인이거나 상세 정보가 없을 때는 기본 정보만으로 상세 페이지 이동
    // 빈 URL을 전달하여 상세 페이지에서 오프라인 메시지 표시
    final routeUrl =
        '/notice/detail?title=${Uri.encodeComponent(notice['title'] ?? '')}&url=${Uri.encodeComponent('')}&chidx=${Uri.encodeComponent(chidx.toString())}&author=${Uri.encodeComponent(notice['author'] ?? '')}&createDt=${Uri.encodeComponent(notice['create_dt'] ?? '')}&offline=true';

    GoRouterHistory.instance.pushWithHistory(context, routeUrl);
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
                                      setState(() {
                                        selectedCategory = cat;
                                        currentPage = 1;
                                        notices.clear();
                                        hasMoreData = true;
                                        errorMessage = null;
                                      });

                                      if (isOnline) {
                                        // 온라인: 서버에서 데이터 가져오기
                                        fetchNoticesWithSearch(
                                          categoryType: typeMapping[cat],
                                          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
                                          searchType: searchType,
                                          isInitialLoad: true,
                                        );
                                      } else {
                                        // 오프라인: 로컬 데이터 로드
                                        _loadOfflineDataForCategory(cat);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    // 검색 타입 선택
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: Row(
                        children: [
                          Text(
                            '검색 기준: ',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('제목'),
                            selected: searchType == 'title',
                            onSelected: (_) {
                              setState(() => searchType = 'title');
                              if (searchQuery.isNotEmpty) {
                                setState(() {
                                  currentPage = 1;
                                  notices.clear();
                                  hasMoreData = true;
                                  errorMessage = null;
                                });

                                if (isOnline) {
                                  fetchNoticesWithSearch(
                                    categoryType: typeMapping[selectedCategory],
                                    searchQuery: searchQuery,
                                    searchType: searchType,
                                    isInitialLoad: true,
                                  );
                                } else {
                                  _filterOfflineData(searchQuery);
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('작성자'),
                            selected: searchType == 'author',
                            onSelected: (_) {
                              setState(() => searchType = 'author');
                              if (searchQuery.isNotEmpty) {
                                setState(() {
                                  currentPage = 1;
                                  notices.clear();
                                  hasMoreData = true;
                                  errorMessage = null;
                                });

                                if (isOnline) {
                                  fetchNoticesWithSearch(
                                    categoryType: typeMapping[selectedCategory],
                                    searchQuery: searchQuery,
                                    searchType: searchType,
                                    isInitialLoad: true,
                                  );
                                } else {
                                  _filterOfflineData(searchQuery);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // 검색창
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: searchType == 'title' ? '제목으로 검색' : '작성자로 검색',
                          border: const OutlineInputBorder(),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child:
                            notices.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        errorMessage != null ? Icons.error_outline : Icons.article_outlined,
                                        size: 64,
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        errorMessage ?? (searchQuery.isNotEmpty ? '검색 결과가 없습니다.' : '공지사항이 없습니다.'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (errorMessage != null && !isOnline) ...[
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () => _checkConnectivityAndLoadData(),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('다시 시도'),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: notices.length + (isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == notices.length) {
                                      // 로딩 인디케이터
                                      return const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    final notice = notices[index];
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

            // 상세 데이터 시도
            final detail = await fetchNoticeDetail(chidx);

            if (detail != null) {
              // 서버에서 가져온 상세 데이터가 있는 경우
              final htmlPath = detail['content'];
              if (htmlPath != null && htmlPath.isNotEmpty) {
                final fullUrl = ApiConfig.getFileUrl(htmlPath);

                final routeUrl =
                    '/notice/detail?title=${Uri.encodeComponent(detail['title'] ?? notice['title'] ?? '')}&url=${Uri.encodeComponent(fullUrl)}&chidx=${Uri.encodeComponent(chidx.toString())}&author=${Uri.encodeComponent(detail['author'] ?? notice['author'] ?? '')}&createDt=${Uri.encodeComponent(detail['create_dt'] ?? notice['create_dt'] ?? '')}';

                GoRouterHistory.instance.pushWithHistory(context, routeUrl);
              } else {
                // 상세 데이터는 있지만 content가 없는 경우 - 기본 정보로 이동
                _navigateWithBasicInfo(notice, chidx);
              }
            } else {
              // 상세 데이터를 가져올 수 없는 경우 (오프라인 등) - 기본 정보로 이동
              _navigateWithBasicInfo(notice, chidx);
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
                    const SizedBox(width: 12), // 카테고리와 작성자 사이 갭
                    // 작성자 및 날짜
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$author / $createDate',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color ?? Colors.grey[600],
                              ),
                            ),
                          ),
                          if (!isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_off, size: 12, color: Colors.orange[700]),
                                  const SizedBox(width: 2),
                                  Text(
                                    '오프라인',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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
