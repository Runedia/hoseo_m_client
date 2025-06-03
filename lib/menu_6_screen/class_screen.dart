import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes.dart';

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

  @override
  void initState() {
    super.initState();
    fetchClassInfo();
  }

  Future<void> fetchClassInfo() async {
    try {
      final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/class?type=${widget.type}'));
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

  Widget _buildCard(String? title, List<String> content, [List<String>? nested]) {
    return Card(
      color: const Color(0xFFF9F4FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text('📚 $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ],
            ...content.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(line, style: const TextStyle(fontSize: 15, height: 1.6)),
            )),
            if (nested != null && nested.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nested.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(line, style: const TextStyle(fontSize: 15, height: 1.6)),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
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
      final children = section['children'] as Map<String, dynamic>? ?? {};

      bool isFirst = true;
      for (final value in children.values) {
        String text = '';
        Map<String, dynamic>? subChildren;

        if (value is String) {
          text = value;
        } else if (value is Map<String, dynamic>) {
          text = value['text']?.toString() ?? '';
          subChildren = value['children'] as Map<String, dynamic>?;
        }

        List<String> main = [];
        List<String> nested = [];
        final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final line in lines) {
          if (RegExp(r'^[가-하]\.|^\d+\.').hasMatch(line)) {
            nested.add(line);
          } else {
            main.add(line);
          }
        }

        if (subChildren != null) {
          for (final sub in subChildren.values) {
            nested.add(sub.toString());
          }
        }

        widgets.add(_buildCard(isFirst ? sectionTitle : null, main, nested));
        isFirst = false;
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final sections = ['전체'] +
        (classData?.entries.map((e) => (e.value as Map<String, dynamic>)['text'].toString()).toSet().toList() ?? []);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: HSColors.HsRed, foregroundColor: Colors.white),
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
