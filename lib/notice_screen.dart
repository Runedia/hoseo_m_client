import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'notice_webview_page.dart'; // 👈 WebView 전용 화면

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  List<Map<String, dynamic>> notices = [];
  final List<String> categories = ['전체공지', '일반공지', '학사공지', '장학공지'];
  final Map<String, String?> typeMapping = {
    '전체공지': null,
    '일반공지': 'CTG_17082400011',
    '학사공지': 'CTG_17082400012',
    '장학공지': 'CTG_17082400013',
  };
  String selectedCategory = '전체공지';
  String searchQuery = '';
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    setState(() => isLoading = true);
    try {
      final response = await Dio().get(
        'http://rukeras.com:3000/notice/list?page=1&pageSize=30',
      );
      if (response.statusCode == 200) {
        setState(() {
          notices = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      }
    } catch (e) {
      print('공지 불러오기 오류: $e');
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> fetchNoticeDetail(int chidx) async {
    try {
      final res = await Dio().get('http://rukeras.com:3000/notice/idx/$chidx');
      return res.data;
    } catch (e) {
      print('상세 공지 불러오기 오류: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotices = notices.where((notice) {
      final title = (notice['title'] ?? '').toString();
      final matchesCategory = selectedCategory == '전체공지' ||
          notice['type'] == typeMapping[selectedCategory];
      final matchesSearch = title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
        title: const Text('공지사항'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
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
            child: ListView.builder(
              itemCount: filteredNotices.length,
              itemBuilder: (context, index) {
                final notice = filteredNotices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      notice['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notice['type'] ?? ''),
                    trailing: Text(
                      '${notice['author']} / ${notice['create_dt']?.substring(0, 10) ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
                          final fullUrl = 'http://rukeras.com:3000/$htmlPath';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoticeWebViewPage(
                                title: detail['title'] ?? '',
                                url: fullUrl,
                                userAgent:
                                'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
