import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubMajorPage extends StatefulWidget {
  const SubMajorPage({super.key});

  @override
  State<SubMajorPage> createState() => _SubMajorPageState();
}

class _SubMajorPageState extends State<SubMajorPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? subMajorData;

  @override
  void initState() {
    super.initState();
    fetchSubMajorData();
  }

  Future<void> fetchSubMajorData() async {
    try {
      final response = await http.get(
        Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=minor'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        setState(() {
          subMajorData = data;
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

  String buildPlainText() {
    if (subMajorData == null) return '';
    final buffer = StringBuffer();

    for (final entry in subMajorData!.entries) {
      final section = entry.value as Map<String, dynamic>;
      final title = section['text'].toString().trim();
      final children = section['children'] as Map<String, dynamic>;

      buffer.writeln(title);
      buffer.writeln();

      for (final line in children.values) {
        buffer.writeln(line.toString().trim());
      }

      buffer.writeln('\n');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부전공 안내'),
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('❌ 오류 발생: $error'))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          buildPlainText(),
          style: const TextStyle(fontSize: 15.5, height: 1.7),
        ),
      ),
    );
  }
}
