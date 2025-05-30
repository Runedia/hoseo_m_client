import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AcademicSchedulePage extends StatefulWidget {
  const AcademicSchedulePage({super.key});

  @override
  State<AcademicSchedulePage> createState() => _AcademicSchedulePageState();
}

class _AcademicSchedulePageState extends State<AcademicSchedulePage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? scheduleData;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    try {
      final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/calendar'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        setState(() {
          scheduleData = data;
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

  List<Widget> _buildScheduleList() {
    if (scheduleData == null) return [];
    List<Widget> widgets = [];

    scheduleData!.forEach((year, months) {
      widgets.add(Text('$year년', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
      (months as Map<String, dynamic>).forEach((month, days) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12, top: 4),
          child: Text('$month월', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ));
        (days as Map<String, dynamic>).forEach((day, events) {
          (events as Map<String, dynamic>).forEach((_, text) {
            widgets.add(Padding(
              padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
              child: Text('$month월 $day일 - $text'),
            ));
          });
        });
      });
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학사일정'),
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('오류 발생: $error'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildScheduleList(),
        ),
      ),
    );
  }
}
