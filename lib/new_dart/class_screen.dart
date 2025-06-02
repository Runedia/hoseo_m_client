import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes.dart'; // HSColors를 임포트

class ClassInfoScreen extends StatefulWidget {
  final String type;
  final String title;

  const ClassInfoScreen({super.key, required this.type, required this.title});

  @override
  State<ClassInfoScreen> createState() => _ClassInfoScreenState();
}

class _ClassInfoScreenState extends State<ClassInfoScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? classData;
  String selectedSection = '전체';
  String searchQuery = '';

  // 카드 계층별 색상 배열
  final List<Color> cardColors = [
    HSColors.HsBlue.withOpacity(0.08),
    HSColors.HsGreen.withOpacity(0.12),
    HSColors.HsRed.withOpacity(0.10),
    HSColors.HsGrey.withOpacity(0.10),
  ];

  @override
  void initState() {
    super.initState();
    fetchClassInfo();
  }

  Future<void> fetchClassInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://rukeras.com:3000/eduguide/class?type=${widget.type}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        setState(() {
          classData = data;
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

  // “다만,” “단,” 등 조건부 문장은 항상 줄바꿈 처리
  String _splitConditions(String text) {
    return text
        .replaceAllMapped(RegExp(r'(다만,|단,|단 |다만 )'), (m) => '\n${m[1]}')
        .replaceAll('\n\n', '\n')
        .trim();
  }

  // 중첩 children 카드(재귀)
  Widget _buildNestedCard(dynamic value, int depth) {
    final color = cardColors[depth % cardColors.length];
    // value가 Map(중첩 children)일 경우
    if (value is Map && value.containsKey('text')) {
      final String text = _splitConditions(value['text'].toString());
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(text, style: const TextStyle(fontSize: 15, height: 1.7)),
              if (value['children'] != null)
                ..._buildChildrenCards(value['children'], depth + 1),
            ],
          ),
        ),
      );
    }
    // value가 String(텍스트)일 경우
    final cleaned = _splitConditions(value.toString());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(cleaned, style: const TextStyle(fontSize: 15, height: 1.7)),
      ),
    );
  }

  // children(Map or String) → 카드 위젯 리스트로 (재귀)
  List<Widget> _buildChildrenCards(dynamic children, int depth) {
    List<Widget> cards = [];
    if (children is Map) {
      children.forEach((_, value) {
        cards.add(_buildNestedCard(value, depth));
      });
    } else if (children is String) {
      cards.add(_buildNestedCard(children, depth));
    }
    return cards;
  }

  List<Widget> _buildClassList() {
    if (classData == null) return [];

    List<Widget> widgets = [];
    final filteredEntries = classData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text'].toString();
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text'].toString();
      final children = section['children'];
      List<Widget> subCards = [];

      if (children != null) {
        subCards = _buildChildrenCards(children, 0);
      } else {
        subCards = [
          _buildNestedCard(sectionTitle, 0),
        ];
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
                ...subCards,
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
        (classData?.entries
            .map((e) => (e.value as Map<String, dynamic>)['text'].toString())
            .toSet()
            .toList() ??
            []);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: HSColors.HsRed,
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
              children: _buildClassList(),
            ),
          ),
        ],
      ),
    );
  }
}
