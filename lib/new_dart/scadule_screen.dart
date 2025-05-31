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

  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownMenuItem<String>(
      value: item,
      child: Text(item, style: const TextStyle(fontSize: 18)),
    ))
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
              final cleaned = rawText.contains('event:')
                  ? rawText.split('event:').last.trim().replaceAll(RegExp(r'[{}]'), '')
                  : rawText;
              final eventText = cleaned + ' 시작';
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

    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = scheduleData?.keys.toList() ?? [];
    final months = selectedYear != null ? (scheduleData?[selectedYear!]?.keys.toList() ?? []) : [];
    final days = (selectedYear != null && selectedMonth != null)
        ? ((scheduleData?[selectedYear!]?[selectedMonth!] as Map<String, dynamic>?)?.keys.toList() ?? [])
        : [];

    final groupedEvents = _groupEventsByDate().entries.where((entry) {
      final parts = entry.key.split('.');
      final y = parts[0], m = parts[1], d = parts[2];
      final matchesYear = selectedYear == null || y == selectedYear;
      final matchesMonth = selectedMonth == null || m == selectedMonth!.padLeft(2, '0');
      final matchesDay = selectedDay == null || d == selectedDay!.padLeft(2, '0');
      return matchesYear && matchesMonth && matchesDay;
    }).toList();

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
                        onChanged: (value) => setState(() {
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
                        onChanged: (value) => setState(() {
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
                        onChanged: (value) => setState(() {
                          selectedDay = value;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '검색',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: groupedEvents.isEmpty
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
                        ...events.map((e) => Text('- $e', style: const TextStyle(fontSize: 16))).toList(),
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
