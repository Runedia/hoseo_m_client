import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

class AcademicSchedulePage extends StatefulWidget {
  const AcademicSchedulePage({super.key});

  @override
  State<AcademicSchedulePage> createState() => _AcademicSchedulePageState();
}

class _AcademicSchedulePageState extends State<AcademicSchedulePage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? scheduleData;

  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    print('[DEBUG] fetchSchedule 시작');
    try {
      // 네트워크 연결 확인
      print('[DEBUG] 네트워크 연결 상태 확인 중...');
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;
      print('[DEBUG] 네트워크 연결 상태: $connectivityResult, 연결됨: $isConnected');

      if (isConnected) {
        // 인터넷 연결이 있으면 API 호출
        print('[DEBUG] 인터넷 연결 확인됨 - API 호출 시작');
        await _fetchFromAPI();
        print('[DEBUG] API 호출 완료');
      } else {
        // 인터넷 연결이 없으면 로컬 데이터 사용
        print('[DEBUG] 인터넷 연결 없음 - 로컬 데이터 로드 시작');
        await _loadLocalData();
        print('[DEBUG] 로컬 데이터 로드 완료');
      }
    } catch (e) {
      // API 호출 실패 시 로컬 데이터로 폴백
      print('[DEBUG] fetchSchedule 오류 발생: $e');
      print('[DEBUG] 로컬 데이터로 폴백 시작');
      await _loadLocalData(showOfflineMessage: true); // 오프라인 메시지 표시
      print('[DEBUG] 폴백 완료');
    }
    print('[DEBUG] fetchSchedule 종료');
  }

  Future<void> _fetchFromAPI() async {
    print('[DEBUG] _fetchFromAPI 시작');
    try {
      print('[DEBUG] API 요청 시작: http://rukeras.com:3000/eduguide/calendar');
      final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/calendar'));
      print('[DEBUG] API 응답 받음 - 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[DEBUG] JSON 파싱 시작');
        final data = json.decode(response.body)['data'] as Map<String, dynamic>;
        print('[DEBUG] JSON 파싱 완료 - 데이터 크기: ${data.length}개 항목');

        // 새 데이터를 로컬에 저장
        print('[DEBUG] 로컬 데이터베이스 저장 시작');
        await DatabaseManager.instance.saveScheduleData(data);
        print('[DEBUG] 로컬 데이터베이스 저장 완료');

        setState(() {
          scheduleData = data;
          isLoading = false;
          error = null;
        });
      } else {
        print('[DEBUG] API 응답 오류 - 상태코드: ${response.statusCode}');
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('[DEBUG] _fetchFromAPI 오류: $e');
      throw Exception('API 호출 실패: $e');
    }
  }

  Future<void> _loadLocalData({bool showOfflineMessage = false}) async {
    print('[DEBUG] _loadLocalData 시작');
    try {
      print('[DEBUG] 로컬 데이터베이스에서 데이터 조회 시작');
      final localData = await DatabaseManager.instance.getScheduleData();

      if (localData != null) {
        print('[DEBUG] 로컬 데이터 찾음 - 데이터 크기: ${localData.length}개 항목');
        
        // 오프라인 데이터 사용 안내
        if (showOfflineMessage && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('오프라인 데이터입니다.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        setState(() {
          scheduleData = localData;
          isLoading = false;
          error = null;
        });
        print('[DEBUG] 로컬 데이터로 UI 상태 업데이트 완료');
      } else {
        print('[DEBUG] 로컬 데이터 없음');
        setState(() {
          error = '저장된 데이터가 없습니다. 인터넷 연결을 확인해주세요.';
          isLoading = false;
        });
        print('[DEBUG] 에러 상태로 UI 업데이트 완료');
      }
    } catch (e) {
      print('[DEBUG] _loadLocalData 오류: $e');
      setState(() {
        error = '로컬 데이터 로드 실패: $e';
        isLoading = false;
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 18))))
        .toList();
  }

  Map<String, List<String>> _groupEventsByDate() {
    final Map<String, List<String>> grouped = {};
    if (scheduleData == null) return grouped;

    scheduleData!.forEach((year, months) {
      (months as Map<String, dynamic>).forEach((month, days) {
        (days as Map<String, dynamic>).forEach((day, events) {
          if (events is Map<String, dynamic>) {
            for (var eventEntry in events.entries) {
              final rawText = eventEntry.value.toString();
              final cleaned =
                  rawText.contains('event:')
                      ? rawText.split('event:').last.trim().replaceAll(RegExp(r'[{}]'), '')
                      : rawText;
              final eventText = '$cleaned 시작';
              final dateKey = '$year.${month.padLeft(2, '0')}.${day.padLeft(2, '0')}';
              if (eventText.contains(searchQuery)) {
                grouped.putIfAbsent(dateKey, () => []);
                grouped[dateKey]!.add(eventText);
              }
            }
          }
        });
      });
    });

    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  Widget build(BuildContext context) {
    final years = scheduleData?.keys.toList() ?? [];
    final months = selectedYear != null ? (scheduleData?[selectedYear!]?.keys.toList() ?? []) : [];
    final days =
        (selectedYear != null && selectedMonth != null)
            ? ((scheduleData?[selectedYear!]?[selectedMonth!] as Map<String, dynamic>?)?.keys.toList() ?? [])
            : [];

    final groupedEvents =
        _groupEventsByDate().entries.where((entry) {
          final parts = entry.key.split('.');
          final y = parts[0], m = parts[1], d = parts[2];
          final matchesYear = selectedYear == null || y == selectedYear;
          final matchesMonth = selectedMonth == null || m == selectedMonth!.padLeft(2, '0');
          final matchesDay = selectedDay == null || d == selectedDay!.padLeft(2, '0');
          return matchesYear && matchesMonth && matchesDay;
        }).toList();

    return CommonScaffold(
      title: '학사일정 목록',
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('오류 발생: $error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                hint: const Text('연도 선택', style: TextStyle(fontSize: 18)),
                                value: selectedYear,
                                items: _buildDropdownItems(years.cast<String>()),
                                onChanged:
                                    (value) => setState(() {
                                      selectedYear = value;
                                      selectedMonth = null;
                                      selectedDay = null;
                                    }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                hint: const Text('월 선택', style: TextStyle(fontSize: 18)),
                                value: selectedMonth,
                                items: _buildDropdownItems(months.cast<String>()),
                                onChanged:
                                    (value) => setState(() {
                                      selectedMonth = value;
                                      selectedDay = null;
                                    }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                hint: const Text('일 선택', style: TextStyle(fontSize: 18)),
                                value: selectedDay,
                                items: _buildDropdownItems(days.cast<String>()),
                                onChanged:
                                    (value) => setState(() {
                                      selectedDay = value;
                                    }),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 8),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     SizedBox(
                        //       width: 200,
                        //       child: TextField(
                        //         decoration: const InputDecoration(
                        //           hintText: '검색',
                        //           border: OutlineInputBorder(),
                        //           isDense: true,
                        //           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        //         ),
                        //         onChanged: (value) => setState(() => searchQuery = value),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        groupedEvents.isEmpty
                            ? const Center(child: Text('선택된 조건에 해당하는 일정이 없습니다.'))
                            : ListView.builder(
                              itemCount: groupedEvents.length,
                              itemBuilder: (context, index) {
                                final entry = groupedEvents[index];
                                final date = entry.key;
                                final events = entry.value;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        ...events
                                            .map((e) => Text('- $e', style: const TextStyle(fontSize: 16)))
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
