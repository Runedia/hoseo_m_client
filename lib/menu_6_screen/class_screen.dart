import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;

class ClassInfoScreen extends StatefulWidget {
  final String type;
  final String title;

  const ClassInfoScreen({super.key, required this.type, required this.title});

  @override
  State<ClassInfoScreen> createState() => _ClassInfoScreenState();
}

class _ClassInfoScreenState extends State<ClassInfoScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? classData;
  String selectedSection = '전체';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 위젯이 완전히 빌드된 후에 fetchClassInfo 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchClassInfo();
    });
  }

  Future<void> fetchClassInfo() async {
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
          final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/class?type=${widget.type}'));

          if (response.statusCode == 200) {
            // 4. 데이터를 수신 받은 경우 해당 데이터 사용
            final responseData = json.decode(response.body);
            final data = responseData['data'] as Map<String, dynamic>;

            // 5. DB 업데이트 (덮어쓰배)
            await DatabaseManager.instance.saveClassData(widget.type, responseData);

            // 로딩 대화상자 닫기
            if (mounted) Navigator.of(context).pop();

            setState(() {
              classData = data;
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
          final localData = await DatabaseManager.instance.getClassData(widget.type);

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
              classData = data;
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
        final localData = await DatabaseManager.instance.getClassData(widget.type);

        if (localData != null) {
          final data = localData['data'] as Map<String, dynamic>;

          // 로딩 대화상자 닫기
          if (mounted) Navigator.of(context).pop();

          setState(() {
            classData = data;
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

  String _formatNestedLine(String line) {
    // "다만," "단," 앞에 줄바꿈
    return line.replaceAllMapped(RegExp(r'(다만,|단,)', caseSensitive: false), (m) => '\n${m.group(1)}');
  }

  Widget _buildCard(String? title, List<String> content, [List<String>? nested]) {
    return Card(
      color: const Color(0xFFF9F4FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text('📚 $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ],
            ...content.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(line, style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
            ),
            if (nested != null && nested.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      nested.map((line) {
                        final formatted = _formatNestedLine(line);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(formatted, style: const TextStyle(fontSize: 15, height: 1.6)),
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildClassList() {
    if (classData == null) return [];

    // *** [검색 기능] 검색어와 섹션에 따른 데이터 필터링 ***
    List<Widget> widgets = [];
    final filteredEntries = classData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text'].toString();
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text'].toString();
      final children = section['children'] as Map<String, dynamic>? ?? {};

      bool isFirst = true;
      for (final value in children.values) {
        String text = '';
        Map<String, dynamic>? subChildren;

        if (value is String) {
          text = value;
        } else if (value is Map<String, dynamic>) {
          text = value['text']?.toString() ?? '';
          subChildren = value['children'] as Map<String, dynamic>?;
        }

        List<String> main = [];
        List<String> nested = [];
        final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final line in lines) {
          if (RegExp(r'^[가-하]\.|^\d+\.').hasMatch(line)) {
            nested.add(line);
          } else {
            main.add(line);
          }
        }

        if (subChildren != null) {
          for (final sub in subChildren.values) {
            if (sub is String) {
              nested.add(sub);
            } else if (sub is Map && sub.containsKey('text')) {
              nested.add(sub['text'].toString());
            }
          }
        }

        widgets.add(_buildCard(isFirst ? sectionTitle : null, main, nested));
        isFirst = false;
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final sections =
        ['전체'] +
        (classData?.entries.map((e) => (e.value as Map<String, dynamic>)['text'].toString()).toSet().toList() ?? []);

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
                            sections.map((sec) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(sec),
                                  selected: selectedSection == sec,
                                  onSelected: (_) => setState(() => selectedSection = sec),
                                ),
                              );
                            }).toList(),
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
                    child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: _buildClassList()),
                  ),
                ],
              ),
    );
  }
}
