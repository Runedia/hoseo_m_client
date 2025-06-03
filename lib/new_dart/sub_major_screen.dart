import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MinorMajorPage extends StatefulWidget {
  const MinorMajorPage({super.key});

  @override
  State<MinorMajorPage> createState() => _MinorMajorPageState();
}

class _MinorMajorPageState extends State<MinorMajorPage> {
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
        Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=minor'),
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
        final cond = RegExp(r'^(단|다만),\s+(.+)').firstMatch(merged);
        if (cond != null) {
          if (lines.isNotEmpty && !lines.last.trim().endsWith('.')) {
            lines[lines.length - 1] = '${lines.last.trim()}.';
          }
          lines.add('  ${cond.group(1)}, ${cond.group(2)}');
        } else {
          if (!merged.endsWith('.')) merged = '$merged.';
          lines.add('• $merged');
        }
      }
    });
    return lines.join('\n');
  }

  PreferredSizeWidget buildAppBar(Color color, Color textColor) {
    return AppBar(
      title: Text('부전공 안내', style: TextStyle(color: textColor)),
      backgroundColor: color,
      iconTheme: IconThemeData(color: textColor),
      centerTitle: true,
    );
  }

  Widget buildContentCard({
    required Color cardColor,
    required String title,
    required String bodyText,
    required Color iconColor,
    required TextStyle? titleStyle,
    required TextStyle? bodyStyle,
  }) {
    return Card(
      elevation: 2,
      color: cardColor,
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
                Icon(Icons.menu_book_rounded, color: iconColor, size: 22),
                const SizedBox(width: 7),
                Text(title, style: titleStyle),
              ],
            ),
            const SizedBox(height: 14),
            Text(bodyText, style: bodyStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final appBarColor = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
      final appBarTextColor = theme.appBarTheme.titleTextStyle?.color ?? Colors.white;
      final cardColor = theme.primaryColor.withOpacity(0.06);

      if (sections.isEmpty || selectedIndex >= sections.length) {
        return Scaffold(
          appBar: buildAppBar(appBarColor, appBarTextColor),
          body: const Center(child: Text('부전공 정보가 없습니다.')),
        );
      }

      final section = sections[selectedIndex];
      final children = section['children'] as Map<String, dynamic>? ?? {};

      return Scaffold(
        appBar: buildAppBar(appBarColor, appBarTextColor),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            color: selectedIndex == i
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        selected: i == selectedIndex,
                        selectedColor: theme.colorScheme.primary.withOpacity(0.12),
                        onSelected: (selected) {
                          if (selected) setState(() => selectedIndex = i);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildContentCard(
                    cardColor: cardColor,
                    title: section['text'] ?? '',
                    bodyText: formatSectionText(children),
                    iconColor: theme.primaryColor,
                    titleStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    bodyStyle: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
