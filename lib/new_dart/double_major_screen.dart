import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../settings_screen.dart';

class DoubleMajorPage extends StatefulWidget {
  const DoubleMajorPage({super.key});

  @override
  State<DoubleMajorPage> createState() => _DoubleMajorPageState();
}

class _DoubleMajorPageState extends State<DoubleMajorPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? curriculumData;

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
        setState(() {
          curriculumData = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복수전공 교육과정', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: curriculumData!.entries.map((entry) {
          final section = entry.value;
          final title = section['text'];
          final children = section['children'] as Map<String, dynamic>;
          final content = _formatContent(children);
          return _buildContentCard(title, content);
        }).toList(),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildContentCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
          ],
        ),
      ),
    );
  }

  String _formatContent(Map<String, dynamic> children) {
    List<String> lines = [];

    children.forEach((key, value) {
      if (value is String) {
        lines.add('$key. $value');
      } else if (value is Map && value['text'] != null) {
        lines.add('$key. ${value['text']}');
        final subChildren = value['children'] as Map<String, dynamic>? ?? {};
        subChildren.forEach((subKey, subValue) {
          lines.add('• $subValue');
        });
      }
    });

    String result = lines.join('\n');

    // 조건부 문장 처리: - 단, - 다만 줄바꿈 및 쉼표 유지
    result = result.replaceAllMapped(
      RegExp(r'\s*-\s*(단|다만),\s*'),
          (match) => '\n- ${match[1]}, ',
    );

    return result.trim();
  }

  Widget _buildBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(context, Icons.arrow_back, '이전', () {
            Navigator.pop(context);
          }),
          _buildNavButton(context, Icons.home, '홈', () {
            Navigator.popUntil(context, (route) => route.isFirst);
          }),
          _buildNavButton(context, Icons.arrow_forward, '다음', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('다음 기능은 준비 중입니다.')),
            );
          }),
          _buildNavButton(context, Icons.settings, '설정', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(48, 48),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
