import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShuttleDetailScreen extends StatefulWidget {
  final DateTime date;
  final bool isAsanToCheonan;

  const ShuttleDetailScreen({super.key, required this.date, required this.isAsanToCheonan});

  @override
  State<ShuttleDetailScreen> createState() => _ShuttleDetailScreenState();
}

class _ShuttleDetailScreenState extends State<ShuttleDetailScreen> {
  List<Map<String, String>> schedules = [];
  bool isLoading = true;

  final asanToCheonanStops = [
    '아산캠퍼스',
    '천안아산역',
    '쌍용2동',
    '충무병원',
    '천안역',
    '천안터미널',
    '천안캠퍼스'
  ];

  List<String> get stopOrder =>
      widget.isAsanToCheonan ? asanToCheonanStops : asanToCheonanStops.reversed.toList();

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final dateStr = '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';
    final route = widget.isAsanToCheonan ? '1' : '2';
    final uri = Uri.parse('http://rukeras.com:3000/shuttle/schedule/detail?date=$dateStr&route=$route&schedule=all');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final scheduleMap = decoded['data']?['schedules'] ?? decoded['data']?['schedule'] ?? {};

      List<Map<String, String>> parsed = [];
      scheduleMap.forEach((busKey, stops) {
        if (busKey != 'error') {
          Map<String, String> row = {'trip': busKey.replaceAll('bus_', '')};
          for (int i = 0; i < 7; i++) {
            row['pos${i + 1}'] = stops['pos${i + 1}'] ?? '-';
          }
          parsed.add(row);
        }
      });

      setState(() {
        schedules = parsed;
        isLoading = false;
      });
    } else {
      setState(() {
        schedules = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
        title: Text(widget.isAsanToCheonan ? '아산 → 천안 셔틀' : '천안 → 아산 셔틀'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
          ? const Center(child: Text('셔틀 시간표가 없습니다.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('날짜: $dateStr', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(child: Center(child: Text('회차', style: TextStyle(color: Colors.white))))
                ]
                  ..addAll(stopOrder.map((stop) =>
                      Expanded(child: Center(child: Text(stop, style: const TextStyle(color: Colors.white)))))),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final item = schedules[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Center(child: Text(item['trip'] ?? '-'))),
                    ]
                      ..addAll(List.generate(7, (i) =>
                          Expanded(child: Center(child: Text(item['pos${i + 1}'] ?? '-'))))),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
