import 'package:flutter/material.dart';

class ShuttleScreen extends StatelessWidget {
  final String route;
  final DateTime date;

  const ShuttleScreen({
    super.key,
    required this.route,
    required this.date,
  });

  final List<Map<String, String>> schedules = const [
    {'trip': '1', 'departure': '08:00', 'arrival': '08:48'},
    {'trip': '2', 'departure': '09:00', 'arrival': '09:48'},
    {'trip': '3', 'departure': '10:00', 'arrival': '10:48'},
    {'trip': '4', 'departure': '11:00', 'arrival': '11:48'},
    {'trip': '5', 'departure': '12:00', 'arrival': '12:48'},
    {'trip': '6', 'departure': '13:00', 'arrival': '13:48'},
    {'trip': '7', 'departure': '14:00', 'arrival': '14:48'},
    {'trip': '8', 'departure': '15:00', 'arrival': '15:48'},
    {'trip': '9', 'departure': '16:00', 'arrival': '16:48'},
    {'trip': '10', 'departure': '08:00', 'arrival': '08:48'},
    {'trip': '11', 'departure': '09:00', 'arrival': '09:48'},
    {'trip': '12', 'departure': '10:00', 'arrival': '10:48'},
    {'trip': '13', 'departure': '11:00', 'arrival': '11:48'},
    {'trip': '14', 'departure': '12:00', 'arrival': '12:48'},
    {'trip': '15', 'departure': '13:00', 'arrival': '13:48'},
    {'trip': '16', 'departure': '14:00', 'arrival': '14:48'},
    {'trip': '17', 'departure': '15:00', 'arrival': '15:48'},
    {'trip': '18', 'departure': '16:00', 'arrival': '16:48'},
  ];

  @override
  Widget build(BuildContext context) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('셔틀버스'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '노선: $route',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '날짜: $dateString',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // 헤더
            Row(
              children: const [
                Expanded(child: _HeaderCell(text: '회차')),
                Expanded(child: _HeaderCell(text: '출발시간')),
                Expanded(child: _HeaderCell(text: '도착시간')),
              ],
            ),

            const SizedBox(height: 8),

            // 리스트
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
        style:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
