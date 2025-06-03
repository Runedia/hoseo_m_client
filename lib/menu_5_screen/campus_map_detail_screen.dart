import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hoseo_m_client/database/database_manager.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map_detail.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CampusMapDetailScreen extends StatefulWidget {
  final String campusName;
  final String campusCode;

  const CampusMapDetailScreen({super.key, required this.campusName, required this.campusCode});

  @override
  State<CampusMapDetailScreen> createState() => _CampusMapDetailScreenState();
}

class _CampusMapDetailScreenState extends State<CampusMapDetailScreen> {
  String? campusImagePath;
  List<String> buildingList = [];
  bool isLoading = true;
  String? error;
  final baseUrl = 'http://rukeras.com:3000';
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 loadCampusData를 호출하지 않음
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 첫 번째 호출에서만 loadCampusData 실행
    if (!_hasInitialized) {
      _hasInitialized = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        loadCampusData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '${widget.campusName} 지도',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('오류 발생: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            error = null;
                          });
                          loadCampusData();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: CampusMapDetail(
                    campusName: widget.campusName,
                    campusImagePath: campusImagePath,
                    buildingList: buildingList,
                  ),
                ),
      ),
    );
  }

  Future<void> loadCampusData() async {
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
        // 1. 인터넷이 연결되어있을 경우
        try {
          // 2. REST API 연결
          final jsonUrl = Uri.parse('$baseUrl/campus_map/${widget.campusCode}');
          final imageUrl = Uri.parse('$baseUrl/campus_map/${widget.campusCode}/image');

          final res = await http.get(jsonUrl);

          if (res.statusCode == 200) {
            // 3. 데이터를 수신 받은 경우 해당 데이터 사용
            final data = json.decode(res.body);
            final map = data['data'] as Map<String, dynamic>;
            buildingList = map.entries.map((e) => '${e.key.padLeft(2, '0')}. ${e.value}').toList();

            // 4. DB 업데이트 (덤어쓰기)
            await DatabaseManager.instance.saveCampusMapData(widget.campusCode, data);

            // 이미지 다운로드 및 저장
            final imgRes = await http.get(imageUrl);
            if (imgRes.statusCode == 200) {
              final dir = await getApplicationDocumentsDirectory();
              final imageFile = File('${dir.path}/${widget.campusCode}.gif');
              await imageFile.writeAsBytes(imgRes.bodyBytes);
              campusImagePath = imageFile.path;
            }

            // 로딩 대화상자 닫기
            if (mounted) Navigator.of(context).pop();

            setState(() {
              isLoading = false;
            });
            return;
          } else {
            throw Exception('서버 오류: ${res.statusCode}');
          }
        } catch (e) {
          // 5. 데이터를 수신 실패 한 경우 (ERROR 발생 시)
          print('API 호출 실패: $e');

          // 6. DB에서 데이터 불러오기 후 SnackBar로 오프라인 데이터 입니다. 안내
          final localData = await DatabaseManager.instance.getCampusMapData(widget.campusCode);

          if (localData != null) {
            final map = localData['data'] as Map<String, dynamic>;
            buildingList = map.entries.map((e) => '${e.key.padLeft(2, '0')}. ${e.value}').toList();

            // 로컬 이미지 파일 확인
            final dir = await getApplicationDocumentsDirectory();
            final imageFile = File('${dir.path}/${widget.campusCode}.gif');
            if (await imageFile.exists()) {
              campusImagePath = imageFile.path;
            }

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
              isLoading = false;
            });
            return;
          } else {
            // DB에도 데이터가 없는 경우
            throw Exception('사용 가능한 데이터가 없습니다.');
          }
        }
      } else {
        // 7. 인터넷이 연결되어있지 않을 경우
        // 8. DB 내용 사용
        final localData = await DatabaseManager.instance.getCampusMapData(widget.campusCode);

        if (localData != null) {
          final map = localData['data'] as Map<String, dynamic>;
          buildingList = map.entries.map((e) => '${e.key.padLeft(2, '0')}. ${e.value}').toList();

          // 로컬 이미지 파일 확인
          final dir = await getApplicationDocumentsDirectory();
          final imageFile = File('${dir.path}/${widget.campusCode}.gif');
          if (await imageFile.exists()) {
            campusImagePath = imageFile.path;
          }

          // 로딩 대화상자 닫기
          if (mounted) Navigator.of(context).pop();

          setState(() {
            isLoading = false;
          });
          return;
        } else {
          // 9. DB에도 데이터가 없을 경우 SnackBar로 메시지 표시
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
}
