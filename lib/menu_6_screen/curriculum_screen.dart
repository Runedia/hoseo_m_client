import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes.dart'; // HSColors 등 포함

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

  final List<Color> cardColors = [
    HSColors.HsBlue.withOpacity(0.08),
    HSColors.HsGreen.withOpacity(0.12),
    HSColors.HsRed.withOpacity(0.10),
    HSColors.HsGrey.withOpacity(0.10),
  ];

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

        String cleanJson(String text) {
          return text.replaceAll(RegExp(r'<삭제:[^>]*>'), '').trim();
        }

        data.forEach((key, value) {
          if (value is Map && value.containsKey('text')) {
            value['text'] = cleanJson(value['text'].toString());
          }
          if (value is Map && value.containsKey('children')) {
            final children = value['children'];
            if (children is Map) {
              children.forEach((k, v) {
                if (v is String) {
                  children[k] = cleanJson(v);
                } else if (v is Map && v.containsKey('text')) {
                  v['text'] = cleanJson(v['text'].toString());
                }
              });
            }
          }
        });

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

  Widget _buildFormattedText(String text, {bool numbered = false, int? index}) {
    final List<Widget> lines = [];
    final regex = RegExp(r'(단,|다만,)[^\n.]*[\n.]');
    final matches = regex.allMatches(text);
    int lastEnd = 0;

    for (final match in matches) {
      final before = text.substring(lastEnd, match.start).trim();
      if (before.isNotEmpty) {
        lines.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            numbered && index != null ? '$index. $before' : before,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ));
      }

      final condition = match.group(0)!.trim();
      lines.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(condition, style: const TextStyle(fontSize: 15, height: 1.7)),
      ));
      lastEnd = match.end;
    }

    final after = text.substring(lastEnd).trim();
    if (after.isNotEmpty) {
      lines.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          numbered && index != null ? '$index. $after' : after,
          style: const TextStyle(fontSize: 15, height: 1.7),
        ),
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines);
  }

  Widget _buildNestedCard(dynamic value, int depth, {int? index}) {
    final color = cardColors[depth % cardColors.length];

    if (value is Map && value.containsKey('text')) {
      final String text = value['text'].toString();
      final bool numbered = depth > 0;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormattedText(text, numbered: numbered, index: index),
              if (value['children'] != null) ..._buildChildrenCards(value['children'], depth + 1),
            ],
          ),
        ),
      );
    }

    if (value is String) {
      final bool numbered = depth > 0;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildFormattedText(value, numbered: numbered, index: index),
        ),
      );
    }

    return const SizedBox();
  }

  List<Widget> _buildChildrenCards(dynamic children, int depth) {
    List<Widget> cards = [];
    if (children is Map) {
      int i = 1;
      children.forEach((_, value) {
        cards.add(_buildNestedCard(value, depth, index: i));
        i++;
      });
    } else if (children is String) {
      cards.add(_buildNestedCard(children, depth));
    }
    return cards;
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
      final children = section['children'];
      List<Widget> subCards = [];

      if (children != null) {
        subCards = _buildChildrenCards(children, 0);
      } else {
        subCards = [_buildNestedCard(sectionTitle, 0)];
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
        (curriculumData?.entries.map((e) => (e.value as Map<String, dynamic>)['text'].toString()).toSet().toList() ?? []);

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
              children: _buildCurriculumList(),
            ),
          ),
        ],
      ),
    );
  }
}
