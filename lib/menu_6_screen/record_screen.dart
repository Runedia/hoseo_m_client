import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

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
  Map<String, dynamic>? recordData;
  String selectedSection = '전체';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 위젯이 완전히 빌드된 후에 fetchRecordInfo 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecordInfo();
    });
  }

  Future<void> fetchRecordInfo() async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator(), SizedBox(width: 20), Text('로딩 중...')],
          ),
        );
      },
    );

    try {
      // 1. 인터넷 연결 상태 확인
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // 2. 인터넷이 연결되어있을 경우
        try {
          // 3. REST API 연결
          final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/record?type=${widget.type}'));

          if (response.statusCode == 200) {
            // 4. 데이터를 수신 받은 경우 해당 데이터 사용
            final responseData = json.decode(response.body);
            final data = responseData['data'] as Map<String, dynamic>;

            // 5. DB 업데이트 (덮어쓰배)
            await DatabaseManager.instance.saveRecordData(widget.type, responseData);

            // 로딩 대화상자 닫기
            if (mounted) Navigator.of(context).pop();

            setState(() {
              recordData = data;
              isLoading = false;
              error = null;
            });
          } else {
            // 서버 오류
            throw Exception('서버 오류: ${response.statusCode}');
          }
        } catch (e) {
          // 6. 데이터를 수신 실패 한 경우 (ERROR 발생 시)
          print('API 호출 실패: $e');

          // 7. DB에서 데이터 불러오기 후 SnackBar로 오프라인 데이터 입니다. 안내
          final localData = await DatabaseManager.instance.getRecordData(widget.type);

          if (localData != null) {
            final data = localData['data'] as Map<String, dynamic>;

            // 로딩 대화상자 닫기
            if (mounted) Navigator.of(context).pop();

            // 오프라인 데이터 사용 안내
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('오프라인 데이터입니다.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }

            setState(() {
              recordData = data;
              isLoading = false;
              error = null;
            });
          } else {
            // DB에도 데이터가 없는 경우
            throw Exception('인터넷 연결이 없고 저장된 데이터도 없습니다.');
          }
        }
      } else {
        // 8. 인터넷이 연결되어있지 않을 경우
        // 9. DB 내용 사용
        final localData = await DatabaseManager.instance.getRecordData(widget.type);

        if (localData != null) {
          final data = localData['data'] as Map<String, dynamic>;

          // 로딩 대화상자 닫기
          if (mounted) Navigator.of(context).pop();

          setState(() {
            recordData = data;
            isLoading = false;
            error = null;
          });
        } else {
          // 10. DB에도 데이터가 없을 경우 SnackBar로 메시지 표시
          throw Exception('인터넷 연결이 없고 저장된 데이터도 없습니다.');
        }
      }
    } catch (e) {
      // 로딩 대화상자 닫기
      if (mounted) Navigator.of(context).pop();

      // 오류 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터를 불러올 수 없습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _cleanText(String input) {
    String cleaned = input;
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<삭제:.*?>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(text|children):'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[{}]'), '');
    cleaned = cleaned.replaceAllMapped(RegExp(r'\$?(\d+):'), (m) => '\n${m.group(1)}. ');

    // ✅ "다만," 또는 "단," 앞에 줄바꿈 추가
    cleaned = cleaned.replaceAllMapped(RegExp(r'(?<!\n)(\s*)(다만,|단,)', caseSensitive: false), (m) => '\n${m.group(2)}');

    return cleaned.trim();
  }

  bool _isNestedLine(String line) {
    return RegExp(r'^\d+\.\s').hasMatch(line) ||
        line.trim().endsWith('때') ||
        RegExp(r'^(신병|입대 및 병무소집|직계가족 사망|기타)\s*:').hasMatch(line);
  }

  List<Widget> _buildRecordList() {
    if (recordData == null) return [];

    List<Widget> widgets = [];

    final filteredEntries = recordData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text']?.toString() ?? '';
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text']?.toString() ?? '';
      final children = section['children'] as Map?;

      List<String> normalLines = [];
      List<String> nestedLines = [];
      int autoNumber = 1;

      if (children != null) {
        for (final raw in children.values) {
          final textList = <String>[];
          if (raw is String) {
            textList.addAll(_cleanText(raw).split('\n'));
          } else if (raw is Map && raw.containsKey('text')) {
            textList.addAll(_cleanText(raw['text']).split('\n'));
            if (raw.containsKey('children')) {
              final subChildren = raw['children'] as Map;
              for (final sub in subChildren.values) {
                textList.addAll(_cleanText(sub.toString()).split('\n'));
              }
            }
          }

          for (var line in textList.map((e) => e.trim()).where((e) => e.isNotEmpty)) {
            if (RegExp(r'^\d+\.\s').hasMatch(line)) {
              nestedLines.add(line);
            } else if (line.endsWith('때')) {
              nestedLines.add('- $line');
            } else if (RegExp(r'^(신병|입대 및 병무소집|직계가족 사망|기타)\s*:').hasMatch(line)) {
              nestedLines.add('${autoNumber++}. $line');
            } else if (line.startsWith('다만,') || line.startsWith('단,')) {
              // ✅ 줄바꿈만 하고 점(•) 없이 추가
              normalLines.add(line);
            } else {
              normalLines.add('• $line');
            }
          }
        }
      }

      widgets.add(
        Card(
          color: const Color(0xFFF9F4FD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📄 $sectionTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...normalLines.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
                  ),
                ),
                if (nestedLines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          nestedLines
                              .map(
                                (text) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final sections =
        ['전체'] +
        (recordData?.entries.map((e) => (e.value as Map<String, dynamic>)['text']?.toString() ?? '').toSet().toList() ??
            []);

    return CommonScaffold(
      title: widget.title,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('❌ 오류 발생: $error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            sections
                                .map(
                                  (sec) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ChoiceChip(
                                      label: Text(sec),
                                      selected: selectedSection == sec,
                                      onSelected: (_) => setState(() => selectedSection = sec),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: '검색',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: _buildRecordList()),
                  ),
                ],
              ),
    );
  }
}
