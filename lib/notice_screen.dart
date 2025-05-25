import 'package:flutter/material.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final List<Map<String, String>> notices = [
    {
      'title': '2025학년도 여름학기 개강 안내',
      'author': '교무처',
      'date': '2025-05-25',
      'content': '여름학기는 6월 10일 개강 예정입니다. 자세한 사항은 홈페이지 참고 바랍니다.'
    },
    {
      'title': '학사일정 변경 안내',
      'author': '학사팀',
      'date': '2025-05-23',
      'content': '내용 내용 내용 '
    },
    {
      'title': 'LMS 서버 점검',
      'author': '정보전산원',
      'date': '2025-05-19',
      'content': '5월 25일(금) 00시~06시까지 시스템 점검이 예정되어 있습니다.'
    },
  ];

  final List<String> categories = ['전체공지', '학사공지', '장학공지', '일반공지'];
  String selectedCategory = '전체공지';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredNotices = notices.where((notice) {
      final matchesCategory = selectedCategory == '전체공지' || notice['author']!.contains(selectedCategory.replaceAll('공지', ''));
      final matchesSearch = notice['title']!.contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        centerTitle: true,
      ),
      body: Column(
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
                    onSelected: (_) {
                      setState(() => selectedCategory = cat);
                    },
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
                    title: Text(notice['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notice['content'] ?? ''),
                    trailing: Text(
                      '${notice['author']} / ${notice['date']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.7,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notice['title'] ?? '',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '${notice['author']} / ${notice['date']}',
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      notice['content'] ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    child: const Text("닫기"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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
