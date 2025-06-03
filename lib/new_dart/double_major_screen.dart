import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoubleMajorPage extends StatefulWidget {
  const DoubleMajorPage({super.key});

  @override
  State<DoubleMajorPage> createState() => _DoubleMajorPageState();
}

class _DoubleMajorPageState extends State<DoubleMajorPage> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> sections = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCurriculum();
  }

  Future<void> fetchCurriculum() async {
    try {
      final response = await http.get(
        Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=double'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> items = [];
        data.forEach((_, value) {
          items.add(value as Map<String, dynamic>);
        });
        setState(() {
          sections = items;
          isLoading = false;
        });
      } else {
        setState(() {
          error = '서버 오류: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '데이터를 불러오는 중 오류 발생';
        isLoading = false;
      });
    }
  }

  String formatSectionText(Map<String, dynamic> children) {
    final lines = <String>[];

    children.forEach((_, value) {
      if (value is String) {
        String merged = value.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

        // 조건문이 반드시 문장 처음에만 존재해야 하도록 제한
        final cond = RegExp(r'^\s*(단|다만),\s+(.+)$').firstMatch(merged);

        if (cond != null) {
          // 바로 이전 줄이 마침표로 끝나지 않으면 붙여줌
          if (lines.isNotEmpty && !lines.last.trim().endsWith('.')) {
            lines[lines.length - 1] = '${lines.last.trim()}.';
          }
          lines.add('- ${cond.group(1)}, ${cond.group(2)}');
        } else {
          if (!merged.endsWith('.')) merged = '$merged.';
          lines.add('• $merged');
        }
      }
    });

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('복수전공 안내', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(fontSize: 16)))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 ChoiceChip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Row(
              children: [
                for (int i = 0; i < sections.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        sections[i]['text'] ?? '',
                        style: TextStyle(
                          fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: i == selectedIndex,
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      onSelected: (selected) {
                        if (selected) setState(() => selectedIndex = i);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
              ],
            ),
          ),
          // 카드(본문)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  color: isDark ? Colors.grey[900] : const Color(0xFFF7F3FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: Color(0xFF3288FF), size: 22),
                            const SizedBox(width: 7),
                            Text(
                              sections[selectedIndex]['text'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          formatSectionText(sections[selectedIndex]['children'] as Map<String, dynamic>),
                          style: const TextStyle(fontSize: 15.5, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
