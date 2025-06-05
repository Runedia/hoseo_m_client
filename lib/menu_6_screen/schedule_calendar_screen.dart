import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/config/api_config.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

class CalendarSchedulePage extends StatefulWidget {
  const CalendarSchedulePage({super.key});

  @override
  State<CalendarSchedulePage> createState() => _CalendarSchedulePageState();
}

class _CalendarSchedulePageState extends State<CalendarSchedulePage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? scheduleData;

  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController();
  String? selectedEventPeriod; // 선택된 일정의 기간을 저장
  List<DateTime> highlightedDates = []; // 강조할 날짜들
  List<DateTime> availableMonths = []; // 데이터에서 사용 가능한 년월 목록

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  // 이전 달로 이동 (데이터가 있는 달만)
  void _goToPreviousMonth() {
    if (availableMonths.isEmpty) return;

    final currentIndex = availableMonths.indexWhere(
      (month) => month.year == selectedDate.year && month.month == selectedDate.month,
    );

    if (currentIndex > 0) {
      setState(() {
        selectedDate = availableMonths[currentIndex - 1];
        // 월 변경 시 일정 선택 해제
        selectedEventPeriod = null;
        highlightedDates = [];
      });
    }
  }

  // 다음 달로 이동 (데이터가 있는 달만)
  void _goToNextMonth() {
    if (availableMonths.isEmpty) return;

    final currentIndex = availableMonths.indexWhere(
      (month) => month.year == selectedDate.year && month.month == selectedDate.month,
    );

    if (currentIndex >= 0 && currentIndex < availableMonths.length - 1) {
      setState(() {
        selectedDate = availableMonths[currentIndex + 1];
        // 월 변경 시 일정 선택 해제
        selectedEventPeriod = null;
        highlightedDates = [];
      });
    }
  }

  // 이전 달로 이동 가능한지 확인
  bool _canGoToPreviousMonth() {
    if (availableMonths.isEmpty) return false;

    final currentIndex = availableMonths.indexWhere(
      (month) => month.year == selectedDate.year && month.month == selectedDate.month,
    );

    return currentIndex > 0;
  }

  // 다음 달로 이동 가능한지 확인
  bool _canGoToNextMonth() {
    if (availableMonths.isEmpty) return false;

    final currentIndex = availableMonths.indexWhere(
      (month) => month.year == selectedDate.year && month.month == selectedDate.month,
    );

    return currentIndex >= 0 && currentIndex < availableMonths.length - 1;
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
      await _loadLocalData();
      print('[DEBUG] 폴백 완료');
    }
    print('[DEBUG] fetchSchedule 종료');
  }

  Future<void> _fetchFromAPI() async {
    print('[DEBUG] _fetchFromAPI 시작');
    try {
      print('[DEBUG] API 요청 시작: http://rukeras.com:3000/eduguide/calendar');
      final response = await http.get(Uri.parse(ApiConfig.getUrl('/eduguide/calendar')));
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
          _updateAvailableMonths();
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

  Future<void> _loadLocalData() async {
    print('[DEBUG] _loadLocalData 시작');
    try {
      print('[DEBUG] 로컬 데이터베이스에서 데이터 조회 시작');
      final localData = await DatabaseManager.instance.getScheduleData();

      if (localData != null) {
        print('[DEBUG] 로컬 데이터 찾음 - 데이터 크기: ${localData.length}개 항목');
        setState(() {
          scheduleData = localData;
          isLoading = false;
          error = null;
          _updateAvailableMonths();
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

  // 데이터에서 사용 가능한 년월 목록 업데이트
  void _updateAvailableMonths() {
    if (scheduleData == null) return;

    Set<DateTime> monthSet = {};

    scheduleData!.forEach((year, months) {
      (months as Map<String, dynamic>).forEach((month, days) {
        monthSet.add(DateTime(int.parse(year), int.parse(month)));
      });
    });

    availableMonths = monthSet.toList();
    availableMonths.sort();
  }

  // 년월 선택 다이얼로그 표시
  void _showMonthPicker() {
    if (availableMonths.isEmpty) return;

    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text('년월 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: availableMonths.length,
                  itemBuilder: (context, index) {
                    final month = availableMonths[index];
                    final isCurrentMonth = selectedDate.year == month.year && selectedDate.month == month.month;

                    return ListTile(
                      title: Text(
                        '${month.year}년 ${month.month}월',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                          color: isCurrentMonth ? primaryColor : Colors.black,
                        ),
                      ),
                      trailing: isCurrentMonth ? Icon(Icons.check, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          selectedDate = DateTime(month.year, month.month, 1);
                          // 월 변경 시 일정 선택 해제
                          selectedEventPeriod = null;
                          highlightedDates = [];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 특정 날짜의 일정 가져오기
  List<String> _getEventsForDate(DateTime date) {
    if (scheduleData == null) return [];

    final year = date.year.toString();
    final month = date.month.toString();
    final day = date.day.toString();

    final yearData = scheduleData![year];
    if (yearData == null) return [];

    final monthData = yearData[month];
    if (monthData == null) return [];

    final dayData = monthData[day];
    if (dayData == null) return [];

    List<String> events = [];
    if (dayData is Map<String, dynamic>) {
      for (var eventEntry in dayData.entries) {
        final rawText = eventEntry.value.toString();
        final cleaned =
            rawText.contains('event:') ? rawText.split('event:').last.trim().replaceAll(RegExp(r'[{}]'), '') : rawText;
        events.add(cleaned);
      }
    }

    return events;
  }

  // 일정 이름으로 해당 일정이 있는 모든 날짜 찾기
  List<DateTime> _findEventDates(String eventName) {
    List<DateTime> dates = [];
    if (scheduleData == null) return dates;

    // 원본 이벤트명 정리
    final cleanEventName = eventName.trim();

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

              if (cleaned.contains(cleanEventName) || cleanEventName.contains(cleaned)) {
                final date = DateTime(int.parse(year), int.parse(month), int.parse(day));
                dates.add(date);
              }
            }
          }
        });
      });
    });

    return dates;
  }

  // 일정 선택 처리
  void _selectEvent(String eventName) {
    setState(() {
      if (selectedEventPeriod == eventName) {
        // 이미 선택된 일정을 다시 누르면 선택 해제
        selectedEventPeriod = null;
        highlightedDates = [];
      } else {
        selectedEventPeriod = eventName;
        highlightedDates = _findEventDates(eventName);
      }
    });
  }

  // 날짜가 강조되어야 하는지 확인
  bool _isHighlighted(DateTime date) {
    return highlightedDates.any(
      (highlightDate) =>
          highlightDate.year == date.year && highlightDate.month == date.month && highlightDate.day == date.day,
    );
  }

  // 해당 날짜에 일정이 있는지 확인
  bool _hasEvents(DateTime date) {
    return _getEventsForDate(date).isNotEmpty;
  }

  // 달력 그리드 생성
  Widget _buildCalendarGrid(DateTime currentDate) {
    final primaryColor = Theme.of(context).primaryColor;
    final lightPrimaryColor = Theme.of(context).primaryColorLight;

    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // 요일 헤더
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    for (String weekday in weekdays) {
      dayWidgets.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            weekday,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  weekday == '일'
                      ? Colors.red
                      : weekday == '토'
                      ? Colors.blue
                      : Colors.black,
            ),
          ),
        ),
      );
    }

    // 이전 달의 빈 칸들
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(Container());
    }

    // 현재 달의 날짜들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentDate.year, currentDate.month, day);
      final hasEvents = _hasEvents(date);
      final isSelected =
          selectedDate.year == date.year && selectedDate.month == date.month && selectedDate.day == date.day;
      final isToday =
          DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day;
      final isHighlighted = _isHighlighted(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
              // 날짜 선택 시 일정 선택 해제
              selectedEventPeriod = null;
              highlightedDates = [];
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? primaryColor
                      : isToday
                      ? lightPrimaryColor ?? primaryColor.withOpacity(0.3)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border:
                  isHighlighted
                      ? Border.all(color: Colors.black, width: 2)
                      : hasEvents && !isSelected
                      ? Border.all(color: primaryColor, width: 1)
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : isToday
                            ? primaryColor
                            : Colors.black,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasEvents && !isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(title: '학사일정 달력', body: _buildBody());
  }

  Widget _buildBody() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text('오류 발생: $error'))
        : Column(
          children: [
            // 달력 헤더 (월/년 표시 및 네비게이션)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _canGoToPreviousMonth() ? _goToPreviousMonth : null,
                    icon: Icon(Icons.chevron_left, color: _canGoToPreviousMonth() ? Colors.black : Colors.grey),
                  ),
                  GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${selectedDate.year}년 ${selectedDate.month}월',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _canGoToNextMonth() ? _goToNextMonth : null,
                    icon: Icon(Icons.chevron_right, color: _canGoToNextMonth() ? Colors.black : Colors.grey),
                  ),
                ],
              ),
            ),

            // 달력 그리드
            Container(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildCalendarGrid(selectedDate)),

            const Divider(thickness: 1, height: 32),

            // 선택된 날짜의 일정 표시
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 일정',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildEventList()),
                  ],
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildEventList() {
    final events = _getEventsForDate(selectedDate);
    final primaryColor = Theme.of(context).primaryColor;

    if (events.isEmpty) {
      return const Center(child: Text('선택된 날짜에 일정이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final isEventSelected = selectedEventPeriod == events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isEventSelected ? Colors.black : primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            title: Text(
              events[index],
              style: TextStyle(fontSize: 16, fontWeight: isEventSelected ? FontWeight.bold : FontWeight.normal),
            ),
            onTap: () => _selectEvent(events[index]),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
