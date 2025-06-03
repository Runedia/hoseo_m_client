import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  Map<String, List<String>> departments = {};
  Map<String, dynamic> departmentInfo = {};
  String? expandedCollege;
  String? selectedDepartment;
  bool isLoading = true;

  Color getPrimaryColor(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    return themeColor != null && themeColor != Colors.transparent ? themeColor : const Color(0xFFBE1924);
  }

  @override
  void initState() {
    super.initState();
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

  Future<void> fetchDepartmentDetail(String deptName) async {
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

          setState(() {
            departmentInfo = {
              ..._parseDepartment(data),
              'localImages': localImages,
              'localSingleImage': singleLocalImage,
            };
          });
        } else {}
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

          setState(() {
            departmentInfo = {
              ..._parseDepartment(data),
              'localImages': localImages,
              'localSingleImage': singleLocalImage,
            };
          });
        } else {}
      }
    } catch (e) {}
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
    final primaryColor = getPrimaryColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('학과정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child:
                    selectedDepartment == null
                        ? ListView(
                          children:
                              departments.entries.map((entry) {
                                final college = entry.key;
                                final deptList = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          expandedCollege = expandedCollege == college ? null : college;
                                        });
                                      },
                                      child: Text(college, style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(height: 4),
                                    if (expandedCollege == college)
                                      ...deptList.map((dept) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: primaryColor),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                selectedDepartment = dept;
                                                departmentInfo = {};
                                              });
                                              await fetchDepartmentDetail(dept);
                                            },
                                            child: Text(dept, style: const TextStyle(color: Colors.black)),
                                          ),
                                        );
                                      }),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                        )
                        : _buildDepartmentDetail(primaryColor),
              ),
    );
  }

  Widget _buildDepartmentDetail(Color primaryColor) {
    final name = departmentInfo['name'] ?? '';
    final college = departmentInfo['college'] ?? '';
    final type = departmentInfo['type'] ?? '';
    final description = departmentInfo['description'] ?? '';
    final phone = departmentInfo['phone'];
    final email = departmentInfo['email'];
    final location = departmentInfo['location'];
    final localImages = departmentInfo['localImages'] ?? [];
    final localSingleImage = departmentInfo['localSingleImage'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(name, style: const TextStyle(color: Colors.black)),
          ),
          if (localImages.isNotEmpty)
            ...localImages.map<Widget>(
              (file) => Container(margin: const EdgeInsets.only(bottom: 8), child: Image.file(file)),
            ),
          if (localImages.isEmpty && localSingleImage != null)
            Container(margin: const EdgeInsets.only(bottom: 8), child: Image.file(localSingleImage)),
          if (college.isNotEmpty) _infoBox('단과대학: $college', primaryColor),
          if (type.isNotEmpty) _infoBox('구분: $type', primaryColor),
          if (description.isNotEmpty) _infoBox('설명: $description', primaryColor),
          if (phone != null && phone.toString().trim().isNotEmpty) _infoBox('대표번호: $phone', primaryColor),
          if (location != null && location.toString().trim().isNotEmpty) _infoBox('위치: $location', primaryColor),
          if (email != null && email.toString().trim().isNotEmpty) _infoBox('이메일: $email', primaryColor),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDepartment = null;
                departmentInfo = {};
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('뒤로가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String text, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: primaryColor)),
      child: Text(text),
    );
  }
}
