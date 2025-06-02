import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordInfoScreen extends StatefulWidget {
  final String type;
  final String title;
  const RecordInfoScreen({super.key, required this.type, required this.title});

  @override
  State<RecordInfoScreen> createState() => _RecordInfoScreenState();
}

class _RecordInfoScreenState extends State<RecordInfoScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? recordData;
  String selectedSection = '전체';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchRecordInfo();
  }

  Future<void> fetchRecordInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://rukeras.com:3000/eduguide/record?type=${widget.type}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        setState(() {
          recordData = data;
          isLoading = false;
        });
      } else {
        throw Exception('서버 오류');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _cleanText(String input) {
    String cleaned = input;

    // 1. 불필요 키워드/중괄호 제거
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<삭제:.*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(text|children):'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[{}]'), '');
    cleaned = cleaned.trim();

    // 2. 콤마 뒤 번호(1:, 2:, ...)는 무조건 줄바꿈
    cleaned = cleaned.replaceAll(RegExp(r',\s*(\d+):'), '\n\$1:');

    // 3. 여러 줄로 나누기
    final lines = cleaned.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);

    List<String> result = [];
    for (var line in lines) {
      // 맨 앞 불필요한 점/기호/공백 제거
      String l = line.replaceFirst(RegExp(r'^[•·\-\s.]+'), '');

      // 4. "1: 신병 ..." → "- 1. 신병 ..."으로 변환
      if (RegExp(r'^(\d+):').hasMatch(l)) {
        l = l.replaceFirstMapped(RegExp(r'^(\d+):\s*'), (m) => '- ${m.group(1)}. ');
        result.add(l);
        continue;
      }

      // 5. 조건문/때. 줄은 - 붙이기
      if (RegExp(r'^(단,|다만,)', caseSensitive: false).hasMatch(l) || l.endsWith('때.')) {
        result.add('- $l');
        continue;
      }

      // 6. 그 외는 항상 • 붙이기 (동일한 크기/굵기)
      result.add('• $l');
    }

    return result.join('\n');
  }





  List<Widget> _buildRecordList() {
    if (recordData == null) return [];

    List<Widget> widgets = [];

    final filteredEntries = recordData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text']?.toString() ?? '';
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text']?.toString() ?? '';

      final List<List<String>> cards = [];
      List<String> current = [];

      // "children"의 값(value)만 사용
      final children = section['children'] as Map?;
      if (children != null) {
        for (final raw in children.values) {
          final cleaned = _cleanText(raw.toString());
          final lines = cleaned.split('\n');

          for (final rawLine in lines) {
            final line = rawLine.trim();
            if (line.isEmpty) continue;
            current.add(line);
          }
          if (current.isNotEmpty) cards.add(List.from(current));
          current.clear();
        }
      }

      widgets.add(
        Card(
          color: const Color(0xFFF9F4FD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📄 $sectionTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...cards.where((g) => g.isNotEmpty).map((group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: group.map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15,           // 본문 크기
                          fontWeight: FontWeight.normal, // 본문/점 모두 일반 굵기
                          height: 1.6,
                        ),
                      ),
                    )).toList(),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final sections = ['전체'] +
        (recordData?.entries
            .map((e) => (e.value as Map<String, dynamic>)['text']?.toString() ?? '')
            .toSet()
            .toList() ??
            []);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('❌ 오류 발생: $error'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sections.map((sec) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(sec),
                      selected: selectedSection == sec,
                      onSelected: (_) => setState(() => selectedSection = sec),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '검색',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _buildRecordList(),
            ),
          ),
        ],
      ),
    );
  }
}
