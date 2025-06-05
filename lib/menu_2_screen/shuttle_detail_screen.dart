import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

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

  final asanToCheonanStops = ['아산캠퍼스', '천안아산역', '쌍용2동', '충무병원', '천안역', '천안터미널', '천안캠퍼스'];

  List<String> get stopOrder => widget.isAsanToCheonan ? asanToCheonanStops : asanToCheonanStops.reversed.toList();

  @override
  void initState() {
    super.initState();
    fetchAllScheduleDetails();
  }

  Future<void> fetchAllScheduleDetails() async {
    final dateStr =
        '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';
    final route = widget.isAsanToCheonan ? '1' : '2';
    final simpleUri = Uri.parse(ApiConfig.getUrl('/shuttle/schedule?date=$dateStr&route=$route'));

    try {
      final response = await http.get(simpleUri);
      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        return;
      }

      final decoded = json.decode(response.body);
      final scheduleMap = decoded['data']['schedule'] ?? {};

      List<Map<String, String>> loadedSchedules = [];

      // scheduleMap에서 데이터를 직접 사용 (추가 API 호출 불필요)
      scheduleMap.forEach((busKey, stopData) {
        final startTime = stopData['pos1']?.toString().trim() ?? '';
        final endTime = stopData['pos7']?.toString().trim() ?? '';

        // 시작 시간과 끝 시간이 모두 비어있으면 스킵
        if (startTime.isEmpty && endTime.isEmpty) return;

        // 이미 simpleUri 응답에 모든 pos 데이터가 포함되어 있음
        Map<String, String> row = {'trip': busKey.toString()};
        for (int i = 1; i <= 7; i++) {
          row['pos$i'] = stopData['pos$i']?.toString() ?? '-';
        }
        loadedSchedules.add(row);
      });

      setState(() {
        schedules = loadedSchedules;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        schedules = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: widget.isAsanToCheonan ? '아산 → 천안 셔틀' : '천안 → 아산 셔틀',
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : schedules.isEmpty
              ? const Center(child: Text('셔틀 시간표가 없습니다.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final item = schedules[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Row(
                        children: [
                          Text('${item['trip']}회차', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          Text(
                            '${item['pos1']} → ${item['pos7']}',
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                      children: [
                        const Divider(height: 1),
                        ...List.generate(7, (i) {
                          return ListTile(
                            dense: true,
                            title: Text(stopOrder[i], style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: Text(item['pos${i + 1}'] ?? '-'),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
