import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Color getPrimaryColor(BuildContext context) {
  final themeColor = Theme.of(context).primaryColor;
  return themeColor != null && themeColor != Colors.transparent ? themeColor : const Color(0xFFBE1924);
}

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  String? selectedCampus;
  String? campusImagePath;
  List<String> buildingList = [];
  final baseUrl = 'http://rukeras.com:3000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠퍼스맵', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            selectedCampus == null
                ? _buildCampusButtons()
                : SingleChildScrollView(child: _buildCampusMap(selectedCampus!)),
      ),
    );
  }

  Widget _buildCampusButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_campusButton('아산캠퍼스', 'asan'), const SizedBox(height: 20), _campusButton('천안캠퍼스', 'cheonan')],
    );
  }

  Widget _campusButton(String label, String code) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(context),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    onPressed: () async {
      await loadCampusData(code);
      setState(() {
        selectedCampus = label;
      });
    },
    child: Text(label, style: const TextStyle(color: Colors.white)),
  );

  Widget _buildCampusMap(String campusName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: getPrimaryColor(context),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(campusName, style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: getPrimaryColor(context))),
          child:
              campusImagePath != null
                  ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Scaffold(
                                backgroundColor: Colors.black,
                                body: SafeArea(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 1,
                                      maxScale: 5,
                                      child: Center(
                                        child: Image.file(
                                          File(campusImagePath!),
                                          fit: BoxFit.contain,
                                          width: MediaQuery.of(context).size.width * 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                    child: Image.file(File(campusImagePath!), fit: BoxFit.contain),
                  )
                  : const Center(child: Text('이미지를 불러오는 중...')),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children:
              buildingList
                  .map((b) => SizedBox(width: 160, child: Text(b, style: const TextStyle(fontSize: 14))))
                  .toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedCampus = null;
              buildingList.clear();
              campusImagePath = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: getPrimaryColor(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: const Text('뒤로가기', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> loadCampusData(String campusCode) async {
    final jsonUrl = Uri.parse('$baseUrl/campus_map/$campusCode');
    final imageUrl = Uri.parse('$baseUrl/campus_map/$campusCode/image');
    final dir = await getApplicationDocumentsDirectory();
    final jsonFile = File('${dir.path}/$campusCode.json');
    final imageFile = File('${dir.path}/$campusCode.gif');
    final online = await isOnline();

    if (online) {
      try {
        final res = await http.get(jsonUrl);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final map = data['data'] as Map<String, dynamic>;
          buildingList = map.entries.map((e) => '${e.key.padLeft(2, '0')}. ${e.value}').toList();
          await jsonFile.writeAsString(json.encode(data));
        }

        final imgRes = await http.get(imageUrl);
        if (imgRes.statusCode == 200) {
          await imageFile.writeAsBytes(imgRes.bodyBytes);
        }
      } catch (e) {}
    } else {
      if (await jsonFile.exists()) {
        final content = await jsonFile.readAsString();
        final data = json.decode(content);
        final map = data['data'] as Map<String, dynamic>;
        buildingList = map.entries.map((e) => '${e.key.padLeft(2, '0')}. ${e.value}').toList();
      }
    }

    if (await imageFile.exists()) {
      campusImagePath = imageFile.path;
    }
  }

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
