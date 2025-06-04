import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/themes/themes.dart';
import 'package:http/http.dart' as http;

class CurriculumPage extends StatefulWidget {
  final String type;
  final String title;

  const CurriculumPage({super.key, required this.type, required this.title});

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? curriculumData;
  String selectedSection = '전체';
  String searchQuery = '';

  final List<Color> cardColors = [
    HSColors.hsBlue.withOpacity(0.08),
    HSColors.hsGreen.withOpacity(0.12),
    HSColors.hsRed.withOpacity(0.10),
    HSColors.hsGrey.withOpacity(0.10),
  ];

  @override
  void initState() {
    super.initState();
    // 위젯이 완전히 빌드된 후에 fetchCurriculum 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCurriculum();
    });
  }

  Future<void> fetchCurriculum() async {
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
          final response = await http.get(Uri.parse('http://rukeras.com:3000/eduguide/curriculum?type=${widget.type}'));

          if (response.statusCode == 200) {
            // 4. 데이터를 수신 받은 경우 해당 데이터 사용
            final responseData = json.decode(response.body);
            final data = responseData['data'] as Map<String, dynamic>;

            String cleanJson(String text) {
              return text.replaceAll(RegExp(r'<삭제:[^>]*>'), '').trim();
            }

            data.forEach((key, value) {
              if (value is Map && value.containsKey('text')) {
                value['text'] = cleanJson(value['text'].toString());
              }
              if (value is Map && value.containsKey('children')) {
                final children = value['children'];
                if (children is Map) {
                  children.forEach((k, v) {
                    if (v is String) {
                      children[k] = cleanJson(v);
                    } else if (v is Map && v.containsKey('text')) {
                      v['text'] = cleanJson(v['text'].toString());
                    }
                  });
                }
              }
            });

            // 5. DB 업데이트 (덮어쓰배)
            await DatabaseManager.instance.saveCurriculumData(widget.type, responseData);

            // 로딩 대화상자 닫기
            if (mounted) Navigator.of(context).pop();

            setState(() {
              curriculumData = data;
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
          final localData = await DatabaseManager.instance.getCurriculumData(widget.type);

          if (localData != null) {
            final data = localData['data'] as Map<String, dynamic>;

            String cleanJson(String text) {
              return text.replaceAll(RegExp(r'<삭제:[^>]*>'), '').trim();
            }

            data.forEach((key, value) {
              if (value is Map && value.containsKey('text')) {
                value['text'] = cleanJson(value['text'].toString());
              }
              if (value is Map && value.containsKey('children')) {
                final children = value['children'];
                if (children is Map) {
                  children.forEach((k, v) {
                    if (v is String) {
                      children[k] = cleanJson(v);
                    } else if (v is Map && v.containsKey('text')) {
                      v['text'] = cleanJson(v['text'].toString());
                    }
                  });
                }
              }
            });

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
              curriculumData = data;
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
        final localData = await DatabaseManager.instance.getCurriculumData(widget.type);

        if (localData != null) {
          final data = localData['data'] as Map<String, dynamic>;

          String cleanJson(String text) {
            return text.replaceAll(RegExp(r'<삭제:[^>]*>'), '').trim();
          }

          data.forEach((key, value) {
            if (value is Map && value.containsKey('text')) {
              value['text'] = cleanJson(value['text'].toString());
            }
            if (value is Map && value.containsKey('children')) {
              final children = value['children'];
              if (children is Map) {
                children.forEach((k, v) {
                  if (v is String) {
                    children[k] = cleanJson(v);
                  } else if (v is Map && v.containsKey('text')) {
                    v['text'] = cleanJson(v['text'].toString());
                  }
                });
              }
            }
          });

          // 로딩 대화상자 닫기
          if (mounted) Navigator.of(context).pop();

          setState(() {
            curriculumData = data;
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
    cleaned = cleaned.trim();
    return cleaned;
  }

  Widget _buildFormattedText(String text, {bool numbered = false, int? index}) {
    final List<Widget> lines = [];
    final regex = RegExp(r'(단,|다만,)[^\n.]*[\n.]');
    final matches = regex.allMatches(text);
    int lastEnd = 0;

    for (final match in matches) {
      final before = text.substring(lastEnd, match.start).trim();
      if (before.isNotEmpty) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              numbered && index != null ? '$index. $before' : before,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ),
        );
      }

      final condition = match.group(0)!.trim();
      lines.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(condition, style: const TextStyle(fontSize: 15, height: 1.7)),
        ),
      );
      lastEnd = match.end;
    }

    final after = text.substring(lastEnd).trim();
    if (after.isNotEmpty) {
      lines.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            numbered && index != null ? '$index. $after' : after,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines);
  }

  // 박스 카드 내부(중첩) 리스트: 번호 붙여서 출력
  Widget _buildNumberedBox(List<String> lines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < lines.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${i + 1}. ${lines[i]}', style: const TextStyle(fontSize: 15, height: 1.6)),
            ),
        ],
      ),
    );
  }

  // 하위 항목 처리: children 안에 children이 있으면 박스 카드(번호), 없으면 일반 텍스트(•)
  List<Widget> _buildChildrenCards(dynamic children) {
    List<Widget> widgets = [];
    if (children is Map) {
      children.forEach((_, value) {
        if (value is Map && value.containsKey('children')) {
          // 상위 text(설명) •로 출력
          final parentText = _cleanText(value['text']?.toString() ?? '');
          if (parentText.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $parentText', style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
            );
          }
          // 하위 children만 박스 카드(번호 붙임)
          final subLines = <String>[];
          (value['children'] as Map).forEach((_, subVal) {
            final line = _cleanText(subVal.toString());
            if (line.isNotEmpty) subLines.add(line);
          });
          if (subLines.isNotEmpty) {
            widgets.add(_buildNumberedBox(subLines));
          }
        } else {
          // children에 children이 없으면 일반 텍스트(•)
          final line = _cleanText(
            value is Map && value.containsKey('text') ? value['text'].toString() : value.toString(),
          );
          if (line.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $line', style: const TextStyle(fontSize: 15, height: 1.6)),
              ),
            );
          }
        }
      });
    }
    return widgets;
  }

  List<Widget> _buildCurriculumList() {
    if (curriculumData == null) return [];

    List<Widget> widgets = [];
    final filteredEntries = curriculumData!.entries.where((entry) {
      final section = entry.value as Map<String, dynamic>;
      final sectionText = section['text'].toString() ?? '';
      final matchesSection = selectedSection == '전체' || selectedSection == sectionText;
      final matchesSearch = searchQuery.isEmpty || section.toString().contains(searchQuery);
      return matchesSection && matchesSearch;
    });

    for (final entry in filteredEntries) {
      final section = entry.value as Map<String, dynamic>;
      final sectionTitle = section['text']?.toString() ?? '';
      final children = section['children'] as Map?;
      List<Widget> subCards = [];

      List<Widget> subWidgets = [];
      if (children != null) {
        subWidgets = _buildChildrenCards(children);
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
                ...subWidgets,
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
        (curriculumData?.entries
                .map((e) => (e.value as Map<String, dynamic>)['text']?.toString() ?? '')
                .toSet()
                .toList() ??
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
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _buildCurriculumList(),
                    ),
                  ),
                ],
              ),
    );
  }
}
