import 'package:flutter/material.dart';

class CheonanToAsanScreen extends StatelessWidget {
  final DateTime date;

  const CheonanToAsanScreen({super.key, required this.date});

  final List<Map<String, String>> schedules = const [
    {'trip': '1', 'departure': '08:30', 'arrival': '09:15'},
    {'trip': '2', 'departure': '09:30', 'arrival': '10:15'},
    {'trip': '3', 'departure': '10:30', 'arrival': '11:15'},
    {'trip': '4', 'departure': '11:30', 'arrival': '12:15'},
    {'trip': '5', 'departure': '12:30', 'arrival': '13:15'},
    {'trip': '6', 'departure': '13:30', 'arrival': '14:15'},
    {'trip': '7', 'departure': '14:30', 'arrival': '15:15'},
    {'trip': '8', 'departure': '15:30', 'arrival': '16:15'},
    {'trip': '9', 'departure': '16:30', 'arrival': '17:15'},
  ];

  @override
  Widget build(BuildContext context) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
        title: const Text('천안 → 아산 셔틀'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '노선: 천안 → 아산',
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
                        content: Text(
                            '출발: ${item['departure']}\n도착: ${item['arrival']}'),
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
                          child: Center(
                            child: Text(item['trip']!, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(item['departure']!, style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(item['arrival']!, style: const TextStyle(fontSize: 15)),
                          ),
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
