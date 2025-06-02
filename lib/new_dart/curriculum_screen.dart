import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurriculumPage extends StatefulWidget {
  final String type;
  final String title;

  const CurriculumPage({super.key, required this.type, required this.title});

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? curriculumData;
  String selectedSection = '전체';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCurriculum();
  }

  Future<void> fetchCurriculum() async {
    try {
      final response = await http.get(
        Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=${widget.type}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        setState(() {
          curriculumData = data;
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
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<삭제:.*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(text|children):'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[{}]'), '');

    // 번호 항목 줄바꿈
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\s*\(?\s*(\d+)\s*[.:]'),
          (m) => '\n${m[1]}. ',
    );

    // 조건문(단/다만)만 줄바꿈 기준, 앞에 뭐가 있든 일단 줄바꿈
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?<!\n)([•·\-\d\s.]*)(단|다만)[,]?\s*'),
          (m) => '\n${m[0]}',
    );

    // 불필요한 기호/중복 점 제거
    cleaned = cleaned.replaceAll(RegExp(r'[•·.]{2,}'), '');
    // 문장 끝 마침표 후 줄바꿈
    cleaned = cleaned.replaceAllMapped(RegExp(r'\.\s*(?=\S)'), (_) => '.\n');
    // 중복 줄바꿈 제거
    cleaned = cleaned.replaceAll(RegExp(r'\n{2,}'), '\n');

    return cleaned.trim();
  }

  // 조건문 앞에 뭐가 있든 다 지우고 "단, 내용" "다만, 내용"만 반환
  String formatConditionLine(String line) {
    final match = RegExp(r'^(?:[•·\-\d\s.]*)?(단|다만)[,]?\s*(.*)').firstMatch(line.trim());
    if (match != null) {
      final keyword = match.group(1); // "단" 또는 "다만"
      final content = (match.group(2) ?? '').trimLeft();
      return '$keyword, $content';
    }
    return line;
  }

  List<Widget> _buildCurriculumList() {
    if (curriculumData == null) return [];

    List<Widget> widgets = [];

    final filteredEntries = curriculumData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text'].toString();
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text'].toString();

      final List<List<String>> cards = [];
      List<String> current = [];
      String? pendingNumber;

      for (final raw in (section['children'] as Map).values) {
        final cleaned = _cleanText(raw.toString());
        final lines = cleaned.split('\n');

        for (final rawLine in lines) {
          final line = rawLine.trim();
          if (line.isEmpty || RegExp(r'^[•·\-,.\s]+$').hasMatch(line)) continue;

          final isNumberOnly = RegExp(r'^\d+\.$').hasMatch(line);
          final isNumberedLine = RegExp(r'^\d+\.\s+').hasMatch(line);
          // 조건문 판별: 앞에 어떤 기호가 붙어있어도 무시
          final isCondition = RegExp(r'^(?:[•·\-\d\s.]*)?(단|다만)[,]?\s*').hasMatch(line);

          if (isNumberOnly) {
            pendingNumber = line;
            continue;
          }

          String content = pendingNumber != null ? '$pendingNumber $line' : line;
          pendingNumber = null;

          if (isCondition) {
            current.add(formatConditionLine(line));
          } else if (isNumberedLine || RegExp(r'^\d+\.').hasMatch(content)) {
            current.add(content);
          } else if (line.startsWith('• ')) {
            if (current.isNotEmpty) cards.add(List.from(current));
            current = [line];
          } else {
            if (current.isNotEmpty) cards.add(List.from(current));
            current = ['• $content'];
          }
        }
        if (current.isNotEmpty) cards.add(List.from(current));
        current.clear();
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
                Text('📘 $sectionTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...cards.where((g) => g.isNotEmpty).map((group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: group.map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
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
        (curriculumData?.entries
            .map((e) => (e.value as Map<String, dynamic>)['text'].toString())
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
              children: _buildCurriculumList(),
            ),
          ),
        ],
      ),
    );
  }
}
