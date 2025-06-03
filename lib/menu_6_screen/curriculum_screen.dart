import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/themes/themes.dart';
import 'package:http/http.dart' as http;

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
    HSColors.hsBlue.withOpacity(0.08),
    HSColors.hsGreen.withOpacity(0.12),
    HSColors.hsRed.withOpacity(0.10),
    HSColors.hsGrey.withOpacity(0.10),
  ];

  @override
  void initState() {
    super.initState();
    fetchCurriculum();
  }

  Future<void> fetchCurriculum() async {
    try {
      final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=${widget.type}'));
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

  String _cleanText(String input) {
    String cleaned = input;
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<삭제:.*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(text|children):'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[{}]'), '');
    cleaned = cleaned.trim();
    return cleaned;
  }

  Widget _buildFormattedText(String text, {bool numbered = false, int? index}) {
    final List<Widget> lines = [];
    final regex = RegExp(r'(단,|다만,)[^\n.]*[\n.]');
    final matches = regex.allMatches(text);
    int lastEnd = 0;

    for (final match in matches) {
      final before = text.substring(lastEnd, match.start).trim();
      if (before.isNotEmpty) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              numbered && index != null ? '$index. $before' : before,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ),
        );
      }

      final condition = match.group(0)!.trim();
      lines.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(condition, style: const TextStyle(fontSize: 15, height: 1.7)),
        ),
      );
      lastEnd = match.end;
    }

    final after = text.substring(lastEnd).trim();
    if (after.isNotEmpty) {
      lines.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            numbered && index != null ? '$index. $after' : after,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines);
  }

  // 박스 카드 내부(중첩) 리스트: 번호 붙여서 출력
  Widget _buildNumberedBox(List<String> lines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < lines.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${i + 1}. ${lines[i]}', style: const TextStyle(fontSize: 15, height: 1.6)),
            ),
        ],
      ),
    );
  }

  // 하위 항목 처리: children 안에 children이 있으면 박스 카드(번호), 없으면 일반 텍스트(•)
  List<Widget> _buildChildrenCards(dynamic children) {
    List<Widget> widgets = [];
    if (children is Map) {
      children.forEach((_, value) {
        if (value is Map && value.containsKey('children')) {
          // 상위 text(설명) •로 출력
          final parentText = _cleanText(value['text']?.toString() ?? '');
          if (parentText.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $parentText', style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
            );
          }
          // 하위 children만 박스 카드(번호 붙임)
          final subLines = <String>[];
          (value['children'] as Map).forEach((_, subVal) {
            final line = _cleanText(subVal.toString());
            if (line.isNotEmpty) subLines.add(line);
          });
          if (subLines.isNotEmpty) {
            widgets.add(_buildNumberedBox(subLines));
          }
        } else {
          // children에 children이 없으면 일반 텍스트(•)
          final line = _cleanText(
            value is Map && value.containsKey('text') ? value['text'].toString() : value.toString(),
          );
          if (line.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $line', style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
            );
          }
        }
      });
    }
    return widgets;
  }

  List<Widget> _buildCurriculumList() {
    if (curriculumData == null) return [];

    List<Widget> widgets = [];
    final filteredEntries = curriculumData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text'].toString() ?? '';
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text']?.toString() ?? '';
      final children = section['children'] as Map?;
      List<Widget> subCards = [];

      List<Widget> subWidgets = [];
      if (children != null) {
        subWidgets = _buildChildrenCards(children);
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
                ...subWidgets,
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
    final sections =
        ['전체'] +
        (curriculumData?.entries
                .map((e) => (e.value as Map<String, dynamic>)['text']?.toString() ?? '')
                .toSet()
                .toList() ??
            []);

    return CommonScaffold(
      title: widget.title,
      body:
          isLoading
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
                        children:
                            sections.map((sec) {
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
