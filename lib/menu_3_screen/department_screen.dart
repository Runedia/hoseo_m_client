import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/utils/app_state.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  Map<String, List<String>> departments = {};
  String? expandedCollege;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 히스토리에 현재 페이지 추가 안함 (메인에서 이미 추가됨)
    fetchDepartments();
  }

  Future<File> _localFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<File> downloadImage(String url) async {
    final fileName = Uri.parse(url).pathSegments.last;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    if (!(await file.exists())) {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
      }
    }

    return file;
  }

  Future<void> fetchDepartments() async {
    const apiUrl = 'http://rukeras.com:3000/departments/list?format=detailed';
    final file = await _localFile('departments.json');
    final online = await isOnline();

    try {
      if (online) {
        final res = await http.get(Uri.parse(apiUrl));
        if (res.statusCode == 200) {
          final body = json.decode(res.body);
          await file.writeAsString(json.encode(body));
          final Map<String, dynamic> colleges = body['data']['colleges'];

          final Map<String, List<String>> parsed = {};
          for (final entry in colleges.entries) {
            final collegeName = entry.key;
            final departmentList = entry.value['departments'] as List;
            parsed[collegeName] = departmentList.map<String>((d) => d['name'] as String).toList();
          }

          setState(() {
            departments = parsed;
            isLoading = false;
          });
        } else {}
      } else {
        if (await file.exists()) {
          final content = await file.readAsString();
          final body = json.decode(content);
          final Map<String, dynamic> colleges = body['data']['colleges'];

          final Map<String, List<String>> parsed = {};
          for (final entry in colleges.entries) {
            final collegeName = entry.key;
            final departmentList = entry.value['departments'] as List;
            parsed[collegeName] = departmentList.map<String>((d) => d['name'] as String).toList();
          }

          setState(() {
            departments = parsed;
            isLoading = false;
          });
        } else {}
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchDepartmentDetail(String deptName) async {
    final encodedDeptName = Uri.encodeComponent(deptName);
    final url = Uri.parse('http://rukeras.com:3000/departments/info?dept=$encodedDeptName');
    final file = await _localFile('department-$encodedDeptName.json');
    final online = await isOnline();

    try {
      if (online) {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          await file.writeAsString(response.body);
          final data = json.decode(response.body)['data'];

          final List<File> localImages = [];
          for (final img in (data['images'] ?? [])) {
            final url = 'http://rukeras.com:3000/departments/$img';
            final file = await downloadImage(url);
            localImages.add(file);
          }

          File? singleLocalImage;
          if (data['image'] != null && data['image'].toString().trim().isNotEmpty) {
            final url = 'http://rukeras.com:3000/departments/${data['image']}';
            singleLocalImage = await downloadImage(url);
          }

          return {..._parseDepartment(data), 'localImages': localImages, 'localSingleImage': singleLocalImage};
        }
      } else {
        if (await file.exists()) {
          final content = await file.readAsString();
          final data = json.decode(content)['data'];

          final List<File> localImages = [];
          for (final img in (data['images'] ?? [])) {
            final url = 'http://rukeras.com:3000/departments/$img';
            final file = await downloadImage(url);
            localImages.add(file);
          }

          File? singleLocalImage;
          if (data['image'] != null && data['image'].toString().trim().isNotEmpty) {
            final url = 'http://rukeras.com:3000/departments/${data['image']}';
            singleLocalImage = await downloadImage(url);
          }

          return {..._parseDepartment(data), 'localImages': localImages, 'localSingleImage': singleLocalImage};
        }
      }
    } catch (e) {
      print('Error fetching department detail: $e');
    }

    return null;
  }

  Map<String, dynamic> _parseDepartment(Map<String, dynamic> data) {
    return {
      'name': data['name'] ?? '',
      'code': data['code'] ?? '',
      'campus': data['campus'] ?? '',
      'college': data['college'] ?? '',
      'type': data['type'] ?? '',
      'description': data['description'] ?? '',
      'professors': data['professor'] ?? [],
      'curriculum': data['curriculum'] ?? [],
      'facilities': data['facilities'] ?? [],
      'phone': data['contact']?['phone'] ?? '',
      'email': data['contact']?['email'] ?? '',
      'office': data['contact']?['office'] ?? '',
      'images': data['images'] ?? [],
      'image': data['image'] ?? '',
      'location': data['location'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return CommonScaffold(
      title: '학과정보',
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children:
                      departments.entries.map((entry) {
                        final college = entry.key;
                        final deptList = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    expandedCollege == college ? primaryColor.withOpacity(0.8) : primaryColor,
                                foregroundColor: Colors.white,
                                side: expandedCollege == college ? BorderSide(color: primaryColor, width: 2) : null,
                                elevation: expandedCollege == college ? 8 : 2,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                setState(() {
                                  expandedCollege = expandedCollege == college ? null : college;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      college,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(
                                    expandedCollege == college ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (expandedCollege == college)
                              ...deptList.map((dept) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: primaryColor),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: () async {
                                      // 상세 정보를 가져온 후 새로운 화면으로 이동
                                      final departmentInfo = await fetchDepartmentDetail(dept);
                                      if (departmentInfo != null) {
                                        // AppState에 현재 학과 정보 저장
                                        AppState.setCurrentDepartment(dept, departmentInfo);
                                        // go_router로 이동
                                        GoRouterHistory.instance.pushWithHistory(context, '/department/detail');
                                      }
                                    },
                                    child: Text(dept, style: const TextStyle(color: Colors.black)),
                                  ),
                                );
                              }),
                            const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
