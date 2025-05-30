import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordInfoScreen extends StatefulWidget {
  final String type;
  final String title;
  const RecordInfoScreen({super.key, required this.type, required this.title});

  @override
  State<RecordInfoScreen> createState() => _RecordInfoScreenState();
}

class _RecordInfoScreenState extends State<RecordInfoScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchRecordInfo();
  }

  Future<void> fetchRecordInfo() async {
    try {
      final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/record?type=${widget.type}'));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body)['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xFFBE1924), foregroundColor: Colors.white),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('오류 발생: $error'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: data!.entries.map((entry) {
          final section = entry.value as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section['text'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._buildChildren(section['children']),
              const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildChildren(dynamic children) {
    if (children is Map<String, dynamic>) {
      return children.entries.map((e) {
        if (e.value is String) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('- ${e.value}'),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${e.key}.', style: const TextStyle(fontWeight: FontWeight.bold)),
              ..._buildChildren(e.value['children'])
            ],
          );
        }
      }).toList();
    }
    return [];
  }
}
