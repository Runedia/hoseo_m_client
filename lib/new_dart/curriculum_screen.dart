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

  List<Widget> _buildCurriculumList() {
    if (curriculumData == null) return [];
    List<Widget> widgets = [];
    curriculumData!.forEach((key, section) {
      final sectionMap = section as Map<String, dynamic>;
      widgets.add(Text(sectionMap['text'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
      (sectionMap['children'] as Map<String, dynamic>).forEach((_, child) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12, top: 4),
          child: Text('- $child'),
        ));
      });
      widgets.add(const Divider());
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('오류 발생: $error'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: _buildCurriculumList(),
      ),
    );
  }
}
