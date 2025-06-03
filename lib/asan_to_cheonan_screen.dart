import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AsanToCheonanScreen extends StatefulWidget {
  final DateTime date;

  const AsanToCheonanScreen({super.key, required this.date});

  @override
  State<AsanToCheonanScreen> createState() => _AsanToCheonanScreenState();
}

class _AsanToCheonanScreenState extends State<AsanToCheonanScreen> {
  List<Map<String, String>> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final dateStr = '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('http://rukeras.com:3000/shuttle/schedule?date=$dateStr&route=1');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      final Map<String, dynamic> rawSchedule = data['schedule'];

      List<Map<String, String>> parsed = [];
      rawSchedule.forEach((busKey, times) {
        if (busKey != 'error') {
          parsed.add({
            'trip': busKey.replaceAll('bus_', ''),
            'departure': times['pos1'] ?? '',
            'arrival': times['pos7'] ?? '',
          });
        }
      });

      setState(() {
        schedules = parsed;
        isLoading = false;
      });
    } else {
      // 오류 처리
      setState(() {
        schedules = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
        title: const Text('아산 → 천안 셔틀'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
          ? const Center(child: Text('셔틀 시간표가 없습니다.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '노선: 아산 → 천안',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '날짜: $dateString',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: _HeaderCell(text: '회차')),
                Expanded(child: _HeaderCell(text: '출발시간')),
                Expanded(child: _HeaderCell(text: '도착시간')),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final item = schedules[index];
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('${item['trip']}회차 상세정보'),
                        content: Text('출발: ${item['departure']}\n도착: ${item['arrival']}'),
                        actions: [
                          TextButton(
                            child: const Text("닫기"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(child: Text(item['trip']!, style: const TextStyle(fontSize: 15))),
                        ),
                        Expanded(
                          child: Center(child: Text(item['departure']!, style: const TextStyle(fontSize: 15))),
                        ),
                        Expanded(
                          child: Center(child: Text(item['arrival']!, style: const TextStyle(fontSize: 15))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
